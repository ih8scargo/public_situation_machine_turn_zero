defmodule PublicSituationMachineTurnZero.RoomToyBoxTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomToyBox,
    CoBuilding,
    CoBuildingGeometry,
    MaterialRibbon
  }

  alias RoomToyBox, as: T
  alias CoBuilding, as: C
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M
  defp part(m, id), do: Enum.find(m.pieces, &(&1.id == id))

  test "common SIX frame contains fixed occupied Seat/Table and exposes retained foundations" do
    m = T.model(T.new())
    old = C.model(C.new())
    assert m.frame.minimum == [1.5, 0, -5.5] and m.frame.maximum == [7.5, 6, 0.5]
    assert m.one == old.one and m.three == old.three and m.zero == old.zero

    for id <- ~w(cb:seat cb:seat-back cb:table cb:square-axle cb:pivot-one cb:pivot-three) do
      p = part(m, id)
      assert p.source_geometry == C.selected(old, id).source_geometry
      assert Enum.all?(p.geometry.vertices, &T.inside?/1)
    end

    assert Enum.all?(m.containment, &(&1.all_inside or &1.only_subfloor_exception))
    refute Enum.find(m.containment, &(&1.id == "cb:zero")).all_inside
    assert part(m, "cb:square-axle").material_office =~ "FROM DOWN UNDER"
    assert m.zero_one.axle_identity == "cb:square-axle"
    assert m.zero_one.axle_height_interval == [[3, 0, -3], [3, 1, -3]]
    assert m.zero_one.root_to_axle_offset == [0, 0, -1]
    assert part(m, "cb:pivot-one").bearing.pivot == %{origin: [3, 1, -3], axis: [0, 1, 0]}
    assert part(m, "cb:pivot-three").bearing.pivot == %{origin: [6, 3, -2], axis: [0, 1, 0]}
    ground = part(m, "cb:ground-side")
    field = part(m, "cb:field-side")
    refute ground.source_identity == field.source_identity
    refute ground.lines == field.lines
    assert ground.evidence.source_plane_normal == [0, 1, 0]
    assert field.evidence.source_plane_normal == [0, -1, 0]
  end

  test "finite through-bearing retains opposite corners and clears fixed supports" do
    m = T.model(T.new())
    b = part(m, "room:body-bearing")
    assert Enum.all?(b.geometry.vertices, &T.inside?/1)
    assert m.body_bearing.delta == [6, 6, 6]
    assert_in_delta m.body_bearing.length, 6 * :math.sqrt(3), 1.0e-9
    assert_in_delta m.body_bearing.elevation, 35.264389682754654, 1.0e-9
    assert Enum.all?(m.bearing_clearance, fn {_, hit} -> not hit end)
    camera = T.camera(%{T.new() | view: "flat"}, m)
    [a, b] = Enum.map(m.body_bearing.endpoints, &T.project(&1, camera))
    assert_in_delta abs(Enum.at(b, 0) - Enum.at(a, 0)), abs(Enum.at(b, 1) - Enum.at(a, 1)), 1.0e-9

    assert C.selected(C.model(C.new()), "cb:global-A").source_coordinates == [
             [0, 0, 0],
             [6, 6, 0]
           ]
  end

  test "continuous ribbon passes below the unchanged axle with fixed finite sections and localized half twist" do
    m = T.model(T.new())
    r = m.ribbon
    assert Enum.all?(m.clearance, fn {_, hit} -> not hit end)
    assert Enum.at(r.points, r.under_post_index) == [3, -0.28, -3]
    assert Enum.at(r.geometry.sections, r.under_post_index) |> Enum.all?(&(Enum.at(&1, 1) < 0))
    assert length(r.geometry.cells) == length(r.points) - 1
    assert Enum.map(m.passage_incidence, & &1.count) == [4, 4]

    assert Enum.all?(
             m.passage_incidence,
             &(&1.door == "gallery-door:1" and &1.four_point_furnishing == :unproved)
           )

    for section <- r.geometry.sections do
      [a, b, c, _] = section
      assert_in_delta M.distance(a, b), 0.12, 1.0e-9
      assert_in_delta M.distance(b, c), 0.02, 1.0e-9
    end

    for f <- r.frames do
      assert_in_delta M.norm(f.tangent), 1, 1.0e-9
      assert_in_delta M.norm(f.u), 1, 1.0e-9
      assert_in_delta M.norm(f.v), 1, 1.0e-9
      assert_in_delta M.dot(f.tangent, f.u), 0, 1.0e-9
    end

    [first, last] = r.twist_interval
    assert last - first == 24
    assert Enum.at(r.frames, first).roll_degrees == 0
    assert_in_delta Enum.at(r.frames, last).roll_degrees, 180, 1.0e-9
    assert_in_delta M.dot(r.tail_normal, [0, 1, 0]), 1, 1.0e-9
    [a, b] = Enum.take(r.points, -2)
    [dx, dy, dz] = M.sub(b, a)
    assert_in_delta abs(dx), abs(dz), 1.0e-9
    assert dy == 0
  end

  test "same M source stays rigid along material and displays UP without moving returned stock" do
    base = T.model(T.new())
    source = part(base, "room:M").source_geometry

    for t <- [0.0, 0.2, 0.6, 0.9, 1.0] do
      m = T.model(%{T.new() | travel: t})
      p = part(m, "room:M")
      assert p.source_identity == "room-ribbon:1/M"
      assert p.source_geometry == source

      for {a, pa} <- Enum.zip(source.vertices, p.geometry.vertices),
          {b, pb} <- Enum.zip(source.vertices, p.geometry.vertices) do
        assert_in_delta M.distance(a, b), M.distance(pa, pb), 1.0e-8
      end
    end

    down = T.model(%{T.new() | travel: 1.0})
    up = T.model(%{T.new() | travel: 1.0, projection?: true})
    assert part(up, "room:M").geometry == part(down, "room:M").geometry
    ys = Enum.map(part(down, "room:M").geometry.vertices, &Enum.at(&1, 1))
    assert Enum.max(ys) - Enum.min(ys) < 0.013
    ys = Enum.map(part(up, "room:M").display_geometry.vertices, &Enum.at(&1, 1))
    assert Enum.max(ys) - Enum.min(ys) > 0.4
    assert part(up, "room:M").evidence.parent_material == down.ribbon.id
  end

  test "nested U and all stands bind source material; FIVE goes THROUGH FOUR toward THREE" do
    m = T.model(T.new())
    assert Enum.all?(m.stands, fn stand -> stand.kind in [:standing_stand, :regarding_stand] end)
    four = Enum.find(m.stands, &(&1.id == "FOUR"))
    assert four.measurement_law == :yellow
    assert Enum.any?(part(m, "room:inner-u").lines |> hd(), &(M.distance(&1, m.four) < 1.0e-9))
    a = M.unit(M.sub(m.four, m.five))
    b = M.unit(M.sub(m.three, m.four))
    assert_in_delta M.dot(a, b), 1, 1.0e-9
    two = T.camera(%{T.new() | view: "two"}, m)
    five = T.camera(%{T.new() | view: "five"}, m)
    assert_in_delta M.dot(two.forward, five.forward), -1, 1.0e-9
    assert G.ray(five.eye, five.forward, part(m, "room:inner-u").geometry.faces) != nil
    within = part(m, "room:within-u").evidence
    assert_in_delta M.dot(within.direction, within.tangent), :math.sqrt(0.5), 1.0e-9
    assert part(m, "room:segmentation").evidence.physical_transform == nil
    assert :SIXTH_EIGHTH_physical_join in m.stopped_portions
  end

  test "every piece/control has an office and views cannot acquire or replace material" do
    s = T.new()
    base = T.model(s)

    required =
      ~w(source_identity material_office standing_locality bearing attachment inheritance affordment regarding status evidence)a

    assert Enum.all?(base.pieces, fn p -> Enum.all?(required, &Map.has_key?(p, &1)) end)
    assert Enum.all?(T.controls(), &(&1.office != ""))

    for view <- T.views() do
      n = T.model(%{s | view: view})

      assert Enum.map(n.pieces, &{&1.id, &1.content_hash}) ==
               Enum.map(base.pieces, &{&1.id, &1.content_hash})

      assert n.acquisition == base.acquisition
      assert T.camera(%{s | view: view}, n).human_seat == base.one
    end

    assert length(Enum.filter(base.pieces, &(&1.source_identity == "room-ribbon:1/M"))) == 1
  end

  test "ordered PINNING rehearsals preserve separate constitutional purchases and stale guards" do
    s = T.new()
    assert {:error, :preceding_hold_required} = T.change(s, 0, {:pin, 2})
    {:ok, a} = T.change(s, 0, {:pin, 1})
    {:ok, b} = T.change(a, 1, {:pin, 2})
    {:ok, c} = T.change(b, 2, {:pin, 3})
    assert c.pins == [1, 2, 3]
    assert T.model(c).pins |> Enum.at(1) |> Map.fetch!(:locality) == [6, 3, -2]
    assert T.model(c).acquisition.index_delta == 0
    assert {:error, :stale} = T.change(c, 0, {:pin, 3})

    for cmd <- [:pittoning, :puffing, :re_step, :pending_un_buttoning, :acquire_next] do
      assert {:error, :constitutional_means_not_furnished} = T.change(c, 3, cmd)
    end

    assert Enum.all?(c.events, &(&1.acquired_delta == 0))
  end
end
