defmodule PublicSituationMachineTurnZero.CoBuildingTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuilding,
    CoBuildingGeometry,
    HereWedging,
    MaterialRibbon
  }

  alias CoBuilding, as: C
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  defp step(s, cmd) do
    {:ok, n} = C.change(s, s.revision, cmd)
    n
  end

  defp part(m, id), do: C.selected(m, "cb:" <> id)

  test "placement retains inherited Seat, fixed SIX and source global diagonals" do
    m = C.model(C.new())
    assert m.one == HereWedging.model().seat_point
    assert m.frame.measure == [6, 6, 6]
    assert length(part(m, "EIGHT").regions) == 8
    refute m.clearance.return_to_zero_interference

    assert C.camera(%{C.new() | view: "tunneling", yaw: 0}).eye ==
             C.camera(%{C.new() | view: "tunneling", yaw: 180}).eye

    assert m.frame.translation == m.zero
    assert part(m, "global-A").source_coordinates == [[0, 0, 0], [6, 6, 0]]
    assert part(m, "global-B").source_coordinates == [[0, 6, 0], [6, 0, 0]]
    assert m.zero != m.three
    assert_in_delta M.distance(hd(m.unit), List.last(m.unit)), 1, 1.0e-10
    assert part(m, "leverage").length == :math.sqrt(2)
    assert length(Enum.filter(m.parts, &String.starts_with?(&1.id, "cb:quadranglement-"))) == 4

    for p <- Enum.filter(m.parts, &String.starts_with?(&1.id, "cb:quadranglement-")),
        do: assert(length(p.geometry.faces) == 6)
  end

  test "stable ZERO bore remains hollow and distinct from THREE during all poses" do
    s = C.new()
    source = part(C.model(s), "zero")

    for view <- C.views() do
      state = s |> step({:view, view}) |> step({:door, 47.5}) |> step({:layer, 0})
      assert part(C.model(state), "zero").geometry == source.geometry
      assert part(C.model(state), "zero").id == source.id
    end

    assert G.ray([3.3, -0.5, -2], [0, 1, 0], source.geometry.faces) == nil
    assert is_number(G.ray([3.5, -0.5, -2], [0, 1, 0], source.geometry.faces))
    m = C.model(s)
    refute m.clearance.zero_leverage_to_bore
    refute m.clearance.wedge_to_cylinder
    assert m.clearance.axle_radial_margin > 0
  end

  test "finite right-angle wedge stocks have a clipped, non-interpenetrating miter" do
    m = C.model(C.new())
    a = part(m, "wedge-A")
    b = part(m, "wedge-B")
    assert M.dot(a.plane_normal, b.plane_normal) == 0
    refute G.collision?(a.geometry, b.geometry)
    assert m.clearance.wedge_miter_contact_area > 0

    assert Enum.any?(a.geometry.vertices, fn p ->
             Enum.any?(b.geometry.vertices, &(M.distance(p, &1) < 1.0e-8))
           end)

    assert a.geometry.faces != [] and b.geometry.faces != []
    assert a.closed_physical_join == false
    assert part(m, "segmentation").status == :yellow
    assert :root_attachment in part(m, "segmentation").yellow
  end

  test "one R swings into depth without ascent while real monitor stays fixed" do
    base = C.model(C.new())
    r = part(base, "R")

    for angle <- [0.0, 22.5, 45.0, 90.0] do
      s = C.new() |> step({:view, "flat"}) |> step({:door, angle})
      m = C.model(s)
      new = part(m, "R")
      assert new.source_letter == "specimen:R:1"
      assert new.source_hash == r.source_hash
      assert part(m, "monitor").geometry == part(base, "monitor").geometry

      assert Enum.zip_with(r.geometry.vertices, new.geometry.vertices, fn a, b ->
               abs(Enum.at(a, 1) - Enum.at(b, 1))
             end)
             |> Enum.all?(&(&1 < 1.0e-10))

      assert_in_delta M.distance(hd(r.geometry.vertices), List.last(r.geometry.vertices)),
                      M.distance(hd(new.geometry.vertices), List.last(new.geometry.vertices)),
                      1.0e-9

      assert Enum.count(m.parts, &(&1.source_id == "cb:R")) == 1
      if angle == 90, do: assert(C.visibility(new, s, m) == :edge_on)
    end

    m = C.model(C.new() |> step({:door, 45}))
    assert Enum.max(Enum.map(part(m, "R").geometry.vertices, &Enum.at(&1, 2))) > -1
  end

  test "wedge trial reveals interference without replacing its registered source fit" do
    base = C.model(C.new())
    s = C.new() |> step({:wedge, 90.0})
    m = C.model(s)
    assert part(m, "wedge-B").source_geometry == part(base, "wedge-B").source_geometry
    assert part(m, "wedge-B").geometry != part(base, "wedge-B").geometry
    assert m.clearance.wedge_trial_interference
    refute m.clearance.wedge_miter_interference
    assert C.source_digest(m) == C.source_digest(base)
    assert m.acquisition == base.acquisition
  end

  test "tracing, road appointment and two Toe rehearsal keep actual stitching false" do
    assert {:error, _} = C.change(C.new(), 0, :stitch)
    s = C.new() |> step({:trace, "R"}) |> step({:r_pose, "road"}) |> step(:stitch)
    m = C.model(s)
    assert Enum.count(m.parts, &String.starts_with?(&1.id, "cb:R-toe-")) == 2
    assert part(m, "R").material_source == "cb:inkwell"
    assert part(m, "R").actual_stitching == false
    # A road appointment preserves finite stock thickness and every pairwise distance.
    source = part(m, "R").source_geometry.vertices
    posed = part(m, "R").geometry.vertices

    for {a, pa} <- Enum.zip(source, posed), {b, pb} <- Enum.zip(source, posed) do
      assert_in_delta M.distance(a, b), M.distance(pa, pb), 1.0e-9
    end

    assert part(m, "R").group == "office-road"
    assert part(m, "standing-material").office =~ "STANDING FOR STAGING"
    assert length(Enum.uniq(m.material_sources)) == 3
    assert m.tools == ["cb:quilling-needle"]
    assert m.acquisition.actual_pittoning == nil
  end

  test "regarding, isolate and earlier construction layers preserve source standing" do
    s = C.new()
    m = C.model(s)
    hash = C.source_digest(m)

    for view <- C.views() do
      n =
        s
        |> step({:view, view})
        |> step({:yaw, 22.5})
        |> step(:park_view)
        |> step({:yaw, 90})
        |> step(:restore_view)
        |> step({:layer, 0})
        |> step(:isolate)

      assert n.yaw == 22.5
      assert C.source_digest(C.model(n)) == hash
      assert Enum.all?(n.trace, &(&1.acquired_delta == 0))
      assert C.model(n).acquisition == m.acquisition
    end
  end

  test "prospective return goes behind the same Seat; next fold is one local extent ahead" do
    m = C.model(C.new())
    path = part(m, "tail-return").points
    assert Enum.min(Enum.map(path, &Enum.at(&1, 2))) < Enum.at(m.one, 2)
    assert Enum.max(Enum.map(path, &Enum.at(&1, 2))) > Enum.at(m.one, 2)
    [next, _] = part(m, "next-fold").points
    assert Enum.at(next, 1) - Enum.at(m.three, 1) == 1
    assert part(m, "pinning-reference").length == 3
    assert m.pending.next_origin == nil
    assert m.clearance.return_join_gap == 0
    refute m.clearance.return_join_certified
    assert :finite_twist_law in part(m, "tail-return").yellow
    assert m.frame.measure == [6, 6, 6]
  end

  test "Gallery course shares finite sections from below Seat through upper loop to flat PINNING" do
    m = C.model(C.new())
    course = m.gallery_course
    under = part(m, "under-curve")
    assert Enum.all?(course.undercurve.points, fn [x, y, _] -> x == 3 and y < 1 end)
    assert Enum.max(Enum.map(under.geometry.vertices, &Enum.at(&1, 1))) < 1
    assert hd(course.points) == [1.4, -0.35, -3]
    ids = ~w(under-curve gallery-through gallery-departure upper-loop around-course)
    segments = Enum.map(ids, &part(m, &1))

    for [a, b] <- Enum.chunk_every(segments, 2, 1, :discard) do
      assert_in_delta M.distance(List.last(a.points), hd(b.points)), 0, 1.0e-9
      assert List.last(a.geometry.sections) == hd(b.geometry.sections)
      assert a.course_id == b.course_id
    end

    [a, b] = part(m, "gallery-departure").points
    [dx, dy, dz] = M.sub(b, a)
    assert_in_delta dx, dy, 1.0e-9
    assert dz == 0
    loop = part(m, "upper-loop")
    assert hd(loop.points) == List.last(loop.points)

    for p <- loop.points do
      assert_in_delta M.distance(p, course.upper_loop.center), 0.3, 1.0e-9
    end

    assert M.dot(course.upper_loop.tangent_at_entry, course.upper_loop.transverse_reference) == 0
    pin = part(m, "next-fold")
    assert pin.flat
    assert pin.plane_normal == [0, 1, 0]
    assert Enum.all?(pin.points, &(Enum.at(&1, 1) == 4))
    assert_in_delta M.distance(hd(pin.points), List.last(pin.points)), 1, 1.0e-9
    assert pin.appointment_offset == [1, 1, 0]
    assert List.last(course.points) == hd(pin.points)
    refute m.clearance.course_to_aperture_interference
    assert m.clearance.loop_to_departure_interference
    assert m.material_lifecycle.acquired_next_footing == nil
    assert part(m, "subsequent-up").lifecycle == :subsequent_material
    assert part(m, "stage-door").opens_from == "cb:slate"
  end

  test "all seven inspection stages and three undercurve Regardings preserve source and acquisition" do
    base = C.model(C.new())
    hash = C.source_digest(base)

    for n <- 1..7 do
      s = C.new() |> step({:course_stage, n})
      assert C.source_digest(C.model(s)) == hash
      assert C.model(s).acquisition == base.acquisition
      if n == 2, do: assert(C.visibility(part(C.model(s), "R"), s, C.model(s)) == :edge_on)
    end

    for v <- ~w(flat side tunneling-under) do
      s = C.new() |> step({:course_stage, 3}) |> step({:view, v})
      under = part(C.model(s), "under-curve")
      assert C.visible?(under, s)
      assert under.source_hash == part(base, "under-curve").source_hash
    end
  end

  test "projected M keeps physical source while changing only its outreading" do
    before = C.model(C.new())
    s = C.new() |> step(:m_projection)
    after_model = C.model(s)
    assert part(before, "terminal-M").geometry == part(after_model, "terminal-M").geometry
    assert part(after_model, "terminal-M").projection_only

    assert part(after_model, "terminal-M").display_geometry !=
             part(after_model, "terminal-M").geometry

    assert C.source_digest(before) == C.source_digest(after_model)
  end

  test "compound transform carries collision cells and closed Gallery sections stay joined mathematically" do
    tube = G.pipe([[0, 0, 0], [0, 1, 0]], 0.2, 0.1, 8)
    moved = G.translate(tube, [5, 0, 0])
    assert Enum.all?(Enum.flat_map(moved.cells, & &1.vertices), &(hd(&1) > 4.7))
    pipe = part(C.model(C.new()), "yt-pipe").geometry
    m = C.model(C.new())
    adapter = part(m, "globe-adapter").geometry
    refute G.collision?(adapter, part(m, "globe").geometry)
    refute G.collision?(adapter, part(m, "pivot-three").geometry)

    assert Enum.zip_with(hd(pipe.sections), List.last(pipe.sections), &M.distance/2)
           |> Enum.all?(&(&1 < 1.0e-9))
  end

  test "stale commands and consequential operations cannot acquire or mutate rehearsal" do
    s = C.new()
    assert {:error, :stale} = C.change(s, 1, {:door, 90})

    for cmd <- [:re_step, :re_stomp, :pittoning, :land, :acquire_next, :fulfill_condition] do
      assert {:error, _} = C.change(s, 0, cmd)
    end

    assert {:error, _} = C.change(s, 0, {:trace, "NOT R"})

    assert C.model(s).acquisition == %{
             delta: 0,
             actual_next_footing: nil,
             actual_pittoning: nil,
             actual_stitching: false,
             completed_re_step: false,
             actual_cob_traversaling: nil
           }
  end
end
