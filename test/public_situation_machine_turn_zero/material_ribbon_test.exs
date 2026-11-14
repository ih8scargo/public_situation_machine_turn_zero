defmodule PublicSituationMachineTurnZero.MaterialRibbonTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{MaterialRibbon, PairedMotor, Steeling}
  alias MaterialRibbon, as: M

  test "occupied rigid triangles retain area, sides, ordered hinge and finite thickness" do
    for q <- [0, 0.25, 0.5, 0.75, 1], kind <- [:outgoing, :retained, :reciprocal] do
      p = M.prism(Atom.to_string(kind), M.triangle(q, kind), 0.04)
      assert_in_delta p.area, 18, 1.0e-8
      assert length(p.faces) == 5
      assert length(p.vertices) == 6

      assert Enum.sort(p.lengths)
             |> Enum.zip([6, 6, :math.sqrt(72)])
             |> Enum.all?(fn {a, b} -> abs(a - b) < 1.0e-8 end)

      assert p.hinge.endpoints == [[-3, 0, -3], [3, 0, 3]]
      assert p.hinge.ordering == "A TOWARD B"

      for {a, b} <- Enum.zip(Enum.take(p.vertices, 3), Enum.drop(p.vertices, 3)),
          do: assert_in_delta(M.distance(a, b), 0.04, 1.0e-8)
    end
  end

  test "finite clearance stop rejects a fold, keeps current material, and grants no turn" do
    s = M.new()
    start = M.prism("outgoing", M.triangle(0, :outgoing), s.thickness)
    finish = M.prism("outgoing", M.triangle(1, :outgoing), s.thickness)
    refute M.collision?(start, M.obstacle())
    assert M.collision?(finish, M.obstacle())
    {:ok, enabled} = M.operate(s, 0, {:toggle, :obstacle?})
    {:ok, blocked} = M.operate(enabled, 1, {:fold, 1.0})
    assert blocked.q == 0
    assert blocked.last_attempt == 1
    assert List.last(blocked.events).result == :blocked_clearance_stop
    assert blocked.index == 0
    assert Enum.all?(blocked.events, &(&1.acquired_turn_delta == 0))
    assert {:error, :stale_or_limit} = M.operate(blocked, 0, {:fold, 0.5})
    assert {:error, :unsupported_operation} = M.operate(blocked, 2, :re_step)
  end

  test "source N18 and curved boundary are kept distinct; only supported comparison transform is reversible" do
    r = M.return_register()
    square = Steeling.model(Steeling.defaults())
    assert r.n_return == square["n_return"]
    assert hd(r.source_points) == [18, 0, 0]
    assert r.incoming == [0.3000000000000007, -0.4, 0]

    for p <- r.source_points do
      {:ok, q} = M.transform(p, "steeling-u13-to-motor-v1")
      {:ok, back} = M.transform(q, "motor-to-steeling-u13-v1")
      assert M.distance(back, p) < 1.0e-10
      if Enum.at(p, 2) == 0, do: assert_in_delta(hd(q), Enum.at(q, 2), 1.0e-10)
    end

    assert {:error, :unsupported_frame_correspondence} =
             M.transform([18, 0, 0], "curved-rail-to-motor")

    rail = M.rail_register(1)
    assert rail.source_to_motor == nil
    assert rail.n18_boundary.point == [1.6, 1.5999999999999999, 3.2]
    assert length(rail.links) == 25
    assert Enum.at(rail.links, 17).square["id"] == "steeling-letter-18"
    assert Enum.at(rail.links, 18).curved == "inscription-letter-19"
    assert rail.ribbon.twist_range == [17.5, 18.5]
    assert rail.ribbon.appointed_handedness == nil
  end

  test "A04 aperture and nested U are exact source witnesses; rigid pivot preserves lengths" do
    alias PublicSituationMachineTurnZero.Workshop
    registry = Workshop.Calibration.registry(Workshop.Calibration.new(), Workshop.new())
    source = Enum.find(registry["items"], &(&1["id"] == "flat-aperture"))
    aperture = M.aperture()
    assert aperture.source_points == source["points"]
    assert Enum.take(aperture.source_points, 2) == registry["toe_points"]

    for [a, b] <-
          Enum.chunk_every(aperture.source_points ++ [hd(aperture.source_points)], 2, 1, :discard) do
      {:ok, aa} = M.transform(a, "steeling-u13-to-motor-v1")
      {:ok, bb} = M.transform(b, "steeling-u13-to-motor-v1")
      assert_in_delta M.distance(a, b), M.distance(aa, bb), 1.0e-10
    end

    crossing = M.crossing()

    for {id, source_id} <- [{"u-outer", "u-aperture"}, {"u-within-u", "bobbining-enclosure"}] do
      object = Enum.find(crossing.objects, &(&1.id == id))
      original = Enum.find(registry["items"], &(&1["id"] == source_id))
      assert object.source_points == original["points"]
    end

    assert crossing.ray_hit == registry["projection_thing"]["center"]
    assert crossing.optical_curvature == :unproved
    assert aperture.curvature == :not_created_by_rigid_pivot
  end

  test "all Regarding changes preserve world material, appointments and retained doors" do
    motor = PairedMotor.new()
    {:ok, motor} = PairedMotor.operate(motor, 0, :ground)
    {:ok, motor} = PairedMotor.operate(motor, 1, :pending_un_buttoning)
    {:ok, motor} = PairedMotor.operate(motor, 2, {:progress, 1.0})
    {:ok, motor} = PairedMotor.operate(motor, 3, :furnish_return)
    {:ok, motor} = PairedMotor.operate(motor, 4, :next)
    {:ok, motor} = PairedMotor.operate(motor, 5, :ground)
    s = M.new()
    {:ok, s} = M.operate(s, 0, {:appoint, "SIX", "My curvature reference"})
    model = M.model(s, motor, "cargo-1")
    assert length(model.footings) == 2

    assert Enum.map(model.footings, & &1.door_id) == [
             "trial-footing-1:entrance",
             "trial-footing-2:entrance"
           ]

    for f <- model.footings do
      assert f.ground == :rehearsed
      refute f.constitutional?
      assert hd(f.entrance) == Enum.at(f.entrance, 2)
    end

    for view <- M.views() do
      {:ok, changed} = M.operate(s, s.revision, {:view, view})
      next = M.model(changed, motor, "cargo-1")
      assert next == model
      assert changed.appointments == s.appointments
    end

    refute M.project(hd(model.pieces).vertices, "flat") ==
             M.project(hd(model.pieces).vertices, "gallery")

    assert model.acquired_turns == 0
    assert_in_delta M.distance(hd(model.bar), List.last(model.bar)), 1, 1.0e-9
    assert length(model.gauges) == 6
    assert Enum.map(Enum.take(model.gauges, 3), & &1.radius) == [1.0, 1.5, 2.0]
    assert Enum.all?(model.gauges, &(&1.role == :reference_not_trajectory))
  end
end
