defmodule PublicSituationMachineTurnZero.LetterTransformInspectionTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomFromHere,
    LetterTransformInspection,
    MaterialRibbon
  }

  alias MaterialRibbon, as: M

  setup_all do
    s = RoomFromHere.new()
    m = RoomFromHere.model(s)
    {:ok, s: s, m: m}
  end

  defp part(m, id), do: Enum.find(m.pieces, &(&1.id == id))

  test "T1 changes observer and Door independently while the same source R retains material pose",
       %{s: s, m: m} do
    {:ok, a} = RoomFromHere.change(s, 0, {:letter_inspection, :activate})
    {:ok, b} = RoomFromHere.change(a, a.revision, {:letter_bearing, 90.0})
    {:ok, c} = RoomFromHere.change(b, b.revision, {:letter_door, 90.0})
    am = RoomFromHere.model(a)
    bm = RoomFromHere.model(b)
    cm = RoomFromHere.model(c)

    for n <- [am, bm, cm] do
      assert part(n, "doorway:letter-R").geometry == part(am, "doorway:letter-R").geometry
      assert n.source_digest == m.source_digest and n.frame == m.frame
      assert Enum.count(n.pieces, &(&1.id == "doorway:letter-R")) == 1
    end

    refute RoomFromHere.camera(a, am).eye == RoomFromHere.camera(b, bm).eye
    refute part(am, "doorway:stage-leaf").geometry == part(cm, "doorway:stage-leaf").geometry
    glyph = part(m, "room:R").source_geometry
    offset = am.letter_inspection.toe.unit_embedding_translation
    position = am.letter_inspection.material_pose.origin
    points = Enum.map(glyph.vertices, &M.add(M.add(&1, offset), position))

    width = fn state, model ->
      xs =
        Enum.map(points, fn p ->
          hd(RoomFromHere.project(p, RoomFromHere.camera(state, model)))
        end)

      Enum.max(xs) - Enum.min(xs)
    end

    assert width.(b, bm) < 0.03 * width.(a, am)
    assert am.letter_inspection.toe.world_point == cm.letter_inspection.toe.world_point
    refute Map.fetch!(am.letter_inspection.issuing, :Door_leaf_clear_to_target)
    assert Map.fetch!(cm.letter_inspection.issuing, :Door_leaf_clear_to_target)
  end

  test "T2 rigid frame transport samples the actual U and preserves every source vertex and allocation",
       %{s: s, m: m} do
    source = part(m, "doorway:letter-R").source_geometry

    for t <- [0.0, 0.25, 0.5, 0.75, 1.0] do
      state = %{
        s
        | letter_inspection: %{LetterTransformInspection.new() | active: true, curvature: t}
      }

      n = RoomFromHere.model(state)
      r = n.letter_inspection
      assert r.allocation.measure == [1, 1, 1] and r.allocation.inside_ROOM
      assert n.source_digest == m.source_digest and n.frame == m.frame

      for {a, b} <- Enum.zip(source.vertices, part(n, "doorway:letter-R").geometry.vertices) do
        relative = M.sub(b, r.material_pose.origin)

        inverse =
          PublicSituationMachineTurnZero.Workshop.RoomRibbon.rotate(
            relative,
            [0, 0, 1],
            -r.material_pose.degrees * :math.pi() / 180
          )

        assert M.distance(a, inverse) < 1.0e-10
      end

      for p <- m.pieces, do: assert(part(n, p.id).source_geometry == p.source_geometry)
      assert r.curvature.source == "doorway:inner-u"
      assert r.curvature.local_discrete_curvature > 0
      assert r.gate.actual_curvature_standing == false
    end

    a =
      RoomFromHere.model(%{
        s
        | letter_inspection: %{LetterTransformInspection.new() | active: true}
      })

    b =
      RoomFromHere.model(%{
        s
        | letter_inspection: %{LetterTransformInspection.new() | active: true, curvature: 0.5}
      })

    refute a.letter_inspection.material_pose == b.letter_inspection.material_pose

    assert Map.fetch!(a.letter_inspection, :Regarding) ==
             Map.fetch!(b.letter_inspection, :Regarding)
  end

  test "leading toe is the original finite stroke end-cap and issues a traceable TOWARD relation",
       %{m: m} do
    r = m.letter_inspection
    assert M.distance(r.toe.source_point, [3.26, 2.05, -1.04]) < 1.0e-10

    assert r.toe.source_face ==
             Enum.at(part(m, "room:R").source_geometry.faces, r.toe.source_face_index)

    assert r.issuing.origin == r.toe.world_point
    assert r.issuing.target == m.frame.maximum
    assert r.issuing.ordered_prepositioning == ["FROM", "THROUGH", "TOWARD"]
    assert Map.fetch!(r.issuing, :Stage_plane_incidence).inside_opening
    assert Map.fetch!(r.issuing, :PITTONING) == :not_accepted
  end

  test "lawful PUFFING remains blocked for this source pair and normal workflow restores its original pose",
       %{s: s} do
    {:ok, a} = RoomFromHere.change(s, 0, {:letter_curvature, 0.5})

    assert {:error, :unit_letter_puffing_acceptance_unbound} =
             RoomFromHere.change(a, a.revision, {:letter_inspection, :puff})

    assert {:error, :stale} = RoomFromHere.change(a, 0, {:letter_bearing, 90})
    {:ok, b} = RoomFromHere.change(a, a.revision, {:doorway, :trace})
    refute b.letter_inspection.active
    assert RoomFromHere.model(b).acquisition.index_delta == 0
  end
end
