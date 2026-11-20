defmodule PublicSituationMachineTurnZero.Workshop.LayeringZeroOpening do
  @moduledoc "Opening-slice and reciprocal Regarding specimens in the Layering ZERO registry."
  alias PublicSituationMachineTurnZero.Architecture.InscriptionResolution

  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuildingGeometry,
    GeometryExploration,
    MaterialRibbon,
    OpeningSliceProjection,
    RoomToyBox
  }

  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def build(center, seat) do
    a = Enum.find(GeometryExploration.references(), &(&1.id == "diagonal-A"))
    [from, toward] = a.points
    inherited = M.distance(from, toward)
    half = M.scale(M.add(from, toward), 0.5)
    offset = M.sub(center, [hd(half), 0, List.last(half)])
    midpoint = M.add(half, offset)
    bearing = Enum.map(a.points, &M.add(&1, offset))
    outward = M.add(center, [inherited, 0, 0])
    next = M.add(outward, [1, 1, 0])

    resolved_bow =
      for {t, residual} <- chart_residuals() do
        M.add(M.add(center, [inherited * t, 0, 0]), M.scale(residual, inherited))
      end

    letters = InscriptionResolution.model()["letters"]
    doors = for i <- 0..7, do: door(center, i)

    pieces =
      Enum.flat_map(doors, & &1.pieces) ++
        [
          piece("bowstring:seat", "Seat → DOWN UNDER XT registration", "bow",
            paths: [[seat, center]]
          ),
          piece("bowstring:out", "Inherited-measure rehearsal · straight OUT", "bow",
            faces:
              G.box(M.add(center, [0, -0.018, -0.018]), M.add(outward, [0, 0.018, 0.018])).faces,
            paths: [[center, outward]]
          ),
          piece("bowstring:regarding", "Bowstring · reciprocal chart image", "bow-image",
            paths: [resolved_bow]
          ),
          piece("bowstring:next", "Prospective ONE UP and ONE OUT", "bow",
            paths: [[outward, next]]
          ),
          piece("footing:halfway-bearing", "R31–R36 halfway bearing", "halfway",
            paths: [bearing, [midpoint]]
          ),
          piece("footing:upright", "First Footing · Groundward upright specimen", "upright",
            faces:
              G.box(M.add(center, [-0.12, 0, -0.36]), M.add(midpoint, [0.12, 0.04, -0.20])).faces,
            paths: [[center, midpoint]]
          )
        ] ++ cages(letters, outward) ++ u_references()

    %{
      doors: Enum.map(doors, &Map.delete(&1, :pieces)),
      pieces: pieces,
      bowstring: %{
        source: a.id,
        edge: center,
        seat: seat,
        outward: outward,
        next: next,
        measure: inherited,
        chart: OpeningSliceProjection.contract(),
        prior_completed_source: nil
      },
      midpoint: midpoint,
      bearing: bearing,
      inscription: %{
        source: "inscription-resolution-v1",
        segments: [3, 6, 9, 7],
        return_between: ["inscription-letter-18", "inscription-letter-19"]
      }
    }
  end

  defp door(center, ordinal) do
    id = "gallery-door:#{ordinal + 1}"
    angle = ordinal * :math.pi() / 4
    radial = [:math.cos(angle), 0, :math.sin(angle)]
    tangent = [-:math.sin(angle), 0, :math.cos(angle)]

    pose = fn [x, y, z] ->
      M.add(center, M.add(M.scale(radial, x), M.add([0, y, 0], M.scale(tangent, z))))
    end

    original = Enum.map([[1.34, 0.62, -0.19], [1.34, 0.62, 0.19]], pose)
    furnished = Enum.map([[1.48, 0.62, 0.19], [2.02, 0.97, 0.42]], pose)

    square =
      Enum.map(
        [[1.34, 0.32, -0.30], [1.34, 0.92, -0.30], [1.34, 0.92, 0.30], [1.34, 0.32, 0.30]],
        pose
      )

    floor =
      for j <- 0..8 do
        a = angle + (j / 8 - 0.5) * :math.pi() / 4
        M.add(center, [1.5 * :math.cos(a), -0.32, 1.5 * :math.sin(a)])
      end

    [a, b] = original
    [c, d] = furnished

    chart = fn sign ->
      for {t, residual} <- chart_residuals() do
        bend = M.scale(tangent, sign * 2 * M.norm(residual))
        M.add(M.add(c, M.scale(M.sub(d, c), t)), bend)
      end
    end

    hold_end = M.add(c, M.scale(M.unit(M.sub(d, c)), 0.075))
    hold = G.pipe([c, hold_end], 0.075, 0.05, 8)

    variants =
      for {sign, hand} <- [{1, "positive"}, {-1, "negative"}], into: %{} do
        curve = chart.(sign)
        tube = G.sweep(curve, 0.12, 0.034)

        {hand,
         {curve,
          piece("#{id}:#{hand}", "Transverse ribbon · #{hand} trial", "resolution",
            faces: tube.faces,
            paths: [curve]
          )}}
      end

    %{
      id: id,
      string: "#{id}/string:1",
      points: %{beginning: a, end: b, furnished_beginning: c, furnished_end: d},
      endpoints:
        for(
          name <- ~w(beginning end furnished_beginning furnished_end),
          do: "#{id}/string:1/#{name}"
        ),
      principal: square,
      ground: floor,
      upper_seam: Enum.map([hd(floor), List.last(floor)], &M.add(&1, [0, 0.67, 0])),
      origins: %{gallery: pose.([1.34, 0.62, 0]), transverse: pose.([1.7, 0.7, 0.3])},
      passage_bounds_local: [[1.4, 0.49, -0.27], [2.16, 1.10, 0.63]],
      curves: Map.new(variants, fn {hand, {curve, _}} -> {hand, curve} end),
      pieces:
        [
          piece("#{id}:principal", "Principal wedge · STAGING FOR STAGING", "principal",
            faces: [square]
          ),
          piece("#{id}:passage", "Oblique transverse region · trial envelope", "passage",
            paths:
              G.box([1.4, 0.49, -0.27], [2.16, 1.10, 0.63]).faces
              |> Enum.map(fn face -> Enum.map(face ++ [hd(face)], pose) end)
          ),
          piece("#{id}:four-points", "String · four registered opening points", "slice",
            paths: [[a, b], [a, c], [b, d], [c, d], [a], [b], [c], [d]]
          ),
          piece("#{id}:ground", "Groundward Segmentationing #{ordinal + 1}", "ground",
            faces:
              for(
                {[u, v], i} <- floor |> Enum.chunk_every(2, 1, :discard) |> Enum.with_index(),
                phase = rem(ordinal * 8 + i + 60, 64),
                phase not in 16..31 and phase not in 48..55,
                do: [u, v, floor_inner(v, center), floor_inner(u, center)]
              ),
            paths: [floor]
          ),
          piece("#{id}:ft", "FT COB · ribbon offered through appointed hold", "ft",
            faces: G.sweep([c, d], 0.08, 0.024).faces,
            paths: [[c], [c, d]]
          ),
          piece("#{id}:ft-hold", "FT COB · hollow hold around straight ribbon", "ft",
            faces: hold.faces
          ),
          piece("#{id}:tf", "TF COB · return alignment at received ribbon", "tf",
            faces: G.sweep(Enum.reverse(elem(variants["positive"], 0)), 0.08, 0.024).faces,
            paths: [Enum.reverse(elem(variants["positive"], 0)), [c]]
          )
        ] ++ Enum.map(variants, fn {_, {_, body}} -> body end)
    }
  end

  defp chart_residuals do
    origin = OpeningSliceProjection.resolve_point(0, [-0.5, 0, 0])
    span = M.sub(OpeningSliceProjection.resolve_point(0, [0.5, 0, 0]), origin)

    for i <- 0..16 do
      t = i / 16
      sample = OpeningSliceProjection.resolve_point(0, [t - 0.5, 0, 0])
      {t, M.sub(M.sub(sample, origin), M.scale(span, t))}
    end
  end

  defp floor_inner([x, y, z], [cx, _, cz]),
    do: [cx + (x - cx) * 0.88, y, cz + (z - cz) * 0.88]

  defp u_references do
    RoomToyBox.model(RoomToyBox.new()).pieces
    |> Enum.filter(&(&1.id in ~w(room:inner-u room:outer-u room:within-u)))
    |> Enum.map(&piece(&1.id, &1.id, "u", faces: &1.source_geometry.faces, paths: &1.lines))
  end

  defp cages(letters, start) do
    for %{"id" => id, "index" => index, "letter" => glyph} <- letters do
      x = index - 1 + if(index > 18, do: 1, else: 0)
      lower = M.add(start, [x, -0.5, -0.5])
      upper = M.add(lower, [1, 1, 1])
      piece(id, "#{index} · #{glyph} CUBICAL cage", "cage", faces: G.box(lower, upper).faces)
    end
  end

  defp piece(id, label, kind, opts) do
    %{id: id, label: label, kind: kind, faces: opts[:faces] || [], paths: opts[:paths] || []}
  end
end
