defmodule PublicSituationMachineTurnZero.Workshop.JanusiteInheritance do
  @moduledoc "Source-preserving road/letter/shared-curve/ONE-to-TWO inspection; no constitutional operations."
  alias PublicSituationMachineTurnZero.Workshop.{
    HereWedging,
    SnailBody,
    ComingAboardMachine,
    AlongsideStaging,
    MaterialRibbon
  }

  alias MaterialRibbon, as: M

  def new,
    do: %{
      text: "ROOM",
      mode: "A",
      view: "flat",
      footing: "one",
      stitches?: true,
      loops?: true,
      hypothetical?: false
    }

  def change(s, {:text, t}) when is_binary(t) and byte_size(t) > 0 and byte_size(t) <= 12 do
    if Regex.match?(~r/^[A-Z]+$/, t),
      do: {:ok, %{s | text: t}},
      else: {:error, :uppercase_specimen_required}
  end

  def change(s, {:mode, v}) when v in ~w(A B C), do: {:ok, %{s | mode: v}}
  def change(s, {:view, v}) when v in ~w(flat longhouse tunneling), do: {:ok, %{s | view: v}}
  def change(s, {:footing, v}) when v in ~w(one two), do: {:ok, %{s | footing: v}}

  def change(s, {:toggle, k}) when k in [:stitches?, :loops?, :hypothetical?],
    do: {:ok, Map.update!(s, k, &(!&1))}

  def change(_, _), do: {:error, :inspection_only}

  def sample(t, view, offset) do
    f = SnailBody.arc_frame(t)

    p =
      if view == "flat",
        do: [t * SnailBody.arc_length() * 6 / 1.4, 0, 0],
        else: M.add(ComingAboardMachine.snail_point(f.point), offset)

    %{
      point: p,
      tangent: if(view == "flat", do: [1, 0, 0], else: f.tangent),
      across: if(view == "flat", do: [0, 1, 0], else: f.binormal),
      normal: if(view == "flat", do: [0, 0, 1], else: f.radial),
      address: t
    }
  end

  def model(s) do
    h = HereWedging.model()
    offset = h.snail.offset
    id = "janusite:" <> Base.encode16(:crypto.hash(:sha256, s.text), case: :lower)
    n = String.length(s.text)
    finish = n / 24
    frames = Enum.map(0..(n * 4), &sample(&1 / 96, "source", offset))
    points = Enum.map(frames, & &1.point)

    sections =
      Enum.map(frames, fn f ->
        for {w, d} <- [{-0.5, -0.01}, {0.5, -0.01}, {0.5, 0.01}, {-0.5, 0.01}],
            do: M.add(f.point, M.add(M.scale(f.across, w), M.scale(f.normal, d)))
      end)

    cells =
      Enum.chunk_every(sections, 2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        vertices = a ++ b

        %{
          vertices: vertices,
          faces:
            for(
              ids <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(ids, &Enum.at(vertices, &1))
            )
        }
      end)

    letters =
      String.graphemes(s.text)
      |> Enum.with_index()
      |> Enum.map(fn {letter, i} ->
        at = fn t, w ->
          f = sample(t, "source", offset)
          M.add(f.point, M.scale(f.across, w))
        end

        a = (i + 0.2) / 24
        b = (i + 0.8) / 24
        t = (i + 0.5) / 24
        lead = at.(a, -0.5)
        trail = at.(b, -0.5)
        top = at.(t, 0.35)
        f = sample(t, "source", offset)
        loop_center = at.(t, 0.75)

        loop =
          for j <- 0..24,
              do:
                M.add(
                  loop_center,
                  M.add(
                    M.scale(f.tangent, 0.08 * :math.cos(j * :math.pi() / 12)),
                    M.scale(f.across, 0.08 * :math.sin(j * :math.pi() / 12))
                  )
                )

        %{
          id: id <> "/letter-#{i + 1}",
          letter: letter,
          address: t,
          carriage: f,
          toes: [
            %{id: "leading", point: lead, address: a, solid: stitch(lead)},
            %{id: "trailing", point: trail, address: b, solid: stitch(trail)}
          ],
          wedge:
            M.prism("letter-#{i + 1}", [lead, trail, top], 0.02)
            |> Map.merge(%{
              material_id: id <> "/letter-#{i + 1}/wedge",
              source: "JanusiteInheritance.model/1; SnailBody.arc_frame/1 Toe addresses",
              width: M.distance(lead, trail),
              hinge: %{
                id: "toe-bearing",
                endpoints: [lead, trail],
                ordering: "Leading TOWARD Trailing"
              }
            }),
          loop: %{
            id: "upper-guide",
            points: loop,
            stitch: false,
            occupied_profile: Enum.map(loop, &stitch/1)
          },
          joins: :candidate_inner_crossing_stitches,
          head?: i == 0,
          tail?: i == n - 1
        }
      end)

    endpoint = sample(finish, "source", offset).point

    probe =
      M.prism(
        "diagnostic-cob-profile",
        [
          sample(0, "source", offset).point,
          sample(1 / 96, "source", offset).point,
          M.add(sample(0, "source", offset).point, [0.1, 0, 0])
        ],
        0.1
      )
      |> Map.merge(%{
        material_id: id <> "/diagnostic-cob-profile",
        source: "JanusiteInheritance.model/1; diagnostic profile only",
        width: 0.1,
        hinge: nil
      })

    collision = Enum.any?(cells, &M.collision?(&1, probe))

    %{
      id: id,
      geometry_contract: "geometry-table-2026-11-14.v5",
      source_line: %{id: "snail-radial-arc-v1", points: points, end_address: finish},
      cob_course: %{
        source_line_id: "snail-radial-arc-v1",
        points: points,
        profile: probe,
        actual_craft: nil
      },
      road: %{
        cells: cells,
        sections: sections,
        top_to_bottom: 1,
        measure_basis: "XT TO XT unit candidate comparison; material conversion unproved",
        length: n * SnailBody.arc_length() / 24 * 6 / 1.4,
        thickness: 0.02
      },
      letters: letters,
      head: hd(letters).id,
      tail: List.last(letters).id,
      offset: offset,
      scale: 6 / 1.4,
      crossing: %{
        id: "inner-projectioning-stitching-locality",
        door: "staging for staging",
        pinning: "staging for standing",
        manufactured_join: :unproved
      },
      table: %{
        point: h.table,
        source: "HereWedging.table",
        distance_to_source_end: M.distance(h.table, endpoint),
        exchange: :blocked_no_physical_transform
      },
      inheritance: %{
        returning_string: %{material: id, endpoint: endpoint},
        inaugural_xt: %{
          source: "HereWedging.model/0 unit",
          points: h.unit.points,
          joining_to_curve: :unproved
        },
        aperture: Map.put(AlongsideStaging.aperture(), :source, "AlongsideStaging.aperture/0"),
        yt_toward_yt: %{origin: endpoint, material_points: [], status: :appended_address_only},
        two_cursor: endpoint,
        cursor_furnishes_length: false,
        next_material_points: [],
        next_xt_origin:
          if(s.hypothetical?,
            do: %{point: endpoint, status: :hypothetical_landing_fixture},
            else: nil
          ),
        actual_landing: nil,
        next_floor: :blocked_unproved_resolution,
        fold_degrees: 45,
        opening_condition: :inspection_fixture_pending,
        closing_condition: :inspection_fixture_pending,
        no_ceiling_passage: "Current XT TO XT continues; another circuit creates no new origin"
      },
      guide_rail: Enum.map(frames, fn f -> M.add(f.point, M.scale(f.across, 0.75)) end),
      fold_trial:
        M.prism(
          "inherited-unit-45-trial",
          Enum.map(h.wedge.points, fn p ->
            [x, y, z] = M.sub(p, hd(h.unit.points))
            a = :math.pi() / 4

            M.add(hd(h.unit.points), [
              x * :math.cos(a) + z * :math.sin(a),
              y,
              -x * :math.sin(a) + z * :math.cos(a)
            ])
          end),
          0.04
        )
        |> Map.merge(%{
          source: "HereWedging unit specimen; candidate +45-degree Y pivot",
          material_id: "here-unit:45-degree-trial",
          width: 1,
          hinge: %{id: "here-unit-y-pivot", origin: hd(h.unit.points), axis: [0, 1, 0]},
          join: :unproved
        }),
      clearance: %{
        diagnostic_profile_intersects_road: collision,
        actual_cob_clearance: :unproved,
        guide_and_loop_clearance: :unproved
      },
      preserved_fit: h.snail.height_range,
      preserved_source: h.snail.source,
      frame: "exploration-six-v1",
      acquired_index: 0
    }
  end

  def stitch(p) do
    vertices =
      for x <- [-0.02, 0.02], y <- [-0.02, 0.02], z <- [-0.02, 0.02], do: M.add(p, [x, y, z])

    %{
      vertices: vertices,
      faces:
        for(
          ids <- [
            [0, 1, 3, 2],
            [4, 6, 7, 5],
            [0, 4, 5, 1],
            [2, 3, 7, 6],
            [0, 2, 6, 4],
            [1, 5, 7, 3]
          ],
          do: Enum.map(ids, &Enum.at(vertices, &1))
        )
    }
  end

  def project(points, view) do
    Enum.map_join(points, " ", fn [x, y, z] ->
      {u, v} =
        case view do
          "tunneling" -> {z, y}
          "longhouse" -> {(x + z) * :math.sqrt(0.5), y}
          _ -> {x, y}
        end

      "#{100 + u * 30},#{460 - v * 30}"
    end)
  end
end
