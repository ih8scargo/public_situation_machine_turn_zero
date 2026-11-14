defmodule PublicSituationMachineTurnZero.Workshop.StringRibbonGeometry do
  # Geometry reconciliation: Source triangles retained; Ground Table / legacy Seat placements are historical, not revised ONE/THREE registrations.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Inspectable provisional paths. Source frames and topology qualifications accompany every significant object."
  alias PublicSituationMachineTurnZero.Workshop.{ComingAboardMachine, SnailBody, StringRibbon}

  def objects(s) do
    r = ComingAboardMachine.registration()
    square = r.here ++ [hd(r.here)]
    next_center = SnailBody.arc_point(1 / 6)

    next =
      Enum.map(
        [
          [-0.13, 0, -0.13],
          [0.13, 0, -0.13],
          [0.13, 0, 0.13],
          [-0.13, 0, 0.13],
          [-0.13, 0, -0.13]
        ],
        fn offset -> add(next_center, offset) |> ComingAboardMachine.snail_point() end
      )

    base = [
      object(
        "here",
        "HERE square",
        "Persistent SIX × SIX; FROM seated Human",
        "REFERENCE · never replaced by NEXT",
        square
      ),
      object(
        "next",
        "NEXT square",
        "Differentiated TOWARD; not HERE",
        "REFERENCE · preserved SnailWeave NEXT marker, not a new full CUBICAL",
        next
      ),
      object(
        "place",
        "THIS ONE STANDINGING LANDINGING",
        "Circular seated locality FROM HERE",
        "REFERENCE",
        circle([0, 0, 0], 3)
      ),
      object(
        "table",
        "RE-SURFACING Table",
        "Shared seated Table/Craft center · THROUGH HERE",
        "REFERENCE · stationary planar furnishing",
        circle(r.table_center, r.table_radius)
      ),
      object(
        "aperture",
        "Central Table aperture",
        "THROUGH Table center",
        "REFERENCE · physical bore fit unresolved",
        circle(r.table_center, r.aperture_radius)
      ),
      object(
        "monitor",
        "Real fixed monitor",
        "Projectioning TOWARD Human FROM OVER ACROSS",
        "REFERENCE · physically stationary",
        r.monitor.points ++ [hd(r.monitor.points)]
      ),
      object(
        "real-computer",
        "Real Terrestrial Computer locality",
        "Registered through fixed monitor; body is not transported",
        "REFERENCE marker · hardware envelope not appointed",
        [add(r.monitor.center, [-0.1, 0, 0]), add(r.monitor.center, [0.1, 0, 0])]
      ),
      object(
        "main-projection",
        "Main Projectioning Thing",
        "Fixed monitor FROM OVER ACROSS TOWARD seated Human",
        "REFERENCE bearing · optical fit not inferred",
        [r.monitor.center, [0, 0, 2]]
      ),
      object(
        "keyboard",
        "Keyboard / Inkwell wedge reference",
        "Groundward TOWARD Table; not an appointed material pipeline",
        "PROVISIONAL incidence",
        [[-0.6, 0, 2.5], [0.6, 0, 2.5], [0, 0, 0], [-0.6, 0, 2.5]]
      ),
      object(
        "human",
        "Human's FROM Standing",
        "Ordinary seated locality · never transported",
        "REFERENCE marker; not a body model",
        [[0, 0, 2], [0, 0.6, 2]]
      ),
      object(
        "seat",
        "Traversaling Seat",
        "Pocketing return THROUGH position TWO",
        "REFERENCE · distinct from physical chair",
        [[-0.4, 0, 2], [0.4, 0, 2]]
      ),
      object(
        "cob",
        "One COB",
        "UP FROM OUT OF Table · two cooperating offices",
        "REFERENCE · ONE extent",
        r.cob
      ),
      object(
        "local-extent",
        "XT TO XT",
        "Invariant ZERO-TO-ONE local extent",
        "REFERENCE · not the rising course's arclength",
        r.xt
      ),
      object(
        "seam-three",
        "Seam of THREE",
        "Middle of SIX Groundward square",
        "REFERENCE · candidate manifold incidence",
        [[-3, 0, 0], [3, 0, 0]]
      ),
      object(
        "post-six",
        "SIX-extent upper registration",
        "UP FROM Ground THROUGH Table center",
        "REFERENCE · no acquired Footing",
        [[0, 0, 0], [0, 6, 0]]
      ),
      object(
        "bobbin",
        "Bobbining Stringing Thing / cushioned joint",
        "THROUGHBY Table; distinct from Pocketing",
        "PROVISIONAL joint marker · no occupied profile",
        circle([0, 0, 0], 0.38)
      )
    ]

    active =
      case s.course do
        "ribbon" ->
          if s.material,
            do: [
              object(
                "material",
                "String-Ribbon",
                "Furnishing provides; Traversaling takes same source",
                s.material.status <> " · Groundward connector PROVISIONAL",
                StringRibbon.material_course(s),
                s.material.id
              )
            ],
            else: []

        "square-lock" ->
          [
            object(
              "square-lock",
              "Inaugural square-locking manifold",
              "Monitor TOWARD seated Human; UP AROUND ABOUT computer backside",
              "PROVISIONAL two-sided open material sweep; topology unappointed",
              square_lock()
            )
          ]

        "rising" ->
          [
            object(
              "rising",
              "XT TO XT rising presentation",
              "Groundward THROUGH Table/Craft center TOWARD SIX",
              "PROVISIONAL curved presentation · invariant local extent retained separately",
              rising()
            )
          ]

        "pocketing" ->
          [
            object(
              "pocketing",
              "Pocketing FROM SIX post",
              "TOWARD HERE; AROUND ABOUT; return THROUGH Seat → next YT TOWARD YT",
              "PROVISIONAL Snail Shell gathering · 1½ turns plus entry/return; not acquired",
              pocketing()
            )
          ]

        "triangles" ->
          triangles(s.fold)
      end

    for o <- base ++ active do
      trace =
        if o.id in ~w(material square-lock rising pocketing),
          do: prefix(o.points, s.progress),
          else: o.points

      Map.merge(o, %{
        trace: trace,
        drawing: project_path(trace, s.view),
        length: length_of(o.points)
      })
    end
  end

  def square_lock do
    interpolate([[0, 3, 3], [0, 0, 2], [0, 3, 5], [0, 6, 3], [0, 3, 3]])
  end

  def rising, do: interpolate([[0, 0, 2], [0, 0, 0], [-0.6, 2, 0], [0.6, 4, 0], [0, 6, 0]])

  def pocketing do
    # Preserve the source 1.5-revolution helix, normalized to a SIX-high comparison envelope.
    shell =
      for i <- 0..144 do
        [x, y, z] = SnailBody.arc_point(i / 144)
        [x * 3 / 0.85, 6 + (y + 0.55) * 4, 2 + z * 3 / 0.85]
      end

    interpolate([[0, 6, 0], [0, 3, 3], [0, 0, 2], hd(shell)]) ++
      tl(shell) ++ tl(interpolate([List.last(shell), [0, 0, 2]]))
  end

  def triangles(fold) do
    a = [-3, 0, -3]
    b = [3, 0, 3]
    root = [3, 0, -3]
    angle = fold * :math.pi() / 2

    tip = [
      -3 + 6 * (0.5 - 0.5 * :math.cos(angle)),
      6 * :math.sqrt(0.5) * :math.sin(angle),
      -3 + 6 * (0.5 + 0.5 * :math.cos(angle))
    ]

    [
      object(
        "xt-triangle",
        "XT-side triangle",
        "FROM WITHIN source square; traced diagonal retained",
        "PROVISIONAL normalized archway fold, not constitutional hinge",
        [a, tip, b, a]
      ),
      object(
        "reciprocal-triangle",
        "Reciprocal retained triangle",
        "Retains square's other half; does not consume HERE",
        "PROVISIONAL source correspondence",
        [a, root, b, a]
      )
    ]
  end

  def faces(o, view) do
    if o.id in ~w(material square-lock rising pocketing) and length(o.trace) > 1 do
      width = if o.id == "square-lock", do: 3.0, else: 0.12

      for [a, b] <- Enum.chunk_every(o.trace, 2, 1, :discard) do
        points = [
          add(a, [-width, 0, 0]),
          add(a, [width, 0, 0]),
          add(b, [width, 0, 0]),
          add(b, [-width, 0, 0])
        ]

        %{world: points, back_world: Enum.reverse(points), drawing: project_path(points, view)}
      end
    else
      []
    end
  end

  def prefix([], _), do: []
  def prefix(points, p), do: SnailBody.prefix(points, length_of(points) * p)

  def length_of(points),
    do:
      Enum.zip(points, tl_or_empty(points))
      |> Enum.map(fn {a, b} ->
        :math.sqrt(Enum.zip_with(a, b, &((&1 - &2) * (&1 - &2))) |> Enum.sum())
      end)
      |> Enum.sum()

  defp tl_or_empty([]), do: []
  defp tl_or_empty(points), do: tl(points)

  def project_path(points, view),
    do:
      Enum.map_join(points, " ", fn p -> project(p, view) |> Enum.map_join(",", &to_string/1) end)

  def project([x, y, z], view) do
    case view do
      "flat" -> [250 + x * 32, 350 - y * 32 - z * 7]
      "top" -> [250 + x * 32, 230 + z * 32]
      "tunneling" -> [250 + z * 32, 350 - y * 32 + x * 4]
      "roundabout" -> [250 + (x - z) * 24, 350 - y * 32 + (x + z) * 6]
    end
  end

  defp interpolate(points) do
    Enum.chunk_every(points, 2, 1, :discard)
    |> Enum.with_index()
    |> Enum.flat_map(fn {[a, b], n} ->
      for i <- if(n == 0, do: 0, else: 1)..16,
          do: lerp(a, b, i / 16 * (i / 16) * (3 - 2 * i / 16))
    end)
  end

  defp object(id, name, office, status, points, material \\ nil),
    do: %{id: id, name: name, office: office, status: status, points: points, material: material}

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp lerp(a, b, t), do: Enum.zip_with(a, b, &(&1 + (&2 - &1) * t))

  defp circle(c, r),
    do:
      for(
        i <- 0..64,
        do: add(c, [r * :math.cos(i * :math.pi() / 32), 0, r * :math.sin(i * :math.pi() / 32)])
      )
end
