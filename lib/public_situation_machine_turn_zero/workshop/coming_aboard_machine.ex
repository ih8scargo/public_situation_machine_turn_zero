defmodule PublicSituationMachineTurnZero.Workshop.ComingAboardMachine do
  @moduledoc "Extent registration of the inherited tuple, Snail body and monitor. No acquisition operation."
  alias PublicSituationMachineTurnZero.{TupleProjectioning, Architecture.CrossingRehearsal}
  alias PublicSituationMachineTurnZero.Workshop.SnailBody

  def registration do
    body = SnailBody.model(SnailBody.new())
    monitor = Enum.find(body.surfaces, &(&1.id == "ordinary-flat-monitor"))
    center = centroid(monitor.points)

    %{
      version: "coming-aboard-common-machine-v1",
      tuple: TupleProjectioning.table(),
      unit: "CUBICAL extent; not physical measurement",
      ground: square(0, 3),
      cube: for(y <- [0, 6], p <- square(y, 3), do: p),
      here: square(0, 3),
      place_center: [0, 0, 0],
      place_radius: 3,
      table_center: [0, 0, 0],
      table_radius: 1.5,
      table_volume: 0,
      aperture_radius: 0.24 * 1.5 / 1.4,
      axle: [[0, 0, 0], [0, 6, 0]],
      cob: [[0, 0, 0], [0, 1, 0]],
      traversaling_seat: [0, 0, 2],
      craft_seat: [0, 6, 2],
      physical_seat: "ordinary seated Human FROM HERE; never moved by a presentation",
      monitor: %{
        id: monitor.id,
        points: Enum.map(monitor.points, &monitor_point(&1, center)),
        normal: [0, 0, -1],
        center: [0, 3, 3]
      },
      monitor_source: %{points: monitor.points, center: center},
      xt: [[-3, 0, 0], [-2, 0, 0]],
      source: %{
        tuple: "priv/tuple/canonical_tuple_positions.md",
        aperture: "CrossingRehearsal.point/1",
        body: "SnailBody.model/1",
        constraints: "SnailFurnishingConstraints.model/2"
      }
    }
  end

  # An extent frame, not a modification of source meshes: the inherited 1.4 HERE side is SIX.
  def snail_point([x, y, z]), do: [x * 6 / 1.4, y * 6 / 1.4, z * 6 / 1.4]

  def monitor_point([x, y, z], [cx, cy, cz]),
    do: [-(x - cx) * 6 / 1.4, 3 + (y - cy) * 6 / 1.4, 3 - (z - cz) * 6 / 1.4]

  # Reuse the inherited paired-aperture course over the XT-side 45-degree bearing.
  # U and inscription frame use the same tangent; neither makes a full revolution.
  def road(t) do
    [x, _, z] = CrossingRehearsal.point(t / 2)
    [-3 + x * 6 / (1.6 * :math.pi() / 4), 3, z * 6 / (1.6 * :math.pi() / 4)]
  end

  def tangent(t) do
    a = t * :math.pi() / 4
    [:math.cos(a), 0, :math.sin(a)]
  end

  def u(t) do
    c = road(t)
    [x, _, z] = tangent(t)
    across = [-z, 0, x]

    for {w, h} <- [{-0.6, 0.6}, {-0.6, -0.6}, {0.6, -0.6}, {0.6, 0.6}],
        do: add(c, add(scale(across, w), [0, h, 0]))
  end

  def across(t) do
    [x, _, z] = tangent(t)
    [-z, 0, x]
  end

  def bearing(t), do: [add(road(t), scale(tangent(t), -1)), add(road(t), scale(tangent(t), 1))]
  def standing_string, do: [[0, 0, 2], [-3, 0, 0], [-3, 3, 0]]

  def scene(s) do
    r = registration()
    t = s.road_progress
    table = circle(r.table_center, r.table_radius)
    aperture = circle(r.table_center, r.aperture_radius)
    body = SnailBody.model(s.needle, 90, s.wedge)
    native_wedge = Enum.find(body.surfaces, &(&1.kind == "wedging"))

    lines = [
      item(
        "place-circle",
        circle(r.place_center, r.place_radius),
        "Place circle · one registered locality",
        "place"
      ),
      item("ground", r.ground ++ [hd(r.ground)], "Groundward · SIX × SIX", "ground"),
      item("table", table, "RE-SURFACING Table · seated planar surface", "table"),
      item("aperture", aperture, "Central Table aperture", "aperture"),
      item("axle", r.axle, "Square axle · SIX extents", "axis"),
      item("cob", r.cob, "One COB · ONE extent UP FROM OUT OF Table", "cob"),
      item(
        "monitor",
        r.monitor.points ++ [hd(r.monitor.points)],
        "Fixed monitor face",
        "monitor"
      ),
      item("xt", r.xt, "XT TO XT · ZERO-TO-ONE", "extent"),
      item("u", u(t), "Inner U follows rail curvature", "u"),
      item("over-across", bearing(t), "OVER ACROSS THROUGH U center", "bearing"),
      item(
        "projection",
        [road(0.5), r.monitor.center],
        "Projectioning TOWARD fixed monitor face",
        "projection"
      ),
      item(
        "rail",
        Enum.map(0..32, &road(&1 / 32)),
        "Inherited CUBICAL rail-line curvature",
        "rail"
      ),
      item("seat-two", seat(r.traversaling_seat), "Traversaling Seat · position TWO", "seat"),
      item("craft-seat-six", seat(r.craft_seat), "Traversaling Craft Seat · height SIX", "seat"),
      item("wedge", Enum.map(native_wedge.points, &snail_point/1), native_wedge.id, "wedge")
    ]

    lines =
      lines ++
        [
          item(
            "seat-mount",
            [r.traversaling_seat, r.craft_seat],
            "Craft Seat mounting · SIX above position TWO",
            "seat"
          )
        ]

    lines =
      if s.puffed? do
        envelope =
          Enum.map(0..32, fn i -> hd(u(i / 32)) end) ++
            Enum.map(32..0//-1, fn i -> Enum.at(u(i / 32), 2) end)

        lines ++
          [
            item(
              "puffed-tunnel",
              envelope ++ [hd(envelope)],
              "PUFF-furnished JANUSITE tunnel extent FOR possibility",
              "possibility"
            )
          ]
      else
        lines
      end

    lines =
      if s.machine_open?,
        do:
          lines ++
            [
              item(
                "standing-string",
                standing_string(),
                "Standing String attached THROUGH HERE and XT TO XT",
                "string"
              )
            ],
        else: lines

    lines =
      lines ++
        [
          item(
            "axle-base",
            square(0, 0.5) ++ [hd(square(0, 0.5))],
            "Square axle lower cross-section",
            "axis"
          ),
          item(
            "axle-top",
            square(6, 0.5) ++ [hd(square(6, 0.5))],
            "Square axle upper cross-section",
            "axis"
          )
        ]

    edges =
      for {a, b} <- [
            {0, 1},
            {1, 2},
            {2, 3},
            {3, 0},
            {4, 5},
            {5, 6},
            {6, 7},
            {7, 4},
            {0, 4},
            {1, 5},
            {2, 6},
            {3, 7}
          ],
          do:
            item(
              "cube-#{a}-#{b}",
              [Enum.at(r.cube, a), Enum.at(r.cube, b)],
              "SIX CUBICAL extent",
              "cube"
            )

    Enum.map(lines ++ edges, &Map.put(&1, :projection, points(&1.points, camera(s))))
  end

  def glyphs(s) do
    record = Enum.find(s.needle["material"], &(&1["id"] == s.inscription))

    if record do
      letters = String.graphemes(record["text"])
      count = max(length(letters), 1)

      Enum.with_index(letters, fn glyph, i ->
        t = (i + 0.5) / count

        point =
          if s.machine_view == "flat",
            do: [-1.1 + 2.2 * t, 3, 3],
            else: add(road(s.road_progress), scale(across(s.road_progress), -1.1 + 2.2 * t))

        [x, y] = project(point, camera(s))

        %{
          id: "#{record["id"]}/glyph-#{i}",
          text: glyph,
          x: x,
          y: y,
          point: point,
          material: record["id"],
          visible:
            s.machine_view == "flat" or
              (s.machine_view in ~w(dollside tunnel) and MapSet.member?(s.stitched, record["id"]))
        }
      end)
    else
      []
    end
  end

  defp camera(s) do
    if s.machine_view in ~w(tunnel dollside),
      do: {s.machine_view, s.road_progress},
      else: s.machine_view
  end

  def project(point, {view, t}) do
    delta = Enum.zip_with(point, road(t), &(&1 - &2))
    horizontal = dot(delta, across(t))
    depth = dot(delta, tangent(t))

    if view == "tunnel" do
      d = max(0.5, depth + 4)
      [360 + horizontal * 240 / d, 230 - Enum.at(delta, 1) * 240 / d]
    else
      [360 + horizontal * 50, 230 - Enum.at(delta, 1) * 40 + depth * 10]
    end
  end

  def project([x, y, z], view) do
    case view do
      "flat" ->
        [360 + x * 52, 350 - y * 43]

      "tunnel" ->
        depth = max(0.5, x + 4.5)
        [360 + z * 240 / depth, 230 - (y - 3) * 240 / depth]

      "top" ->
        [360 + x * 52, 220 + z * 35]

      "back" ->
        [360 - x * 52 + z * 12, 350 - y * 43]

      _ ->
        [330 + x * 48 + z * 31, 350 - y * 40 + z * 14]
    end
  end

  def points(points, view),
    do: Enum.map_join(points, " ", fn p -> Enum.map_join(project(p, view), ",", &to_string/1) end)

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp square(y, h), do: [[-h, y, -h], [h, y, -h], [h, y, h], [-h, y, h]]

  defp circle(c, r),
    do:
      for(
        i <- 0..64,
        do: add(c, [r * :math.cos(i * :math.pi() / 32), 0, r * :math.sin(i * :math.pi() / 32)])
      )

  defp seat(c),
    do:
      Enum.map(
        [[-0.3, 0, 0], [0.3, 0, 0], [0.3, 0, 0.4], [-0.3, 0, 0.4], [-0.3, 0, 0]],
        &add(c, &1)
      )

  defp item(id, points, label, kind), do: %{id: id, points: points, label: label, kind: kind}
  defp centroid(points), do: points |> Enum.reduce([0, 0, 0], &add/2) |> scale(1 / length(points))
  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp scale(a, n), do: Enum.map(a, &(&1 * n))
end
