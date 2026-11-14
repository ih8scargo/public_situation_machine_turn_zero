defmodule PublicSituationMachineTurnZero.Workshop.SnailWeaveGeometry do
  # R21–R23: historical DOWN UNDER computer/passage is apparatus-source provenance,
  # not automatic FROM DOWN UNDER acquisition for newly staged material.
  # See docs/architecture/geometry/table-crossing-staging.md and un-vanishing-aperture.md.
  # Geometry reconciliation: Source Seat/relay coordinates and zero-width ray hits do not prove revised finite passage or Craft fit.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Registration layers on the existing SnailBody, not a second room. All new fittings are bounded proposals."
  alias PublicSituationMachineTurnZero.Workshop.{SnailBody}

  def model(s, pose \\ 90, q \\ 0, look \\ 0, interface \\ "alongside", scrub \\ 0.0) do
    b = SnailBody.model(s["body"], pose, q)

    seat =
      s["seat"] ||
        %{
          "eye" => [0, Enum.at(SnailBody.model(s["body"]).within_eye, 1), 0],
          "forward" => [0, -1, 0]
        }

    eye = seat["eye"]
    forward = seat["forward"]
    [fx, fy, fz] = forward
    angle = look * :math.pi() / 180

    bearing = [
      fx * :math.cos(angle) + fz * :math.sin(angle),
      fy,
      -fx * :math.sin(angle) + fz * :math.cos(angle)
    ]

    page = [-0.55, -0.65, 1.4]
    frame = SnailBody.model(s["body"])
    receiver = add(frame.fold.tunnel_axis, scale(frame.fold.normal, 0.5))
    source = [0, -2.25, 0]
    run_start = [hd(eye), -2.25, 2.0]
    terminal = [hd(eye), -2.25, 6.0]

    bellows =
      for i <- 0..48,
          do:
            bezier(
              [terminal, add(terminal, [0, 2.8, 0]), add(receiver, [0, 1.0, 1.5]), receiver],
              i / 48
            )

    first =
      for i <- 0..32, do: [-0.48 + 0.96 * i / 32, -0.15 + 0.8 * :math.sin(i * :math.pi() / 32), 0]

    second =
      for i <- 0..32, do: [0, -0.15 + 0.9 * :math.sin(i * :math.pi() / 32), -0.48 + 0.96 * i / 32]

    held = s["active"] != nil
    needle = Enum.find(b.lines, &(&1.id == "Quilling-Stitching-Needle"))

    brace =
      if s["brace"] == "bracing flat page",
        do: [[-0.48, -0.15, 0], [0.2, 0.5, 0]],
        else: needle.points

    surfaces =
      Enum.reject(
        b.surfaces,
        &(&1.kind == "intermediate-shield" or &1.id in ["corner-fold-plane", "cabinet-1"])
      )

    lines =
      Enum.reject(
        b.lines,
        &(&1.id in ["Quilling-Stitching-Needle", "spindle", "side-AROUND-THE-CORNER"] or
            String.starts_with?(&1.id, "projection-ray"))
      )

    lines =
      lines ++
        [
          line("zeroeth-first-arch-XT-TOWARD-YT", first, "#5eead4"),
          line(
            "zeroeth-second-arch-UP-OVER-ACROSS",
            second,
            if(held, do: "#fbbf24", else: "#69849b")
          ),
          line("diagonal-brace-to-Quilling-Needle", brace, "#fbbf24"),
          line(
            "page-centered-axle",
            [add(page, [0, 0, -0.2]), add(page, [0, 0, 0.2])],
            "#e2e8f0"
          ),
          line("loading-deck-to-run-CONFLICT", [source, run_start], "#fb7185"),
          line("long-directed-FRONT", [run_start, terminal], "#5eead4"),
          line("bellows-UP-reading", bellows, "#c4b5fd"),
          line("receiver-to-monitor-registration", [receiver, page], "#8098ad"),
          line("seated-eye-line-of-regard", [eye, receiver], "#e2e8f0"),
          line("seat-datum-six-wide", [add(eye, [-0.5, 0, 0]), add(eye, [0.5, 0, 0])], "#d8b4fe"),
          line("seat-datum-six-high", [add(eye, [0, 0, -0.5]), add(eye, [0, 0, 0.5])], "#d8b4fe"),
          line(
            "THIS-NEXT-APPROACHING-LANDINGING",
            square(SnailBody.arc_point(1 / 6), 0.13),
            "#fbbf24"
          ),
          line("YT-own-HERE", square([-0.67, -0.55, 0], 0.13), "#f472b6")
        ]

    lines =
      if s["pointing"],
        do:
          lines ++
            [
              line(
                "Fishing-Pole-Pointing-able-Thing",
                [eye, s["pointing"]["target"]],
                "#fbbf24"
              )
            ],
        else: lines

    lines =
      if Map.has_key?(s["offices"], "xt"),
        do:
          lines ++
            [
              line(
                "XT-Furnishing-COB-ALONGSIDE",
                [add(eye, [-0.16, 0.04, 0]), add(eye, [-0.08, 0.04, 0])],
                "#5eead4"
              )
            ],
        else: lines

    lines =
      if Map.has_key?(s["offices"], "yt"),
        do:
          lines ++
            [
              line(
                "YT-Traversaling-office-ALONGSIDE",
                [add(eye, [0.08, 0.04, 0]), add(eye, [0.16, 0.04, 0])],
                "#fbbf24"
              ),
              line(
                "candidate-YT-own-HERE-approach",
                [[-0.67, -0.55, 0], SnailBody.arc_point(0)],
                "#69849b"
              )
            ],
        else: lines

    deck = Enum.find(b.surfaces, &(&1.id == "down-under-computer-0")).points
    source_plane = Enum.find(b.surfaces, &(&1.id == "down-under-computer-1")).points

    lines =
      lines ++
        [
          line("Loading-Deck-contact-registration", deck ++ [hd(deck)], "#67b6dd"),
          line("real-Pretend-TC-source-plane", source_plane ++ [hd(source_plane)], "#67b6dd"),
          line("appointed-Craft-FRONT", [eye, add(eye, [0, 0, 0.4])], "#fbbf24")
        ]

    t =
      if s["active"],
        do: Enum.find(s["turns"], &(&1["id"] == s["active"]["turn"])),
        else: List.last(s["turns"])

    material =
      t && t["material"] && Enum.find(s["body"]["material"], &(&1["id"] == t["material"]))

    stations =
      if t && material,
        do: [
          {"cubical", SnailBody.arc_point(hd(t["interval"]))},
          {"loading-deck", source},
          {"groundward", terminal},
          {"upward-relay", Enum.at(bellows, 24)},
          {"receiver", receiver},
          {"monitor", page},
          {"encounter", receiver}
        ],
        else: []

    tags =
      Enum.map(stations, fn {stage, p} ->
        %{
          id: material["id"],
          stage: stage,
          point: p,
          text: material["text"],
          turn: t["id"],
          status:
            if(
              stage == "encounter" && !(s["active"] && s["active"]["turn"] == t["id"]) &&
                !Enum.any?(s["completions"], &(&1["turn"] == t["id"])),
              do: "appointed destination; encounter pending",
              else: "registered presentation; optical completion not claimed"
            )
        }
      end)

    lines =
      Enum.reduce(s["turns"], lines, fn turn, out ->
        [a, z] = turn["interval"]
        points = Enum.map(0..24, &SnailBody.arc_point(a + (z - a) * &1 / 24))
        f = SnailBody.arc_frame((a + z) / 2)

        out ++
          [
            line(turn["id"] <> "-furnished-arc", points, "#fbbf24"),
            line(
              turn["id"] <> "-CUBICAL-tangent",
              [f.point, add(f.point, scale(f.tangent, 0.16))],
              "#5eead4"
            ),
            line(
              turn["id"] <> "-CUBICAL-radial",
              [f.point, add(f.point, scale(f.radial, 0.16))],
              "#c4b5fd"
            )
          ]
      end)

    lines =
      if t do
        [a, z] = t["interval"]
        progress = if s["active"], do: s["active"]["position"] / 2, else: scrub
        p = SnailBody.arc_point(a + (z - a) * progress)

        lines ++
          [
            line(
              "YT-Traversaling-COB-outreading",
              [add(p, [-0.04, 0, 0]), add(p, [0.04, 0, 0])],
              "#e2e8f0"
            )
          ]
      else
        lines
      end

    # The interface sheet is a presentation fold about the appointed radial hinge,
    # never a transform of the furnished arc, material coordinates or HERE identities.
    angle = if interface == "alongside", do: 0.0, else: :math.pi() / 2
    interface_quarter = if t, do: t["quarter"], else: 0
    hinge = SnailBody.model(s["body"], 90, interface_quarter).fold.tunnel_axis
    r = SnailBody.arc_frame(interface_quarter / 6).radial
    transverse = [-Enum.at(r, 2), 0, hd(r)]

    sheet =
      Enum.map([{0.0, 0.0}, {0.4, 0.0}, {0.4, 0.3}, {0.0, 0.3}], fn {u, v} ->
        add(
          hinge,
          add(
            scale(r, u),
            add([0, v * :math.sin(angle), 0], scale(transverse, v * :math.cos(angle)))
          )
        )
      end)

    surfaces =
      surfaces ++
        [
          %{
            id: "groundward-terminal-plane",
            points: rect(terminal, [0.35, 0, 0], [0, 0.25, 0]),
            color: "#5eead4",
            kind: "projection"
          },
          %{
            id: "staging-receiver",
            points: rect(receiver, [0.08, 0, 0], [0, 0, 0.08]),
            color: "#fbbf24",
            kind: "projection"
          },
          %{id: "radial-interface-fold", points: sheet, color: "#c4b5fd", kind: "presentation"}
        ]

    [far_mouth, near_mouth] = b.fold[:YT_to_XT]
    toward_here = sub(near_mouth, far_mouth)
    inside = add(near_mouth, scale(toward_here, 0.25))
    rim_offset = sub(hd(b.fold.mouth), near_mouth)
    off_axis = add(inside, scale(rim_offset, 1.5))
    tunnel_walls = Enum.filter(surfaces, &(&1.kind == "tunnel"))
    center_hits = ray_hits(tunnel_walls, far_mouth, inside)
    control_hits = ray_hits(tunnel_walls, far_mouth, off_axis)
    occupied_hits = ray_hits(surfaces, far_mouth, inside)

    lines =
      lines ++
        [
          line("YT-inbound-centerline", [far_mouth, near_mouth, inside], "#22d3ee"),
          line("YT-inbound-wall-control", [far_mouth, off_axis], "#fb7185")
        ]

    crossing = %{
      first: %{
        id: "zeroeth-first-arch",
        relation: "XT TOWARD YT; braces ordinary flat page",
        brace: "diagonal-brace-to-Quilling-Needle",
        needle_ancestry: s["brace"],
        YT_available_through_Human_words: s["yt"]
      },
      second: %{
        id: "zeroeth-second-arch",
        relation: "UP OVER ACROSS; holds transverse Regarding UP because TC is taking",
        held_UP: held,
        position: s["active"] && s["active"]["position"],
        mode: s["active"] && s["active"]["mode"],
        turn: s["active"] && s["active"]["turn"]
      },
      monitor_registration: %{
        cubical_extents: [6, 6, 6],
        inward_extents: 3,
        seated_locality: 2,
        monitor_pivot: 3,
        table_working_bearing: 4,
        presentation:
          "Flat monitor pivots into horizontal roundabout Regarding in the pretend construction",
        world_transform: :unconfirmed
      },
      yt_through: %{
        relation: "YT TOWARD YT from OVER ACROSS THERE toward standing FROM WITHIN HERE",
        status: :candidate,
        piping: :unregistered,
        clearance: :sketch_clearance_unverified,
        probe: %{
          far_mouth: far_mouth,
          near_mouth: near_mouth,
          inside_sample: inside,
          center_wall_hits: center_hits,
          control_wall_hits: control_hits,
          displayed_face_hits: occupied_hits
        },
        here_receipt: :unappointed,
        qualification:
          "Register both mouths and the receiving locality in one frame. Check the course against the folded enclosure and retained triangle before attaching strings or transferring material."
      },
      ceiling:
        "Both arches are Projectioning Crossing bearingings; geometric XT/YT are not the office identities"
    }

    clearance = %{
      method:
        "analytic conservative radial bounds for every fold 0..90 and all six purchases; not only the displayed pose",
      swept_radial_bound: 0.85 + 0.18 + 0.33 + 0.35,
      run_front_min: 2.0,
      long_run_sweep_margin: 2.0 - (0.85 + 0.18 + 0.33 + 0.35),
      long_run_cabinet_margin: 2.0 - 1.45,
      ring_cabinet_margin: 1.45 - (0.85 + 0.18 + 0.33),
      wedging_table_support_vertical_margin: -0.2 - (-0.55 + 0.33),
      tunnel_computer_vertical_margin:
        -0.55 - 5 * 0.25 - :math.sqrt(0.22 * 0.22 + 0.35 * 0.35) - -2.25,
      source_lead_conflict: %{
        surface: "cabinet front Z=1.45; no appointed opening",
        point: [hd(eye) * 1.45 / 2, -2.25, 1.45]
      },
      fit:
        "LONG RUN outside sweep; source lead intersects cabinet; full relay/support assembly NOT physically fitted",
      sight: %{
        eye_inside_existing_wedging: true,
        radius_margin: 0.77 - 0.67,
        aperture_upward_margin: 0.24,
        verified_pose:
          "registered 90-degree reference; arbitrary AROUND ABOUT looks may meet the folds",
        straight_to_exit:
          "central Snail void to receiver; ceiling through existing centered table opening, no added opaque pole",
        monitor_optics:
          "registration witness only; receiver-to-monitor physical optical clearance unresolved"
      }
    }

    result =
      Map.merge(b, %{
        surfaces: surfaces,
        lines: lines,
        tags: tags,
        within_eye: eye,
        within_toward: add(eye, scale(bearing, 0.5)),
        reference_arc: SnailBody.reference_arc(),
        noticings: [
          %{
            object: "zeroeth-first-arch-XT-TOWARD-YT",
            point: Enum.at(first, 8),
            text: "Arch I · XT TOWARD YT",
            color: "#5eead4"
          },
          %{
            object: "zeroeth-second-arch-UP-OVER-ACROSS",
            point: Enum.at(second, 8),
            text:
              if(held, do: "Arch II · holds UP for TC taking", else: "Arch II · UP OVER ACROSS"),
            color: if(held, do: "#fbbf24", else: "#c4b5fd")
          }
        ],
        landinging_registration: %{
          human_here: "HERE-persistent-square",
          standing_circle: "standing-landinging",
          common_center: [0, 0, 0],
          square_half: 0.7,
          circle_radius: 0.48,
          next: %{id: "THIS-NEXT-APPROACHING-LANDINGING", center: SnailBody.arc_point(1 / 6)},
          yt_here: %{id: "YT-own-HERE", center: [-0.67, -0.55, 0]},
          identities_substituted: false
        },
        instrumentation: %{
          status: "Earlier shield/mirror hypotheses are not appointed physical components",
          source: "existing planar Projection.model relationship remains unchanged",
          representation: "directed source/terminal/bellows/receiver registrations"
        },
        crossing: crossing,
        seat: %{
          lock: s["seat"],
          reference: [6, 6],
          datum: [3, 3],
          world_eye: eye,
          unit_scale: 1 / 6,
          front: [0, 0, 1],
          front_source: "appointed Craft from ordinary monitor-plane normal, not screen axes",
          page_center: page,
          axle: "reference line at page center; Snail wedging is the viewing cylinder"
        },
        projection_relay: %{
          loading_deck: source,
          pretend_real_TC: "existing DOWN UNDER computer representation",
          front: [0, 0, 1],
          run: [run_start, terminal],
          groundward: terminal,
          un_vanishing: %{
            point: terminal,
            meaning:
              "proposed un-vanishing in FRONT; a registration witness, not a new constitutional operation"
          },
          bellows: bellows,
          exit: frame.fold.far,
          receiver: receiver,
          pretend_pretend_TC:
            "one staging registration in furnished CUBICAL frame, not a second constitutional TC",
          identity: material && material["id"],
          registrations:
            Enum.map(stations, fn {stage, point} ->
              origin = SnailBody.arc_point(hd(t["interval"]))
              offset = sub(point, origin)

              %{
                material: material["id"],
                turn: t["id"],
                stage: stage,
                from_point: origin,
                to_point: point,
                matrix: [
                  [1, 0, 0, hd(offset)],
                  [0, 1, 0, Enum.at(offset, 1)],
                  [0, 0, 1, Enum.at(offset, 2)],
                  [0, 0, 0, 1]
                ],
                meaning: "registered presentation translation, not a completed optical projector"
              }
            end),
          stages: Enum.map(stations, fn {stage, point} -> %{stage: stage, point: point} end)
        },
        clearances: clearance,
        separation: %{
          intermediate:
            "relationship retained; previous shield/mirror are not appointed physical components",
          direct_reach: "not established by this schematic projection relay"
        },
        interface: %{
          mode: interface,
          hinge: hinge,
          angle: angle,
          source: "same radial wedging / octagonal bearing ancestry",
          constitutional_points_transformed: false
        },
        material: material,
        offices: s["offices"],
        status:
          "One existing Snail House body with proposed integrated registrations; clearances and physical conflicts disclosed"
      })

    physical =
      Enum.reject(
        frame.surfaces,
        &(&1.kind == "intermediate-shield" or &1.id in ["corner-fold-plane", "cabinet-1"])
      )

    Map.put(result, :sight_tests, %{
      scope:
        "zero-width segments against actual reference-pose surface triangles; no optical or bodily-clearance claim",
      upward_to_ceiling: ray_hits(physical, eye, [0, 0.9, 0]),
      toward_receiver: ray_hits(physical, eye, receiver),
      inspection_pose_receiver: ray_hits(surfaces, eye, receiver)
    })
  end

  def ray_hits(surfaces, a, b) do
    direction = sub(b, a)

    Enum.flat_map(surfaces, fn s ->
      triangles =
        Enum.chunk_every(tl(s.points), 2, 1, :discard)
        |> Enum.map(fn [v, w] -> [hd(s.points), v, w] end)

      hits =
        Enum.flat_map(triangles, fn [v0, v1, v2] ->
          e1 = sub(v1, v0)
          e2 = sub(v2, v0)
          h = cross(direction, e2)
          det = dot(e1, h)

          if abs(det) < 1.0e-10 do
            []
          else
            inv = 1 / det
            shift = sub(a, v0)
            u = inv * dot(shift, h)
            q = cross(shift, e1)
            v = inv * dot(direction, q)
            t = inv * dot(e2, q)

            if u >= -1.0e-9 && v >= -1.0e-9 && u + v <= 1 + 1.0e-9 && t > 1.0e-7 &&
                 t < 1 - 1.0e-7,
               do: [%{object: s.id, parameter: t, point: add(a, scale(direction, t))}],
               else: []
          end
        end)

      Enum.uniq_by(hits, &Float.round(&1.parameter, 8))
    end)
  end

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp cross([x, y, z], [u, v, w]), do: [y * w - z * v, z * u - x * w, x * v - y * u]

  defp line(id, points, color), do: %{id: id, points: points, color: color, kind: "integration"}

  defp square([x, y, z], r),
    do: [
      [x - r, y, z - r],
      [x + r, y, z - r],
      [x + r, y, z + r],
      [x - r, y, z + r],
      [x - r, y, z - r]
    ]

  defp rect(c, u, v),
    do: [add(add(c, u), v), add(sub(c, u), v), sub(sub(c, u), v), add(sub(c, v), u)]

  defp bezier([a, b, c, d], t),
    do:
      for(
        i <- 0..2,
        do:
          :math.pow(1 - t, 3) * Enum.at(a, i) + 3 * :math.pow(1 - t, 2) * t * Enum.at(b, i) +
            3 * (1 - t) * t * t * Enum.at(c, i) + t * t * t * Enum.at(d, i)
      )

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp scale(a, n), do: Enum.map(a, &(&1 * n))
end
