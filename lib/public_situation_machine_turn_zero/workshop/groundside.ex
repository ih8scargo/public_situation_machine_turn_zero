defmodule PublicSituationMachineTurnZero.Workshop.Groundside do
  # Geometry reconciliation: Groundside/Craft projections retain old frames and cannot establish the new acquired Human FROM-standing.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Reversible lower-source presentation and explicitly provisional U-normal optical probe. No registrations are mutated."
  alias PublicSituationMachineTurnZero.Workshop.Projection

  def diorama(model) do
    {left, base} = crossing_span(model)
    boundary = left + base
    lower = model["entities"]["lower"]
    face = Enum.find(lower["surfaces"], &(&1["id"] == "lower-surface-x-max"))
    seam = Enum.map(face["vertices"], &Enum.at(lower["vertices"], &1))
    outer = Enum.map(seam, &add(&1, [base, 0, 0]))
    rim = Enum.zip_with(outer, tl(outer) ++ [hd(outer)], &[&1, &2])

    %{
      edges: rim ++ Enum.zip_with(seam, outer, &[&1, &2]),
      strip: source_strip(model["projection"]["source"], left, 2 * base),
      interval: [left, boundary, boundary + base]
    }
  end

  defp crossing_span(model) do
    crossing = model["entities"]["central"]
    {hd(crossing["frame"]["origin"]), hd(crossing["dimensions"])}
  end

  defp source_strip(source, left, reach) do
    {xmin, xmax} = source["outline"] |> Enum.map(&hd/1) |> Enum.min_max()

    Enum.map(source["outline"], fn [x, y, z] ->
      [left + reach * (x - xmin) / (xmax - xmin), y, z]
    end)
  end

  def witness(model, registry, mode, surfacing \\ nil, seat \\ nil) do
    crossing = model["entities"]["central"]
    {left, base} = crossing_span(model)
    source = model["projection"]["source"]
    aperture = Enum.find(registry["items"], &(&1["id"] == "u-aperture"))
    u = registry["u_frame"]["origin"]
    half_extent = base / 12
    rail_u = model["steeling"]["u_return"]["point"]

    cage_vertices =
      for index <- 0..7,
          do:
            Enum.with_index(rail_u)
            |> Enum.map(fn {v, axis} ->
              v +
                if(Bitwise.band(index, Bitwise.bsl(1, axis)) == 0,
                  do: -half_extent,
                  else: half_extent
                )
            end)

    cage_edges =
      for index <- 0..7,
          bit <- [1, 2, 4],
          Bitwise.band(index, bit) == 0,
          do: [Enum.at(cage_vertices, index), Enum.at(cage_vertices, Bitwise.bor(index, bit))]

    trial_origin = [
      hd(rail_u),
      Enum.at(hd(model["entities"]["lower"]["vertices"]), 1),
      Enum.at(rail_u, 2) - base / 3
    ]

    normal = Enum.at(registry["u_frame"]["basis"], 2)
    eye = add(u, scale(normal, -base))
    reach = 2 * base
    xs = Enum.map(source["outline"], &Enum.at(&1, 0))
    zs = Enum.map(source["outline"], &Enum.at(&1, 2))
    xmin = Enum.min(xs)
    xspan = Enum.max(xs) - xmin
    ymin = Enum.min_by(aperture["points"], &Enum.at(&1, 1)) |> Enum.at(1)
    ymax = Enum.max_by(aperture["points"], &Enum.at(&1, 1)) |> Enum.at(1)

    strip = source_strip(source, left, reach)

    # Homothety from a U-derived probe: aperture at distance SIX, window at TWO*SIX.
    # This is a candidate field mapping, not a Seat transform or physical passage.
    window = Enum.map(aperture["points"], fn point -> add(eye, scale(sub(point, eye), 2)) end)
    far_window = Enum.map(window, &add(&1, scale(normal, base)))
    craft = Projection.cob(model["projection"], model["rehearsal"]["progress"])["point"]

    standing =
      Enum.map(model["rehearsal"]["footings"], fn f ->
        %{
          id: f["id"],
          letter: f["letter"],
          sequence: f["sequence"],
          world: Projection.material(model["projection"], f)["vertical"]["point"]
        }
      end)

    record =
      if surfacing,
        do: surfacing["records"] |> Enum.filter(&(&1["route"] == "staging")) |> List.last()

    graphemes = if record, do: String.graphemes(record["text"]), else: []
    count = length(graphemes)
    # Preserve authored order; older/head is nearer, last-in remains farther toward
    # the vanishing direction. These are static inspection ranks, not emergence events.
    indices =
      if count <= 12,
        do: Enum.to_list(1..max(count, 1)),
        else: Enum.to_list(1..6) ++ Enum.to_list((count - 5)..count)

    u_width =
      Enum.max_by(aperture["points"], &hd/1)
      |> hd()
      |> Kernel.-(Enum.min_by(aperture["points"], &hd/1) |> hd())

    tokens =
      if count == 0,
        do: [],
        else:
          Enum.map(indices, fn i ->
            t = (i - 1) / max(1, count - 1)
            point = add(u, [u_width * (t - 0.5), base / 6, base + base * t])

            %{
              index: i,
              text: Enum.at(graphemes, i - 1),
              world: point,
              material_id: record["id"],
              author: record["author"],
              unvanishing_rank: i
            }
          end)

    project =
      case mode do
        "groundside" ->
          fn [x, y, z] -> {75 + (x - left) * 27 + z * 7, 300 - y * 25 - z * 3} end

        "groundside-tunnel" ->
          fn point ->
            [x, y, z] = sub(point, eye)
            depth = max(0.03, z)
            {400 + 650 * x / depth, 215 - 650 * y / depth}
          end
      end

    outlines = fn entity ->
      for surface <- entity["surfaces"],
          do: polyline(Enum.map(surface["vertices"], &Enum.at(entity["vertices"], &1)), project)
    end

    aperture_hits = Enum.map(window, fn point -> add(eye, scale(sub(point, eye), 0.5)) end)

    %{
      rail_cage_world: cage_edges,
      rail_cage_screen: Enum.map(cage_edges, &polyline(&1, project)),
      base: base,
      reach: reach,
      source: source,
      source_world: source["outline"],
      strip_world: strip,
      source_screen: polyline(source["outline"], project),
      ticks:
        Enum.map([left, left + base, left + reach], fn x ->
          {x, project.([x, Enum.at(source["origin"], 1), 0])}
        end),
      strip_screen: polyline(strip, project),
      crossing: outlines.(crossing),
      lower: outlines.(model["entities"]["lower"]),
      crossing_world: crossing,
      aperture_world: aperture["points"],
      aperture_screen: polyline(aperture["points"], project),
      aperture_record: aperture,
      window_world: window,
      window_screen: polyline(window, project),
      far_screen: polyline(far_window, project),
      aperture_hits: aperture_hits,
      rays: Enum.zip_with(window, far_window, fn a, b -> polyline([a, b], project) end),
      source_to_window: polyline([source["origin"], u, add(u, scale(normal, base))], project),
      craft_world: craft,
      craft_screen: project.(craft),
      standing: Enum.map(standing, &Map.put(&1, :screen, project.(&1.world))),
      tokens: Enum.map(tokens, &Map.put(&1, :screen, project.(&1.world))),
      up_over: polyline([u, add(u, [0, base / 6, 0])], project),
      ground: polyline([[left, -base, 0], [left + reach, -base, 0]], project),
      native_seat: seat,
      probe_eye: eye,
      probe_direction: normal,
      u_center: u,
      vanishing_point: if(mode == "groundside-tunnel", do: {400, 215}),
      vanishing_guide:
        if(mode == "groundside-tunnel" && tokens != [],
          do: "400,215 " <> (hd(tokens).world |> project.() |> then(fn {x, y} -> "#{x},#{y}" end))
        ),
      record: record,
      token_count: count,
      relations: %{
        "source" => "#{source["id"]}; registered source Y=-3, distinct from Ground Y=-6",
        "u_witness_gap" =>
          "Rail U13 one-extent cage and calibration U aperture are distinct existing witnesses. Candidate window follows the calibration aperture; the actual inner U opening and their pinning remain unresolved.",
        "existing_bunting_trial" => %{
          "origin" => trial_origin,
          "source" =>
            "existing projection.js buntingPrimitives; shared Ground contact is a trial, not a new constitutional zero"
        },
        "groundside_gap" =>
          "Only Lower Staging source Y=-3 is furnished. Its Resolutioning relation to the Ground-side plane Y=-6 is unestablished.",
        "extension" => %{
          "scope" => "LOWER STAGING GROUNDSIDE presentation only",
          "base" => base,
          "reach" => reach,
          "axis" => "existing +X rehearsal bearing; only source-field display copy stretched",
          "x_range" => [left, left + reach]
        },
        "field_map" =>
          "source X #{xmin}..#{xmin + xspan} -> display X #{left}..#{left + reach}; source Y/Z retained (Z #{Enum.min(zs)}..#{Enum.max(zs)})",
        "window" =>
          "candidate optical field at U + SIX*normal; homothety factor TWO from probe; distinct from U plane; not a physical twelve-extent CUBICAL",
        "aperture" =>
          "existing #{aperture["id"]}; U13 #{inspect(u)}; existing provisional dimensions Y #{ymin}..#{ymax} retained",
        "UP_OVER" =>
          "prospective glyph Y = U.Y + SIX/6; acquired vertical Footing witnesses retain Y=3",
        "unvanishing" =>
          "LAST IN, LAST UNVANISHING: original authored sequence retained; head index 1 nearer, newest farther toward vanishing direction. Static witness only; no operational emergence.",
        "seat_gap" =>
          "native Seat +Z is in the appliance frame; Workshop transform, actual eye/pivot and source-window pinning remain unappointed. U-normal probe is NOT the Traversaling Seat.",
        "axes_gap" =>
          "Craft course +X and U normal +Z are distinct; no constitutional rotation between them asserted",
        "vanishing" =>
          "optical directional limit of parallel U-normal guides, not a new constitutional origin"
      }
    }
  end

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp scale(p, n), do: Enum.map(p, &(&1 * n))

  defp polyline(points, project),
    do: points |> Enum.map(project) |> Enum.map_join(" ", fn {x, y} -> "#{x},#{y}" end)
end
