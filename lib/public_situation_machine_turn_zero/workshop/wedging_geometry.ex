defmodule PublicSituationMachineTurnZero.Workshop.WedgingGeometry do
  @moduledoc "Unitless, provisional geometry for the independent Snail House experiment."

  @octagon [{-1, -2}, {1, -2}, {2, -1}, {2, 1}, {1, 2}, {-1, 2}, {-2, 1}, {-2, -1}]
  @root_extension 0.27
  @directions [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]

  def outline, do: @octagon
  def bearing(turn), do: Enum.at(@directions, turn)
  def pillars, do: [{-1.5, -1}, {-0.5, -1}, {0.5, 0}, {1.5, 1}]

  def pillar_projection(axis) do
    pillars()
    |> Enum.map(fn {x, y} -> if axis == :x, do: x, else: y end)
    |> Enum.frequencies()
    |> Enum.sort()
  end

  def bays(turn, locality, depth) do
    for {a, index} <- Enum.with_index(@octagon) do
      b = Enum.at(@octagon, rem(index + 1, 8))
      {x, y} = center = midpoint(a, b)
      {dx, dy} = bearing(turn)

      %{
        id: index,
        local: local?(locality, index, turn, x * dx + y * dy),
        footing: scale(center, 0.91),
        receiving_edge: scale(center, 1 + @root_extension),
        growth: grow(a, b, @root_extension, depth)
      }
    end
  end

  defp local?(:mouth, index, turn, _dot), do: index == 2 * turn
  defp local?(:forward, _index, _turn, dot), do: dot > 0

  defp grow(_a, _b, _step, 0), do: []

  defp grow(a, b, step, depth) do
    outer_a = scale(a, 1 + step)
    outer_b = scale(b, 1 + step)
    seam = midpoint(outer_a, outer_b)

    [[a, b, outer_b, outer_a] | grow(outer_a, seam, step / 2, depth - 1)] ++
      grow(seam, outer_b, step / 2, depth - 1)
  end

  defp midpoint({x, y}, {u, v}), do: {(x + u) / 2, (y + v) / 2}
  defp scale({x, y}, factor), do: {x * factor, y * factor}

  @doc "Shared Round Two geometry. New vertical dimensions and mouths are explicitly unitless hypotheses."
  def room(state) do
    rings = for h <- [0.0, 1.0, 2.0, 3.0], do: Enum.map(outline(), fn {x, z} -> [x, h, z] end)

    panels =
      for i <- 0..7 do
        a = Enum.at(outline(), i)
        b = Enum.at(outline(), rem(i + 1, 8))

        %{
          id: "panel-#{i}",
          bay: i,
          points:
            Enum.map([a, b], fn {x, z} -> [x, 0, z] end) ++
              Enum.map([b, a], fn {x, z} -> [x, 3, z] end),
          status: "PSM-supplied candidate architectural surface; occupancy not assumed",
          appointed:
            Enum.any?(state["confirmed"], fn r ->
              r["parameters"]["bay"] == i or
                case r["parameters"]["layout"] do
                  "next" -> rem(r["parameters"]["bay"] + 1, 8)
                  "previous" -> Integer.mod(r["parameters"]["bay"] - 1, 8)
                  _ -> r["parameters"]["bay"]
                end == i
            end)
        }
      end

    spiral =
      for i <- 0..96 do
        t = i / 96
        position = t * 8
        index = min(7, trunc(position))
        f = position - index
        {x, z} = Enum.at(outline(), index)
        {u, v} = Enum.at(outline(), rem(index + 1, 8))
        [0.91 * (x + (u - x) * f), 2.4 * t, 0.91 * (z + (v - z) * f)]
      end

    pairs =
      Enum.map(state["confirmed"], fn r ->
        pair(r["parameters"]) |> Map.put("id", r["id"]) |> Map.put("status", r["status"])
      end)

    proposal =
      if state["proposal"],
        do:
          pair(state["proposal"]["parameters"])
          |> Map.put("id", state["proposal"]["id"])
          |> Map.put("status", "candidate")

    active =
      if state["active"] do
        entry = Enum.find(state["confirmed"], &(&1["id"] == state["active"]["pair"]))
        geometry = Enum.find(pairs, &(&1["id"] == entry["id"]))
        course = geometry[state["active"]["course"]]

        %{
          point: at_distance(course.centerline, state["active"]["progress"] * course.length),
          course: state["active"]["course"],
          progress: state["active"]["progress"],
          pair: entry["id"]
        }
      end

    %{
      founding: state["founding"],
      version: 1,
      rings: rings,
      panels: panels,
      spiral: spiral,
      here: [[-0.7, 0, -0.7], [0.7, 0, -0.7], [0.7, 0, 0.7], [-0.7, 0, 0.7]],
      landinging: circle([0, 0, 0], 0.48),
      aperture: circle([0, 3, 0], 0.2),
      approach: [[-0.65, 0, 3.65], [-0.45, 0, 2], [0.45, 0, 2], [0.65, 0, 3.65]],
      pairs: pairs,
      proposal: proposal,
      active: active,
      measurements: %{
        four: [[-2, 0.02, 0], [2, 0.02, 0]],
        three: [[-1.5, 0.04, 0], [1.5, 0.04, 0]],
        meaning:
          "FOUR across existing octagon; THREE between existing pillar X extrema. Two Footing records associate with THREE; no physical transfer or RE-STEP performed."
      },
      status:
        "Unitless experimental room, vertical extrusion and spiral bearing rail; not a registered production shell"
    }
  end

  def pair_defaults(bay, layout \\ "same") do
    %{
      "bay" => bay,
      "layout" => layout,
      "radius" => 0.04,
      "lift" => 0.9,
      "ordinary_height" => 0.22
    }
  end

  def valid_pair_parameters?(p) when is_map(p) do
    Enum.sort(Map.keys(p)) == Enum.sort(Map.keys(pair_defaults(0))) and p["bay"] in 0..7 and
      p["layout"] in ~w(same next previous) and
      Enum.all?(
        [{"radius", 0.025, 0.09}, {"lift", 0.7, 1.2}, {"ordinary_height", 0.18, 0.3}],
        fn {k, a, b} -> is_number(p[k]) and p[k] >= a and p[k] <= b end
      )
  end

  def valid_pair_parameters?(_), do: false

  def pair(p) do
    bay = p["bay"]

    upper_bay =
      case p["layout"] do
        "next" -> rem(bay + 1, 8)
        "previous" -> Integer.mod(bay - 1, 8)
        _ -> bay
      end

    spine = for i <- 0..96, do: base_course(i / 96)

    upper =
      Enum.map(spine, fn {plan, profile} ->
        placed(plan, p["radius"] + p["lift"] * profile, upper_bay)
      end)

    # Ordinary inherits the founding upper spine through a rigid bearing map and
    # vertical-profile subtraction; it is never an unrelated tube.
    ordinary =
      Enum.map(spine, fn {plan, profile} ->
        placed(
          plan,
          p["radius"] + p["lift"] * profile - (p["lift"] - p["ordinary_height"]) * profile,
          bay
        )
      end)

    upper_course = surface(upper, p["radius"])
    ordinary_course = surface(ordinary, p["radius"])
    u = Enum.at(upper, 48)
    o = Enum.at(ordinary, 48)
    lower_contact = plus(o, [0, p["radius"], 0])
    upper_contact = plus(u, [0, -p["radius"], 0])
    # Tangency at middle of the level elbow. Pads are actual planes; the ruled web
    # has two triangles when neighboring bearings make a quadrilateral nonplanar.
    pads = [
      %{
        id: "ordinary-upon-plane",
        points: pad(lower_contact, 0.14),
        contact: lower_contact,
        role: "WHAT-FOR UPON ON · ordinary top contact"
      },
      %{
        id: "up-over-upon-plane",
        points: pad(upper_contact, 0.14),
        contact: upper_contact,
        role: "WHAT-FOR UPON ON · UP-OVER underside contact"
      }
    ]

    web = [
      lower_contact,
      plus(lower_contact, [0.1, 0, 0]),
      upper_contact,
      plus(upper_contact, [0.1, 0, 0])
    ]

    clearance = clearance(upper, ordinary, 2 * p["radius"])

    valid_region =
      Enum.all?(
        ordinary_course.rings |> List.flatten() |> Enum.chunk_every(3),
        &reserved?(&1, bay, 0)
      ) and
        Enum.all?(
          upper_course.rings |> List.flatten() |> Enum.chunk_every(3),
          &reserved?(&1, upper_bay, 0)
        )

    differences =
      Enum.zip_with(curvatures(upper), curvatures(ordinary), fn a, b -> abs(a - b) end)

    %{
      "up_over" => upper_course,
      "ordinary" => ordinary_course,
      "parameters" => p,
      "upper_bay" => upper_bay,
      "planes" => pads,
      "web" => [Enum.take(web, 3), [hd(web), Enum.at(web, 2), Enum.at(web, 3)]],
      "curvature_measurements" => %{
        "local_elbow_max_difference" => differences |> Enum.slice(32, 31) |> Enum.max(),
        "whole_course_max_difference" => Enum.max(differences),
        "cross_section_curvature" => 1 / p["radius"]
      },
      "clearance" => clearance,
      "within_reserved" => valid_region,
      "contact_distance" => %{
        "ordinary" => abs(distance(lower_contact, o) - p["radius"]),
        "up_over" => abs(distance(upper_contact, u) - p["radius"])
      },
      "inheritance" => %{
        "common_foundation" =>
          "one HERE-based spine, one bounded 90-degree local elbow, shared return connectors",
        "centerline" =>
          "same plan when same-panel; rigid bearing transfer for neighboring mouths",
        "surface" =>
          "circular swept sections inherit radius and frame construction, not identical full 3D surface curvature",
        "bearing" => "inherited from selected octagonal panel; no unrestricted swivel",
        "UPON" =>
          "tangent pad contact and connecting support-web geometry; structural/load purchase remains unverified",
        "junction" =>
          "both return HERE; shared radius-0.7 junction excluded from inter-course clearance, single Traversaling at a time",
        "three_extent" =>
          "minimum two Footing witnesses associated with measured THREE; no RE-STEP law or operation"
      }
    }
  end

  def available_pair?(p, turn, locality) do
    available = bays(turn, locality, 1) |> Enum.filter(& &1.local) |> Enum.map(& &1.id)

    upper =
      case p["layout"] do
        "next" -> rem(p["bay"] + 1, 8)
        "previous" -> Integer.mod(p["bay"] - 1, 8)
        _ -> p["bay"]
      end

    p["bay"] in available and upper in available
  end

  def conflict_clearance(a, b) do
    for x <- ~w(up_over ordinary), y <- ~w(up_over ordinary), reduce: 1000.0 do
      value ->
        min(
          value,
          clearance(
            a[x].centerline,
            b[y].centerline,
            a["parameters"]["radius"] + b["parameters"]["radius"]
          )
        )
    end
  end

  def at_distance(points, d) do
    segments = Enum.zip(points, tl(points))

    {_remaining, point} =
      Enum.reduce_while(segments, {max(0, d), hd(points)}, fn {a, b}, {remaining, _} ->
        length = distance(a, b)

        if remaining <= length do
          {:halt, {0, plus(a, times(min(1, remaining / max(length, 1.0e-12)), minus(b, a)))}}
        else
          {:cont, {remaining - length, b}}
        end
      end)

    point
  end

  def distance(a, b), do: :math.sqrt(Enum.zip_with(a, b, &((&1 - &2) * (&1 - &2))) |> Enum.sum())

  defp base_course(t) do
    a = [-0.3, 2.15]
    b = [0.1, 2.4]

    cond do
      t <= 1 / 3 ->
        q = t * 3
        {bezier([[0, 0], [-0.3, 0.7], [-0.3, 1.75], a], q), smooth(q)}

      t <= 2 / 3 ->
        q = (t - 1 / 3) * 3
        theta = q * :math.pi() / 2
        {[0.1 - 0.4 * :math.cos(theta), 2.15 + 0.25 * :math.sin(theta)], 1.0}

      true ->
        q = (t - 2 / 3) * 3
        {bezier([b, [0.5, 2.4], [0.7, 0.7], [0, 0]], q), 1 - smooth(q)}
    end
  end

  defp smooth(t), do: t * t * (3 - 2 * t)

  defp bezier([a, b, c, d], t),
    do:
      for(
        i <- 0..1,
        do:
          :math.pow(1 - t, 3) * Enum.at(a, i) + 3 * :math.pow(1 - t, 2) * t * Enum.at(b, i) +
            3 * (1 - t) * t * t * Enum.at(c, i) + t * t * t * Enum.at(d, i)
      )

  defp placed([lateral, radial], height, bay) do
    {a, b} = Enum.at(@octagon, bay)
    {c, d} = Enum.at(@octagon, rem(bay + 1, 8))
    [dx, dz] = unit([(a + c) / 2, (b + d) / 2])
    [radial * dx + lateral * -dz, height, radial * dz + lateral * dx]
  end

  defp curvatures(points) do
    Enum.chunk_every(points, 3, 1, :discard)
    |> Enum.map(fn [a, b, c] ->
      u = minus(b, a)
      v = minus(c, a)

      2 * :math.sqrt(dot(cross(u, v), cross(u, v))) /
        max(1.0e-12, distance(a, b) * distance(b, c) * distance(a, c))
    end)
  end

  defp surface(points, radius) do
    rings =
      points
      |> Enum.with_index()
      |> Enum.map(fn {p, i} ->
        a = Enum.at(points, max(0, i - 1))
        b = Enum.at(points, min(length(points) - 1, i + 1))
        tangent = unit(minus(b, a))
        right = unit(cross(tangent, [0, 1, 0]))
        up = unit(cross(right, tangent))

        for j <- 0..11 do
          theta = 2 * :math.pi() * j / 12

          plus(
            p,
            plus(times(radius * :math.cos(theta), right), times(radius * :math.sin(theta), up))
          )
        end
      end)

    faces =
      for i <- 0..(length(rings) - 2),
          j <- 0..11,
          do: [
            i * 12 + j,
            (i + 1) * 12 + j,
            (i + 1) * 12 + rem(j + 1, 12),
            i * 12 + rem(j + 1, 12)
          ]

    %{
      centerline: points,
      rings: rings,
      faces: faces,
      length:
        Enum.zip(points, tl(points)) |> Enum.map(fn {a, b} -> distance(a, b) end) |> Enum.sum(),
      mouth: Enum.at(points, 32),
      return: List.last(points),
      entrance: hd(points)
    }
  end

  defp clearance(a, b, radii) do
    aa = outside_segments(a)
    bb = outside_segments(b)

    for {x, y} <- aa, {u, v} <- bb, reduce: 1000.0 do
      value -> min(value, segment_distance(x, y, u, v) - radii)
    end
  end

  defp outside_segments(points) do
    Enum.zip(points, tl(points))
    |> Enum.flat_map(fn {a, b} ->
      [x, _, z] = a
      [dx, _, dz] = minus(b, a)
      qa = dx * dx + dz * dz
      qb = 2 * (x * dx + z * dz)
      qc = x * x + z * z - 0.49
      disc = qb * qb - 4 * qa * qc

      roots =
        if qa > 1.0e-14 && disc >= 0,
          do: [(-qb - :math.sqrt(disc)) / (2 * qa), (-qb + :math.sqrt(disc)) / (2 * qa)],
          else: []

      cuts = ([0.0, 1.0] ++ Enum.filter(roots, &(&1 > 0 && &1 < 1))) |> Enum.sort()

      Enum.zip(cuts, tl(cuts))
      |> Enum.flat_map(fn {s, t} ->
        [xx, _, zz] = plus(a, times((s + t) / 2, minus(b, a)))

        if xx * xx + zz * zz >= 0.49 - 1.0e-12,
          do: [{plus(a, times(s, minus(b, a))), plus(a, times(t, minus(b, a)))}],
          else: []
      end)
    end)
  end

  def segment_distance(p, q, r, s) do
    u = minus(q, p)
    v = minus(s, r)
    w = minus(p, r)
    a = dot(u, u)
    b = dot(u, v)
    c = dot(v, v)
    d = dot(u, w)
    e = dot(v, w)
    den = a * c - b * b
    x = if den > 1.0e-14, do: clamp((b * e - c * d) / den), else: 0.0
    y = if c > 1.0e-14, do: (b * x + e) / c, else: 0.0

    {x, y} =
      cond do
        a < 1.0e-14 -> {0.0, if(c > 1.0e-14, do: clamp(e / c), else: 0.0)}
        y < 0 -> {clamp(-d / a), 0.0}
        y > 1 -> {clamp((b - d) / a), 1.0}
        true -> {x, y}
      end

    :math.sqrt(
      dot(plus(w, minus(times(x, u), times(y, v))), plus(w, minus(times(x, u), times(y, v))))
    )
  end

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp clamp(n), do: max(0.0, min(1.0, n))

  defp reserved?([x, y, z], bay, radius) do
    in_room = inside2?({x, z}, @octagon)
    root = hd(Enum.at(bays(0, :forward, 1), bay).growth)
    (in_room or inside2?({x, z}, root)) and y >= -1.0e-9 and y + radius <= 3
  end

  defp inside2?({x, y}, vertices) do
    signs =
      Enum.with_index(vertices)
      |> Enum.map(fn {{a, b}, i} ->
        {c, d} = Enum.at(vertices, rem(i + 1, length(vertices)))
        (c - a) * (y - b) - (d - b) * (x - a)
      end)

    Enum.all?(signs, &(&1 >= -1.0e-8)) or Enum.all?(signs, &(&1 <= 1.0e-8))
  end

  defp pad([x, y, z], r),
    do: [[x - r, y, z - r], [x + r, y, z - r], [x + r, y, z + r], [x - r, y, z + r]]

  defp circle([x, y, z], r),
    do:
      for(
        i <- 0..48,
        do: [
          x + r * :math.cos(2 * :math.pi() * i / 48),
          y,
          z + r * :math.sin(2 * :math.pi() * i / 48)
        ]
      )

  defp plus(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp minus(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp times(s, a), do: Enum.map(a, &(&1 * s))
  defp cross([a, b, c], [d, e, f]), do: [b * f - c * e, c * d - a * f, a * e - b * d]

  defp unit(a) do
    n = :math.sqrt(Enum.reduce(a, 0, &(&1 * &1 + &2)))
    if n < 1.0e-10, do: Enum.map(a, fn _ -> 0.0 end), else: Enum.map(a, &(&1 / n))
  end
end
