defmodule PublicSituationMachineTurnZero.OpeningSliceProjectionTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomFromHere,
    OpeningSliceProjection,
    SnailBody,
    MaterialRibbon,
    OneCubicalDoorway
  }

  alias OpeningSliceProjection, as: P

  defp step(s, cmd) do
    {:ok, n} = RoomFromHere.change(s, s.revision, cmd)
    n
  end

  defp resolve(s) do
    s
    |> step({:slice_projection, :appoint})
    |> step({:slice_projection, :open})
    |> step({:slice_progress, 1.0})
    |> step({:slice_projection, :resolve})
  end

  defp part(m, id), do: Enum.find(m.pieces, &(&1.id == id))

  test "one compact reservation passes where a resolved unit cannot, then resolves with no acquisition" do
    s = RoomFromHere.new()
    m = RoomFromHere.model(s)

    assert {:error, :one_wedge_predecessor_required} =
             RoomFromHere.change(s, 0, {:slice_projection, :resolve})

    a = step(s, {:slice_projection, :appoint})
    am = RoomFromHere.model(a)
    refute RoomFromHere.visible?(part(am, "doorway:letter-R"), a)
    assert RoomFromHere.visible?(part(am, "projection:opening-slice"), a)

    assert {:error, :one_wedge_predecessor_required} =
             RoomFromHere.change(a, a.revision, {:slice_projection, :appoint})

    b = a |> step({:slice_projection, :open}) |> step({:slice_progress, 0.5})

    assert {:error, :straight_slice_progress_required} =
             RoomFromHere.change(b, b.revision, {:slice_progress, 0.25})

    c = b |> step({:slice_progress, 1.0}) |> step({:slice_projection, :resolve})
    cm = RoomFromHere.model(c)
    assert RoomFromHere.visible?(part(cm, "doorway:letter-R"), c)
    assert cm.acquisition.index_delta == 0
    assert cm.source_digest == m.source_digest
    assert cm.frame == m.frame
    assert {:error, :stale} = RoomFromHere.change(c, 0, {:slice_projection, :next})
    evidence = P.measurements(m)
    assert evidence.resolved_unit_would_hit_compact_insert
    refute evidence.insert_closed_leaf_interference
    refute evidence.insert_leaf_swing_envelope_interference
    assert evidence.insert_frame_attachment
    assert evidence.reservation_sweep_intersections == []
    assert Enum.all?(evidence.resolved_allocations, &(&1.inside_ROOM and &1.intersections == []))
    assert evidence.purchase_unintended_intersections == []
    assert evidence.purchase_wall_incidence
  end

  test "source charts invert, retain unit arclength, and actually curve the same source faces" do
    s = RoomFromHere.new()
    m = RoomFromHere.model(s)

    for i <- 0..3,
        u <- [-0.5, -0.2, 0.0, 0.3, 0.5],
        v <- [-0.5, 0.0, 0.5],
        w <- [-0.5, 0.0, 0.5] do
      q = [u, v, w]
      {:ok, inverse} = P.inverse_point(i, P.resolve_point(i, q))
      assert MaterialRibbon.distance(q, inverse) < 1.0e-8

      assert SnailBody.arc_length() *
               (1 - i / SnailBody.arc_length() - (1 - (i + 1) / SnailBody.arc_length())) >
               0.999999999
    end

    source = part(m, "doorway:letter-R").source_geometry
    result = P.resolve_mesh(source, 0)

    for {f, p} <- Enum.zip(result.geometry.faces, result.provenance) do
      assert p.source_face < length(source.faces)
      assert f == Enum.map(p.parameter_vertices, &P.resolve_point(0, &1))
    end

    a = P.resolve_point(0, [-0.5, 0, 0])
    b = P.resolve_point(0, [0, 0, 0])
    c = P.resolve_point(0, [0.5, 0, 0])
    assert MaterialRibbon.distance(b, MaterialRibbon.scale(MaterialRibbon.add(a, c), 0.5)) > 0.1
    assert P.law().authority == :retained_native_trial_not_revised_coiling_law
  end

  test "all appointments bind unchanged ROOM, source letters and profile, preserve TC bodies and render independently of Regarding" do
    s = RoomFromHere.new()
    m = RoomFromHere.model(s)

    final =
      Enum.reduce(1..4, s, fn _, acc -> resolve(acc) |> step({:slice_projection, :next}) end)

    n = RoomFromHere.model(final)
    assert length(final.opening_projection.resolved) == 4
    assert final.opening_projection.index == 4

    assert {:error, :one_wedge_predecessor_required} =
             RoomFromHere.change(final, final.revision, {:slice_projection, :appoint})

    for r <- final.opening_projection.resolved do
      assert r.law_hash == P.law().hash
      assert Map.fetch!(r, :ROOM_hash) == Map.fetch!(P.context(m), :ROOM_hash)
      assert r.source_hash == part(m, r.source_identity).content_hash
    end

    for p <- m.pieces do
      assert part(n, p.id).source_geometry == p.source_geometry
      assert part(n, p.id).content_hash == p.content_hash
    end

    ports = step(final, {:slice_projection, :ports}) |> RoomFromHere.model()
    assert ports.doorway == m.doorway
    assert ports.source_digest == m.source_digest
    side = step(final, {:view, "oblique"}) |> RoomFromHere.model()

    for id <- ~w(R O1 O2 M) do
      assert part(side, "doorway:letter-" <> id).geometry ==
               part(n, "doorway:letter-" <> id).geometry
    end

    assert n.opening_projection.toe.visible
    toe = n.opening_projection.toe
    assert toe.resolved_point == P.resolve_point(0, toe.source.unit_point)

    assert OneCubicalDoorway.interferes?(
             part(n, "projection:R-resolved-purchase").geometry,
             part(n, "doorway:letter-R").geometry
           )
  end

  test "changed inherited law, ROOM or letter dependency rejects pending resolution" do
    m = RoomFromHere.model(RoomFromHere.new())
    c = P.context(m)
    {:ok, s} = P.change(P.new(), :appoint, c)

    for altered <- [
          %{c | law_hash: "different"},
          Map.put(c, :ROOM_hash, "different"),
          %{c | letter_hashes: Map.put(c.letter_hashes, "R", "different")}
        ] do
      assert {:error, :inherited_projection_binding_changed} = P.change(s, :open, altered)
    end
  end
end
