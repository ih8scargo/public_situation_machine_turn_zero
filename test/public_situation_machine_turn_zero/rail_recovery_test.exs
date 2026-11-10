defmodule PublicSituationMachineTurnZero.Workshop.RailRecoveryTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.RailRecovery, as: R
  alias PublicSituationMachineTurnZero.Architecture.InscriptionResolution

  test "source coordinates and 25 identities survive either half-twist with no acquisition" do
    source = InscriptionResolution.model()
    before = File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json")
    a = R.model(1)
    b = R.model(-1)
    assert a.source == source and b.source == source
    assert Enum.map(a.letters, & &1.ordinal) == Enum.to_list(1..25)
    assert Enum.map_join(a.letters, & &1.letter) == "THEPUBLICSITUATIONMACHINE"

    assert Enum.frequencies_by(a.letters, & &1.word) == %{
             "THE" => 3,
             "PUBLIC" => 6,
             "SITUATION" => 9,
             "MACHINE" => 7
           }

    assert Enum.at(a.letters, 17).successor == Enum.at(a.letters, 18).id
    assert Enum.at(a.letters, 18).predecessor == Enum.at(a.letters, 17).id
    assert a.fixed == b.fixed
    assert a.constitutional_handedness == nil
    assert a.fixed.discrete_turn.advance == :unavailable
    assert a.source_to_gallery == nil
    assert File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json") == before
  end

  test "material rolls exactly a half-turn against transported frame, never reverses order" do
    for hand <- [-1, 1] do
      m = R.model(hand)
      [first | _] = m.ribbon.twist
      last = List.last(m.ribbon.twist)
      assert_in_delta first.roll, 0, 1.0e-12
      assert_in_delta last.roll, hand * :math.pi(), 1.0e-12
      assert_in_delta R.dot(first.base, first.across), 1, 1.0e-12
      assert_in_delta R.dot(last.base, last.across), -1, 1.0e-12
      assert m.ribbon.head == "inscription-letter-1"
      assert m.ribbon.tail == "inscription-letter-25"
      assert m.ribbon.clearance.closed == false

      for f <- m.ribbon.frames do
        assert_in_delta R.dot(f.tangent, f.base), 0, 1.0e-9
        assert_in_delta R.norm(f.across), 1, 1.0e-9
        assert f.point == R.source_sample(m.source, f.purchase).point
      end
    end

    assert Enum.map(R.model(1).ribbon.frames, & &1.point) ==
             Enum.map(R.model(-1).ribbon.frames, & &1.point)
  end

  test "ribbon front/back and wedging seams share exact vertices through the twist" do
    for hand <- [-1, 1] do
      for [a, b] <- Enum.chunk_every(R.model(hand).ribbon.faces, 2, 1, :discard) do
        assert Enum.at(a.points, 3) == Enum.at(b.points, 0)
        assert Enum.at(a.points, 2) == Enum.at(b.points, 1)
        assert Enum.at(a.back, 3) == Enum.at(b.back, 0)
        assert Enum.at(a.back, 2) == Enum.at(b.back, 1)
        assert Enum.drop(a.support_points, 4) == Enum.take(b.support_points, 4)
        assert a.to == b.from
      end
    end
  end

  test "finite occupied conflicts remain collisions and missing Gallery fit stays unqualified" do
    m = R.model()
    assert Enum.any?(m.collisions, &(&1.a == "Square-Axle" and &1.b == "COB-stand"))
    assert m.ribbon.clearance.status == :unqualified
    assert m.ribbon.clearance.self_intersection == :not_certified
    assert m.fixed.table.diameter == 3
    assert m.fixed.ground.normal == [0, 1, 0]
    assert m.fixed.here != m.fixed.next
    assert m.corner.angle_degrees == 90
    # The source has sub-unit successive centers. Unit bounds cannot be certified
    # as a constitutional rail merely by rendering them around those centers.
    [a, b | _] = m.letters
    assert R.norm(R.sub(a.center, b.center)) < 1
  end

  test "explicit rigid coordinate transforms round-trip independent of Regarding" do
    basis = [[0, 0, 1], [0, 1, 0], [-1, 0, 0]]

    for p <- [[0, 0, 0], [1, 2, 3], [-3, 6, -2]] do
      q = R.to_world(p, [9, -3, 2], basis) |> R.from_world([9, -3, 2], basis)
      Enum.zip(p, q) |> Enum.each(fn {a, b} -> assert_in_delta a, b, 1.0e-12 end)
    end

    m = R.model()

    for stand <- ~w(ordinary upstanding table-plan axle N-M-before N-M-within N-M-after),
        kind <- ~w(plan section located) do
      PublicSituationMachineTurnZeroWeb.RailRecoveryLive.scene(m, kind, stand)
    end

    assert R.model() == m
  end
end
