defmodule PublicSituationMachineTurnZero.Workshop.RoomRibbon do
  @moduledoc "Prospective continuous under-and-around stock; transported finite frames and a localized half twist."
  alias PublicSituationMachineTurnZero.Workshop.{CoBuildingGeometry, MaterialRibbon}
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def rotate(v, axis, a),
    do:
      M.add(
        M.add(M.scale(v, :math.cos(a)), M.scale(M.cross(axis, v), :math.sin(a))),
        M.scale(axis, M.dot(axis, v) * (1 - :math.cos(a)))
      )

  def model(table, u_point) do
    loop =
      for i <- 0..48 do
        a = i * 2 * :math.pi() / 48
        [3 + 1.05 * :math.sin(a), 2.1 - 0.2 * i / 48, -3 + 1.05 * :math.cos(a)]
      end

    prefix =
      [
        [3.55, 2.4, -1.04],
        [3.55, 2.4, -0.55],
        [4.25, 3.1, -0.55],
        M.add(table, [0.25, 0.6, 0]),
        M.add(table, [0.1, 0.15, 0]),
        u_point,
        [4.4, 3.7, -1.7],
        hd(loop)
      ] ++
        tl(loop) ++
        [
          [2.25, 0.55, -2.6],
          [2.25, -0.28, -3],
          [3, -0.28, -3],
          [3.75, -0.28, -3],
          [4.6, 1.3, -0.55],
          [3.55, 1.95, -0.55],
          [3.55, 1.95, -1.7],
          [3.75, 0.35, -3.8]
        ]

    twist_start = length(prefix) - 1
    twist = for i <- 1..24, do: [3.75 - 1.2 * i / 24, 0.35, -3.8]
    points = prefix ++ twist ++ [[2.55, 0.15, -3.75], [2.15, 0.15, -4.15]]
    twist_end = twist_start + 24
    tangents = G.frames(points) |> Enum.map(& &1.tangent)

    {base, _} =
      Enum.map_reduce(tangents, nil, fn t, previous ->
        u =
          case previous do
            nil ->
              G.perpendicular(t)

            %{t: old, u: old_u} ->
              axis = M.cross(old, t)
              n = M.norm(axis)
              dot = max(-1, min(1, M.dot(old, t)))

              if n < 1.0e-9,
                do: old_u,
                else: rotate(old_u, M.scale(axis, 1 / n), :math.atan2(n, dot))
          end

        u = M.unit(M.sub(u, M.scale(t, M.dot(u, t))))
        f = %{t: t, u: u, v: M.cross(t, u)}
        {f, f}
      end)

    last = List.last(base)
    desired = [0, -1, 0]
    gauge = :math.atan2(M.dot(last.t, M.cross(last.v, desired)), M.dot(last.v, desired))

    frames =
      Enum.zip([points, base])
      |> Enum.with_index()
      |> Enum.map(fn {{p, f}, i} ->
        roll = :math.pi() * max(0, min(1, (i - twist_start) / max(1, twist_end - twist_start)))
        u = rotate(f.u, f.t, gauge + roll)
        v = M.cross(f.t, u)

        %{
          point: p,
          tangent: f.t,
          u: u,
          v: v,
          roll_degrees: roll * 180 / :math.pi(),
          baseline_gauge_degrees: gauge * 180 / :math.pi()
        }
      end)

    sections =
      Enum.map(frames, fn f ->
        for {w, t} <- [{-0.06, -0.01}, {0.06, -0.01}, {0.06, 0.01}, {-0.06, 0.01}],
            do: M.add(f.point, M.add(M.scale(f.u, w), M.scale(f.v, t)))
      end)

    cells =
      for [a, b] <- Enum.chunk_every(sections, 2, 1, :discard) do
        verts = a ++ b

        G.mesh(
          for ids <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(ids, &Enum.at(verts, &1))
        )
      end

    mesh =
      G.mesh(Enum.flat_map(cells, & &1.faces)) |> Map.merge(%{cells: cells, sections: sections})

    %{
      id: "room-ribbon:1",
      source: "gallery-door:1; inherited text ROOM; prospective continuous stock",
      points: points,
      frames: frames,
      geometry: mesh,
      width: 0.12,
      thickness: 0.02,
      twist_interval: [twist_start, twist_end],
      twist_degrees: 180,
      baseline_gauge_degrees: gauge * 180 / :math.pi(),
      tail_normal: List.last(frames).v,
      under_post_index: Enum.find_index(points, &(&1 == [3, -0.28, -3])),
      passages: [
        %{
          id: "room-ribbon:1/outward",
          indices: [0, 1],
          door: "gallery-door:1",
          office: "BY WAY OF Gallery THROUGH INTO Stage TOWARD STANDING FOR STAGING"
        },
        %{
          id: "room-ribbon:1/return",
          indices: [
            Enum.find_index(points, &(&1 == [3.55, 1.95, -0.55])),
            Enum.find_index(points, &(&1 == [3.55, 1.95, -1.7]))
          ],
          door: "gallery-door:1",
          office:
            "FROM STAGING FOR STANDING AROUND ABOUT / UNDER and THROUGH SAME Gallery TOWARD STANDING FOR STAGING"
        }
      ],
      source_M: "room-ribbon:1/M",
      source_R: "specimen:R:1",
      attachment: :yellow,
      acquired: false
    }
  end

  def frame_at(r, t) do
    q = t * (length(r.frames) - 1)
    i = min(trunc(q), length(r.frames) - 2)
    f = Enum.at(r.frames, i)
    g = Enum.at(r.frames, i + 1)
    w = q - i
    mix = fn a, b -> M.add(M.scale(a, 1 - w), M.scale(b, w)) end
    tangent = M.unit(mix.(f.tangent, g.tangent))
    raw = mix.(f.u, g.u)

    # The half-twist cell has antipodal endpoint frames. Rotate its actual angle instead of lerping through zero.
    u =
      if M.norm(raw) < 0.1 or abs(g.roll_degrees - f.roll_degrees) > 90 do
        rotate(f.u, tangent, w * (g.roll_degrees - f.roll_degrees) * :math.pi() / 180)
      else
        M.unit(M.sub(raw, M.scale(tangent, M.dot(raw, tangent))))
      end

    %{point: mix.(f.point, g.point), tangent: tangent, u: u, v: M.cross(tangent, u)}
  end
end
