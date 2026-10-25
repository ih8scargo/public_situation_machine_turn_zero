defmodule PublicSituationMachineTurnZero.Architecture.Projection do
  @moduledoc "Roundabout and FROM-WITHIN tube projections of one authoritative material ledger."
  alias PublicSituationMachineTurnZero.Architecture

  def materials(m) do
    items = Architecture.regarding_materials(m) |> Enum.sort_by(&{&1["course"], &1["id"]})
    count = max(1, length(items))

    course_ids =
      m.standing["materials"]
      |> Map.values()
      |> Enum.filter(&(&1["location"] in ["ZEROETH-ONE", "ONE"]))
      |> Enum.sort_by(&{&1["course"], &1["id"]})
      |> Enum.map(& &1["id"])

    items
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      index =
        if Architecture.stepped?(m),
          do: Enum.find_index(course_ids, &(&1 == item["id"])),
          else: index

      geometry =
        if Architecture.stepped?(m),
          do: tube_material(m, item, index),
          else: roundabout(m, index, count)

      approached = m.approach == item["id"]

      style =
        cond do
          m.flat? ->
            ""

          approached ->
            "--course-x: 50%; --course-y: 16%; --course-turn: 0deg; --course-scale: #{0.86 + m.approach_depth * 0.12}; --course-opacity: 1; --course-visible: visible"

          true ->
            geometry
        end

      Map.merge(item, %{
        "style" => style,
        "approached" => approached,
        "usingable" => Architecture.dependencies_hold?(m, item["dependencies"]),
        "missing" => Enum.reject(item["dependencies"], &Architecture.furnished?(m, &1))
      })
    end)
  end

  defp roundabout(m, index, count) do
    angle = normalize(index * 360 / count - m.wheel)
    radians = angle * :math.pi() / 180
    x = 50 + :math.sin(radians) * 41
    y = 18 + (1 - :math.cos(radians)) * 8
    scale = 0.75 + max(0, :math.cos(radians)) * 0.25

    "--course-x: #{x}%; --course-y: #{y}%; --course-turn: #{-angle * 0.65}deg; --course-scale: #{scale}; --course-opacity: 1; --course-visible: #{if abs(angle) <= 100, do: "visible", else: "hidden"}"
  end

  defp tube_material(m, item, index) do
    distance = max(0, item["course"] - m.nav + 1)
    right? = rem(index, 2) == 1
    angle = normalize(if(right?, do: 65, else: -65) - m.wheel)
    radians = angle * :math.pi() / 180
    radius = max(17, 42 - distance * 7)
    x = 50 + :math.sin(radians) * radius
    y = 18 + (1 - :math.cos(radians)) * 12 + distance * 3
    turn = -:math.sin(radians) * (42 + distance * 7)

    "--course-x: #{x}%; --course-y: #{y}%; --course-turn: #{turn}deg; --course-scale: #{max(0.5, 1 - distance * 0.12)}; --course-opacity: 1; --course-visible: #{if abs(angle) <= 115, do: "visible", else: "hidden"}"
  end

  # The near section exceeds the display: Regard is inside the tube. Only
  # interior longitudinal seams and a curved receiving opening stand ahead.
  def tube(nav) do
    bend = 80 + :math.sin(nav / 6 * :math.pi()) * 95

    %{
      center: 630 + bend / 2,
      horizon: 285 - nav * 5,
      ceiling:
        "M-100 -90 C220 -20 #{540 + bend} 85 #{630 + bend / 2} #{210 - nav * 5} C#{770 + bend} 95 1020 -30 1100 -80",
      left_wall: "M-100 120 C70 160 #{440 + bend} 200 #{565 + bend / 2} #{285 - nav * 5}",
      right_wall: "M1100 100 C1040 160 #{850 + bend} 180 #{735 + bend / 2} #{285 - nav * 5}",
      floor:
        "M-100 740 C180 640 #{480 + bend} 400 #{590 + bend / 2} #{330 - nav * 5} L#{700 + bend / 2} #{330 - nav * 5} C#{820 + bend} 420 1000 620 1100 740 Z"
    }
  end

  def rail(nav, side) when side in [-1, 1] do
    scene = tube(nav)
    near = if side == -1, do: 180, else: 820
    target = scene.center + side * 35
    "M#{near} 760 C#{near - 35} 560 #{target - 90} 415 #{target} #{scene.horizon + 48}"
  end

  def floor_relation(nav, index) do
    # Provenance has its own course between the Rails; it is not a Rail.
    y = 610 - index * 44 - nav * 4
    x = 445 + index * 19
    %{x: x, y: y, angle: -14 + index * 2}
  end

  defp normalize(n), do: n - :math.floor((n + 180) / 360) * 360
end
