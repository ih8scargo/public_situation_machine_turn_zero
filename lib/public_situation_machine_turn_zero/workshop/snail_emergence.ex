defmodule PublicSituationMachineTurnZero.Workshop.SnailEmergence do
  @moduledoc "Versioned Seat-to-spiral inspection registration. Does not execute RE-STEP, accrue Footings or rewrite the Weave ledger."
  alias PublicSituationMachineTurnZero.Workshop.{SnailBody, SnailWeaveGeometry}

  def model(s, base, extent \\ 0.0, quarter_turn \\ 90, candidate \\ "through") do
    here = [0, 0, 0]
    old_aperture = [-0.55, -0.65, 0.75]
    depth = abs(Enum.at(old_aperture, 1))
    aperture = [-depth, -depth, 0]
    eye_height = abs(Enum.at(SnailBody.model(s["body"]).within_eye, 1))
    eye = [0, eye_height, 0]
    cob = [0.2, eye_height, 0]
    half_square = 0.7
    scale = half_square / 3
    acquired = List.last(s["footings"])

    active_turn =
      if s["active"],
        do: Enum.find(s["turns"], &(&1["id"] == s["active"]["turn"])),
        else: List.last(s["turns"])

    material =
      active_turn && active_turn["material"] &&
        Enum.find(s["body"]["material"], &(&1["id"] == active_turn["material"]))

    # Two joined cubic pieces leave the Groundward aperture, meet the acquired
    # HERE registration, then join the unchanged analytic helix at address zero.
    join = SnailBody.arc_point(0)
    tangent = SnailBody.arc_frame(0).tangent
    a = [aperture, add(aperture, [depth / 3, depth / 3, 0]), [-0.1, 0, 0], here]
    b = [here, [0.1, 0, 0], sub(join, mul(tangent, 0.2)), join]

    samples =
      for(i <- 0..32, do: sample(a, i / 32, [0, 0, 1])) ++
        for i <- 1..32 do
          t = i / 32
          f = t * t * (3 - 2 * t)
          sample(b, t, [f, 0, 1 - f])
        end

    prefix = Enum.map(samples, & &1.point)
    prefix_length = poly_length(prefix)

    walls =
      Enum.with_index(Enum.zip(samples, tl(samples)))
      |> Enum.map(fn {{u, v}, i} ->
        %{
          id: "seat-emergence-wall-#{i}",
          kind: "janusite-wall",
          color: if(acquired, do: "#5eead4", else: "#69849b"),
          points: [
            sub(u.point, mul(u.width, 0.08)),
            add(u.point, mul(u.width, 0.08)),
            add(v.point, mul(v.width, 0.08)),
            sub(v.point, mul(v.width, 0.08))
          ]
        }
      end)

    keep_surfaces =
      Enum.reject(
        base.surfaces,
        &(&1.kind in ["projection", "presentation"] ||
            &1.id in ["inner-aperture", "cabinet-side-aperture"])
      )

    physical = keep_surfaces ++ walls
    ground_eye = sub(aperture, mul(unit(sub(here, aperture)), 0.12))

    marks =
      if material do
        String.graphemes(material["text"])
        |> Enum.take(8)
        |> Enum.with_index()
        |> Enum.map(fn {letter, i} ->
          host = Enum.find(keep_surfaces, &(&1.id == "corkscrew-ribbon-#{136 + i}"))

          quad = [
            uv(host.points, 0.2, 0.4),
            uv(host.points, 0.8, 0.4),
            uv(host.points, 0.8, 0.05),
            uv(host.points, 0.2, 0.05)
          ]

          p = uv(host.points, 0.5, 0.225)

          blockers =
            SnailWeaveGeometry.ray_hits(Enum.reject(physical, &(&1.id == host.id)), eye, p)

          corner_hits =
            Enum.map(
              quad,
              &SnailWeaveGeometry.ray_hits(
                Enum.reject(physical, fn surf -> surf.id == host.id end),
                eye,
                &1
              )
            )

          n = unit(cross(sub(Enum.at(quad, 1), hd(quad)), sub(Enum.at(quad, 3), hd(quad))))

          %{
            groundward_obstructions:
              SnailWeaveGeometry.ray_hits(
                Enum.reject(physical, &(&1.id == host.id)),
                ground_eye,
                p
              ),
            material: material["id"],
            letter: letter,
            index: i,
            host: host.id,
            quad: quad,
            point: p,
            normal: n,
            visible: blockers == [] && Enum.all?(corner_hits, &(&1 == [])),
            corner_obstructions: corner_hits,
            signed_incidence: dot(n, unit(sub(eye, p))),
            blockers: blockers,
            incidence: abs(dot(n, unit(sub(eye, p))))
          }
        end)
      else
        []
      end

    diagnostic_marks = marks
    # The first three glyphs form a bounded identifiable sample at the clear patch;
    # retain the wider eight-face probe, including its occluded results, as evidence.
    marks = Enum.take(marks, 3)
    q = SnailBody.model(s["body"], base.fold.degrees, base.fold.quarter)
    origin = add(q.fold.tunnel_axis, mul(q.fold.normal, 0.08))

    opportunities =
      Enum.map(
        [
          {"through", add(q.fold.tunnel_axis, mul(q.fold.normal, 0.5)), nil},
          {"arrival", aperture, "toward arrival aperture"},
          {"standing", here, "toward standing HERE / Rooming"}
        ],
        fn {id, target, forbidden} ->
          hits = SnailWeaveGeometry.ray_hits(physical, origin, target)

          %{
            id: id,
            origin: origin,
            target: target,
            inside_actual_wedge: true,
            eligible: is_nil(forbidden) && hits == [],
            reason:
              forbidden ||
                if(hits == [],
                  do: "ALONG THROUGH existing wedge; candidate only",
                  else: "surface obstruction"
                ),
            obstructions: hits
          }
        end
      )

    chosen = Enum.find(opportunities, &(&1.id == candidate)) || hd(opportunities)
    puff_outline = Enum.map(q.fold.far, &add(&1, mul(q.fold.normal, 0.15)))
    monitor = Enum.find(base.surfaces, &(&1.id == "ordinary-flat-monitor")).points

    flat_diagonals = [
      %{
        id: "diagonal-XT-TOWARD-YT",
        points: [Enum.at(monitor, 2), Enum.at(monitor, 0)],
        purpose: "Fishing Pole pivot / Regarding / finding / Pointing-able"
      },
      %{
        id: "diagonal-return-bend",
        points: [Enum.at(monitor, 1), Enum.at(monitor, 3)],
        purpose: "Regarding toward the bend returning XT TOWARD YT toward XT"
      }
    ]

    bend = SnailBody.arc_point(1 / 3)
    # Eligibility is a geometric preview; selecting it never performs PUFFING.
    lines =
      Enum.reject(base.lines, fn l ->
        String.starts_with?(l.id, "projection-") ||
          l.id in [
            "long-directed-FRONT",
            "loading-deck-to-run-CONFLICT",
            "bellows-UP-reading",
            "receiver-to-monitor-registration",
            "seated-eye-line-of-regard",
            "seat-datum-six-wide",
            "seat-datum-six-high",
            "XT-Furnishing-COB-ALONGSIDE",
            "YT-Traversaling-office-ALONGSIDE",
            "Fishing-Pole-Pointing-able-Thing"
          ]
      end) ++
        [
          line("Seat-fixed-HERE-datum", square(here, 0.12), "#e2e8f0"),
          line("Human-UPON-Seat-eye", [here, eye], "#e2e8f0"),
          line("COB-FROM-OUT-OF-Seat", [here, cob], "#fbbf24"),
          line("common-eye-level", [add(eye, [-0.2, 0, 0]), add(cob, [0.2, 0, 0])], "#fbbf24"),
          line("inaugural-45-degree-bearing", [aperture, here], "#c4b5fd"),
          line("seat-to-spiral-continuation", prefix, "#5eead4"),
          line(
            "acquired-Landinging-registration",
            circle(base.fixed.landinging.radius),
            "#5eead4"
          ),
          line("foot-DOWN-contact-postcondition", square(here, 0.18), "#fbbf24"),
          line("XT-TO-XT-zero-to-one", [here, [scale, 0, 0]], "#e2e8f0"),
          line(
            "return-bend-Regarding-mobile",
            [eye, bend],
            if(
              SnailWeaveGeometry.ray_hits(
                Enum.reject(physical, &(&1.kind == "registration")),
                eye,
                bend
              ) == [],
              do: "#c4b5fd",
              else: "#fb7185"
            )
          ),
          line("wedging-outline", q.fold.far, "#c4b5fd"),
          line(
            "PUFFING-candidate-outline",
            puff_outline,
            if(chosen.eligible, do: "#5eead4", else: "#fb7185")
          ),
          line(
            "selected-candidate",
            [origin, chosen.target],
            if(chosen.eligible, do: "#5eead4", else: "#fb7185")
          ),
          line(
            "Unvanishing-Line-source",
            [add(aperture, [0, 0, -0.08]), add(aperture, [0, 0, 0.08])],
            "#fbbf24"
          )
        ]

    native_aperture = s["opening"]["opening_geometry"]["aperture"]
    aperture_half = if native_aperture, do: native_aperture["half_size"], else: 0.35
    aperture_u = [0, 0, -aperture_half]
    aperture_v = mul(unit([-1, 1, 0]), aperture_half)

    physical =
      physical ++
        [
          %{
            id: "inaugural-aperture-45",
            kind: "registration",
            color: "#c4b5fd",
            points: rect(aperture, aperture_u, aperture_v)
          }
        ]

    source_revision = acquired_revision(acquired)

    provided =
      Enum.with_index(s["events"], 1) |> Enum.filter(fn {e, _} -> e["op"] == "provide" end)

    prior_turn_candidates =
      if acquired do
        Enum.with_index(s["turns"])
        |> Enum.filter(fn {t, i} ->
          hd(t["addresses"]) >= acquired["address"] && t["id"] != acquired["turn"] &&
            match?({_, _}, Enum.at(provided, i)) &&
            elem(Enum.at(provided, i), 1) < source_revision
        end)
        |> Enum.map(fn {t, _} -> t["id"] end)
      else
        []
      end

    registration = %{
      version: "seat-to-spiral-inspection-v1",
      source_seat: s["seat"],
      fixed_seat: here,
      HERE: base.fixed.here,
      reference_dimensions: [6, 6],
      reference_midpoint: [3, 3],
      reference_to_here: [
        [scale, 0, 0, -half_square],
        [0, 0, -1, 0],
        [0, scale, 0, -half_square],
        [0, 0, 0, 1]
      ],
      current_aperture: old_aperture,
      native_aperture_source: native_aperture,
      native_aperture_relation: "aperture-available",
      native_aperture_to_revised: [
        [0, -1 / :math.sqrt(2), 1 / :math.sqrt(2), -depth],
        [0, 1 / :math.sqrt(2), 1 / :math.sqrt(2), -depth],
        [-1, 0, 0, 0],
        [0, 0, 0, 1]
      ],
      revised_aperture: aperture,
      bearing_degrees: 45,
      current_eye: base.within_eye,
      revised_eye: eye,
      eye_height_source: "magnitude of prior 0.63 eye offset, separated from Seat datum",
      COB_eye: cob,
      COB_source: "same COB FROM OUT OF fixed Seat; two offices, no additional chair",
      seat_motion: false,
      canonical_ledger_rewritten: false
    }

    fresh = %{
      kind: "geometric postcondition inspection; no RE-STEP performed",
      acquired_source: acquired,
      production_Landinging:
        "not yet furnished by an operational RE-STEP; local Footing is not relabeled as one",
      acquired_registration: here,
      source_to_here: if(acquired, do: mul(acquired["point"], -1), else: nil),
      contact_plane_y: 0,
      local_fashioning_extent: 0.0,
      inspected_later_extent: extent,
      scenario:
        if(extent == 0,
          do: "fresh zero-extent postcondition",
          else: "later fashioning inspection; fresh extent remains zero"
        ),
      inherited_material_ids: Enum.map(s["footings"], & &1["material"]) |> Enum.uniq(),
      retained_authored_material_ids: Enum.map(s["body"]["material"], & &1["id"]),
      inherited_footing_ids: Enum.map(s["footings"], & &1["id"]),
      next_frames_previously_furnished: [],
      prior_cubical_turn_candidates: prior_turn_candidates,
      next_frame_available: false,
      next_frame_basis:
        "No dedicated RE-STEP opportunity is recorded by the current source contract. A CUBICAL turn is not automatically such a frame.",
      next_frame_rule:
        "Available only through the authoring Human's prior furnishing of that opportunity; no opportunity is invented here.",
      accretion_limit: nil,
      appointment_count_is_not_footing_count: true
    }

    %{
      version: "seat-to-spiral-inspection-v1",
      registration: registration,
      binding: %{
        standing:
          if(acquired,
            do: "registered to existing local acquired Footing",
            else:
              "given inaugural Human standing anchors geometry; authored/local-acquisition witness pending"
          ),
        source_footing: acquired && acquired["id"],
        source_standing_id: "human-standing",
        source_standing: s["opening"]["relations"]["human-standing"],
        source_material: material && material["id"],
        source_arc: "snail-radial-arc-v1",
        prefix_addresses: [-prefix_length, 0],
        join: join,
        join_tangent: tangent,
        material_width: 0.16,
        unchanged_helix: SnailBody.reference_arc(),
        prefix: prefix,
        seam: List.last(walls).points |> Enum.take(-2),
        continuity:
          "joined centerline tangents and shared ribbon edge; physical support/twist/engagement unresolved"
      },
      fresh: fresh,
      diagonals: %{
        flat: flat_diagonals,
        return_bend: bend,
        volume_return: [eye, bend],
        return_bend_obstructions:
          SnailWeaveGeometry.ray_hits(
            Enum.reject(physical, &(&1.kind == "registration")),
            eye,
            bend
          ),
        PITTONING: "direct participation versus availability after PITTONING remains unresolved",
        YT_TOWARD_YT:
          "reserved for Human interpolation / Semantical In-Stringing-Mentings; no aligning block"
      },
      physical_clearance: %{
        emergence_table_crossings: plane_crossings(walls, -0.1, 0.24, 1.4),
        emergence_standing_annulus_crossings: plane_crossings(walls, 0, 0.24, 0.48),
        scope:
          "ribbon edge / existing annulus plane intersections; no load or solid Seat fit claim"
      },
      wall_test: %{
        material: material,
        sample: Enum.map_join(marks, & &1.letter),
        marks: marks,
        diagnostic_probes: diagnostic_marks,
        actual_surface: "existing JANUSITE corkscrew ribbon; no new optical relay",
        wall_arc_interval: [136 / 144, 1.0],
        early_wall_probe: %{
          host: "corkscrew-ribbon-24",
          point: uv(Enum.find(keep_surfaces, &(&1.id == "corkscrew-ribbon-24")).points, 0.5, 0.5),
          obstructions:
            SnailWeaveGeometry.ray_hits(
              keep_surfaces,
              eye,
              uv(Enum.find(keep_surfaces, &(&1.id == "corkscrew-ribbon-24")).points, 0.5, 0.5)
            )
        },
        source_line: [add(aperture, [0, 0, -0.08]), add(aperture, [0, 0, 0.08])],
        source_line_area: 0,
        physical_interference: SnailWeaveGeometry.ray_hits(keep_surfaces, aperture, here),
        visible_count: Enum.count(marks, & &1.visible),
        hidden_count: Enum.count(marks, &(!&1.visible)),
        registration:
          "same material ID from flat presentation to actual surface quads; local affine glyph approximation",
        optical_motor: false
      },
      opportunities: opportunities,
      selected_candidate: candidate,
      regard: %{
        quarter_turn: quarter_turn,
        flat_forward: [0, 0, 1],
        volume_forward: [0, -1, 0],
        body_rotated_by_regarding: false,
        reading_right: SnailBody.arc_frame(136 / 144).tangent |> List.replace_at(1, 0) |> unit()
      },
      history: %{
        long_run_margin: base.clearances.long_run_sweep_margin,
        cabinet_lead_conflict: base.clearances.source_lead_conflict,
        disposition:
          "prior relay proposal retained, not required or rerouted by this surface test",
        bellows: "unresolved; not appointed"
      },
      ledger: %{
        standing: acquired,
        affordmenting: registration,
        outreading: "surface normals / occlusion / candidate eligibility",
        Human_laboring: Enum.map(s["body"]["material"], &Map.take(&1, ~w(id author piece))),
        confirmationing: s["completions"],
        returnability: "source Weave witness unchanged; inspection views reversible",
        hypotheses: [
          "Seat-to-eye registration",
          "connector ribbon twist and support",
          "production acquired Landinging contract",
          "physical wall projection resolution"
        ]
      },
      presentation: %{
        surfaces: physical,
        lines: lines,
        within_eye: eye,
        within_toward: [0, 0, 0],
        tags: [],
        noticings: []
      }
    }
  end

  defp circle(r),
    do:
      for(
        i <- 0..64,
        do: [r * :math.cos(i * :math.pi() / 32), 0, r * :math.sin(i * :math.pi() / 32)]
      )

  defp plane_crossings(walls, y, inner, outer) do
    Enum.flat_map(walls, fn w ->
      Enum.zip(w.points, tl(w.points) ++ [hd(w.points)])
      |> Enum.flat_map(fn {[_, ay, _] = a, [_, by, _] = b} ->
        if abs(by - ay) < 1.0e-12 do
          []
        else
          t = (y - ay) / (by - ay)
          p = add(a, mul(sub(b, a), t))
          r = :math.sqrt(hd(p) * hd(p) + Enum.at(p, 2) * Enum.at(p, 2))

          if t >= 0 && t <= 1 && r >= inner && r <= outer,
            do: [%{wall: w.id, point: p, annulus_y: y}],
            else: []
        end
      end)
    end)
  end

  defp acquired_revision(nil), do: -1

  defp acquired_revision(f) do
    case Regex.run(~r/completion-(\d+)-footing$/, f["id"]) do
      [_, n] -> String.to_integer(n)
      _ -> -1
    end
  end

  defp sample(points, t, width) do
    derivative = derivative(points, t)
    tangent = unit(derivative)
    n = unit(sub(width, mul(tangent, dot(width, tangent))))
    %{point: bezier(points, t), tangent: tangent, width: n}
  end

  defp uv([a, b, c, d], u, v) do
    if v >= u,
      do: add(add(mul(a, 1 - v), mul(b, v - u)), mul(c, u)),
      else: add(add(mul(a, 1 - u), mul(c, v)), mul(d, u - v))
  end

  defp poly_length(ps),
    do:
      Enum.zip(ps, tl(ps))
      |> Enum.map(fn {a, b} -> :math.sqrt(dot(sub(b, a), sub(b, a))) end)
      |> Enum.sum()

  defp bezier([a, b, c, d], t),
    do:
      add(
        add(mul(a, :math.pow(1 - t, 3)), mul(b, 3 * (1 - t) * (1 - t) * t)),
        add(mul(c, 3 * (1 - t) * t * t), mul(d, t * t * t))
      )

  defp derivative([a, b, c, d], t),
    do:
      add(
        add(mul(sub(b, a), 3 * (1 - t) * (1 - t)), mul(sub(c, b), 6 * (1 - t) * t)),
        mul(sub(d, c), 3 * t * t)
      )

  defp rect(c, u, v),
    do: [add(add(c, u), v), add(sub(c, u), v), sub(sub(c, u), v), add(sub(c, v), u)]

  defp square([x, y, z], r),
    do: [
      [x - r, y, z - r],
      [x + r, y, z - r],
      [x + r, y, z + r],
      [x - r, y, z + r],
      [x - r, y, z - r]
    ]

  defp line(id, points, color), do: %{id: id, points: points, color: color, kind: "emergence"}
  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp mul(a, n), do: Enum.map(a, &(&1 * n))
  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp cross([x, y, z], [u, v, w]), do: [y * w - z * v, z * u - x * w, x * v - y * u]
  defp unit(a), do: mul(a, 1 / max(1.0e-12, :math.sqrt(dot(a, a))))
end
