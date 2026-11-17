defmodule PublicSituationMachineTurnZero.DoublePassageStudyTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    DoublePassageStudy,
    CoBuilding,
    CoBuildingGeometry,
    MaterialRibbon
  }

  alias DoublePassageStudy, as: D
  alias CoBuilding, as: C
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  test "content digest uses sorted typed map pairs rather than JSON object iteration" do
    assert C.digest_profile() == "co-building-canonical-json-v1"
    assert C.digest(%{b: [2, 3], a: 1}) == C.digest(Map.new([{:a, 1}, {:b, [2, 3]}]))
    refute C.digest(%{a: 1}) == C.digest(%{"a" => 1})
    refute C.digest([:a]) == C.digest(["a"])

    expected =
      :crypto.hash(
        :sha256,
        Jason.encode!(["map", [[["atom", "a"], 1], [["atom", "b"], ["list", [2, 3]]]]])
      )
      |> Base.encode16(case: :lower)

    assert C.digest(%{b: [2, 3], a: 1}) == expected
  end

  test "one source String shares finite sections through outward, AROUND and return passages" do
    s = D.model()
    [outward, around, return] = s.segments
    assert Enum.map(s.segments, & &1.id) == ~w(double-outward double-around double-return)
    assert Enum.all?(s.segments, &(&1.door_id == s.door.id and &1.course_id == s.id))
    assert outward.office =~ "TOWARD STANDING FOR STAGING"
    assert return.office =~ "FROM STAGING FOR STANDING"

    for [a, b] <- Enum.chunk_every(s.segments, 2, 1, :discard) do
      assert List.last(a.points) == hd(b.points)
      assert List.last(a.geometry.sections) == hd(b.geometry.sections)
    end

    assert Enum.min(Enum.map(around.points, &Enum.at(&1, 2))) < -3
    assert Enum.max(Enum.map(around.points, &Enum.at(&1, 2))) > -3
    [a, b] = Enum.slice(outward.points, 1, 2)
    [x, y, z] = M.sub(b, a)
    assert_in_delta x, y, 1.0e-9
    assert z == 0
  end

  test "measured opening incidence is eight boundary samples, never four appointed contacts" do
    s = D.model()
    [outward, around, return] = s.incidence
    assert length(outward.inside_opening) == 4
    assert around.inside_opening == []
    assert length(return.inside_opening) == 4
    assert s.quadranglementing.measured_count == 8
    assert s.quadranglementing.appointed_four_points == nil
    assert s.quadranglementing.required_four_point_incidence == :unproved

    for inc <- s.incidence, point <- inc.inside_opening do
      assert D.inside_opening?(point, s.door)
      assert_in_delta Enum.at(point, 2), s.door.plane_z, 1.0e-9
    end

    assert Enum.all?(
             outward.outside_opening ++ return.outside_opening,
             &(not D.inside_opening?(&1, s.door))
           )
  end

  test "plane incidence uses actual finite edges and excludes a parallel displaced mesh" do
    box = G.box([0, 0, -1], [1, 1, 1])
    hits = D.plane_incidence(box, 0)
    assert Enum.sort(hits) == Enum.sort([[0, 0, 0], [1, 0, 0], [0, 1, 0], [1, 1, 0]])
    assert D.plane_incidence(box, 2) == []
  end

  test "sightline-clear candidate preserves finite central sightline and preserved aperture and frame" do
    s = D.model()
    refute s.sightline.course_interference
    assert s.sightline.central_ray_hit == nil
    # A crossing through the centre must actually fail this diagnostic.
    obstruct = G.sweep([[3, 2.4, -2], [3, 2.4, 0]], 0.10, 0.02)
    assert G.collision?(obstruct, s.sightline.corridor)
    assert is_number(G.ray([3, 2.4, -12], [0, 0, 1], obstruct.faces))
    m = C.model(C.new())
    refute m.double_clearance.gallery_frame_interference
    refute m.double_clearance.stable_aperture_interference
    assert C.selected(m, "cb:slate").gallery_door_identity == s.door.id
    assert s.lifecycle.subsequent_twist == :yellow_unfurnished
    assert s.lifecycle.flat_pinning == "cb:next-fold"
    assert s.lifecycle.pittoning_conversion == :unperformed
  end

  test "inspection overlays preserve prior source meshes and actual consequence fields" do
    initial = C.new()
    before = C.model(initial)
    assert {:ok, after_state} = C.change(initial, 0, :double_passage)
    after_model = C.model(after_state)
    assert C.source_digest(before) == C.source_digest(after_model)
    assert before.acquisition == after_model.acquisition

    assert Enum.all?(before.parts, fn p ->
             C.selected(after_model, p.id).source_geometry == p.source_geometry
           end)

    for id <- ~w(cb:double-outward cb:double-return cb:slate cb:seat cb:double-registration) do
      assert C.visible?(C.selected(after_model, id), after_state)
    end

    assert {:error, :stale} = C.change(after_state, 0, :double_passage)
    assert {:error, _} = C.change(after_state, 1, :convert_pittoning)
    assert after_model.double_passage.relation.final_semantical_appointment == :unappointed
  end
end
