defmodule PublicSituationMachineTurnZero.Architecture.TraversalCourse do
  @moduledoc "Human-appointed NAV rehearsal and append-only JANUSITE issuance within the same turn. No seating or RE-STEP."
  alias PublicSituationMachineTurnZero.Architecture, as: A
  @version "flick-to-approach-v2"
  @intervals 24
  @max_issues 3

  def model(m) do
    if A.complete?(m) && !A.legacy?(m) do
      state = m.standing["traversal_rehearsal"]

      state ||
        %{
          "version" => @version,
          "appointed" => false,
          "revision" => 0,
          "continuation_authorized" => false,
          "issues" => [],
          "course" => initial(m),
          "turn_basis" => m.standing["from"],
          "source_event" => "appoint-pointingable"
        }
    end
  end

  def operate(m, params) do
    with true <- A.complete?(m) && !A.legacy?(m),
         state <- model(m),
         true <- params["revision"] == state["revision"],
         {:ok, next} <- transition(state, params) do
      next = Map.update!(next, "revision", &(&1 + 1))
      {:ok, %{m | standing: Map.put(m.standing, "traversal_rehearsal", next)}}
    else
      _ -> {:error, :unavailable}
    end
  end

  defp transition(%{"appointed" => false} = state, %{"action" => "appoint"}),
    do: {:ok, Map.put(state, "appointed", true)}

  defp transition(%{"appointed" => true, "continuation_authorized" => false} = state, %{
         "action" => "appoint-continuation"
       }) do
    if length(state["issues"]) < @max_issues,
      do: {:ok, Map.put(state, "continuation_authorized", true)},
      else: {:error, :issue_limit}
  end

  defp transition(%{"appointed" => true, "continuation_authorized" => true} = state, %{
         "action" => "issue"
       }) do
    index = length(state["issues"]) + 1

    if index <= @max_issues do
      course = append_loop(state["course"], index)

      issue = %{
        "id" => "janusite-nav-issue-#{index}",
        "kind" => "JANUSITE rehearsal track",
        "from_distance" => state["course"]["length"],
        "to_distance" => course["length"],
        "authority" => "explicit Human continuation appointment and issuance",
        "new_turn" => false
      }

      {:ok,
       state
       |> Map.put("course", course)
       |> Map.put("continuation_authorized", false)
       |> Map.update!("issues", &(&1 ++ [issue]))}
    else
      {:error, :issue_limit}
    end
  end

  defp transition(_, _), do: {:error, :unavailable}

  def initial(m) do
    stick = m.standing["opening_geometry"]["stick"]
    start = stick["cob_center"]
    [_, y, _] = start
    floor = min(-1.2, y - 0.65)
    low = floor + 0.35
    [fx, fy, fz] = add(start, add(scale(stick["direction"], 1.0), [0, -0.2, 0]))
    first = [fx, max(floor + 0.45, fy), fz]

    points = [
      start,
      first,
      [-2.1, max(low + 0.8, y - 0.9), 4.6],
      [-1.8, low + 0.35, 6.2],
      [1.9, low + 0.25, 7.0],
      [1.8, low, 8.8],
      [0, low, 10.1],
      [0, low, 11.2]
    ]

    tangents =
      Enum.with_index(points)
      |> Enum.map(fn {_, i} ->
        cond do
          i == 0 -> scale(stick["direction"], 1.4)
          i == length(points) - 1 -> [0, 0, 1.2]
          true -> scale(sub(Enum.at(points, i + 1), Enum.at(points, i - 1)), 0.5)
        end
      end)

    raw =
      Enum.flat_map(0..(length(points) - 2), fn segment ->
        for j <- if(segment == 0, do: 0, else: 1)..@intervals do
          t = j / @intervals

          p =
            hermite(
              Enum.at(points, segment),
              Enum.at(points, segment + 1),
              Enum.at(tangents, segment),
              Enum.at(tangents, segment + 1),
              t
            )

          direction =
            unit(
              hermite_derivative(
                Enum.at(points, segment),
                Enum.at(points, segment + 1),
                Enum.at(tangents, segment),
                Enum.at(tangents, segment + 1),
                t
              )
            )

          fraction = (segment + t) / (length(points) - 1)

          sample(
            p,
            direction,
            1.35 * :math.sin(fraction * 2 * :math.pi()) *
              :math.pow(:math.sin(fraction * :math.pi()), 2),
            0
          )
        end
      end)

    samples = distances(raw, 0, nil)
    total = List.last(samples)["distance"]

    destination = %{
      "id" => "cob-next-approaching-locality-v2",
      "point" => List.last(points),
      "name" => "NEXT APPROACHINGING LANDINGING",
      "source" => "Human-appointed Flick course / appoint-pointingable",
      "status" => "route endpoint; future Seat is reserved beneath the aperture, facing inward",
      "future_seat_with_cob" => false
    }

    %{
      "id" => @version,
      "status" => "Human-operated NAV-STEPPING rehearsal, one current turn",
      "origin" => %{
        "id" => "pointingable-flick-locality-v1",
        "point" => start,
        "source" => "pointingable-standing"
      },
      "destination" => destination,
      "waypoints" => points,
      "tangents" => tangents,
      "samples" => samples,
      "length" => total,
      "base_length" => total,
      "floor_y" => floor,
      "stations" => [total],
      "signs" => [
        sign(
          "flick-departure-notice",
          0.02 * total,
          "FLICK · DEPARTURE",
          "Captain: the course begins at your appointed purchase.",
          "Reverse of departure witness. Same course, same turn."
        ),
        sign(
          "banking-notice",
          0.48 * total,
          "MIND THE BANK",
          "Sideways is a bearing, not a new world. Keep skating.",
          "Bank and local up come from this same course."
        ),
        sign(
          "nav-stepping-notice",
          0.67 * total,
          "NAV-STEPPING",
          "More JANUSITE may be issued within this turn. No RE-STEP; no sealing.",
          "Existing road stays. New material is appended by Human labor."
        ),
        sign(
          "seat-approach-notice",
          0.9 * total,
          "NEXT APPROACH",
          "This is the NEXT approaching locality. The future Seat WITH COB belongs beneath the aperture.",
          "No automatic seating, Weddinging, or RE-STEP is performed."
        )
      ],
      "tube_radius" => 0.65
    }
  end

  defp append_loop(course, issue) do
    start = course["destination"]["point"]
    radius = 0.8 + issue * 0.12

    raw =
      for i <- 1..96 do
        a = i * 2 * :math.pi() / 96

        point =
          add(start, [
            radius * (1 - :math.cos(a)),
            0.18 * :math.pow(:math.sin(a), 2),
            radius * :math.sin(a)
          ])

        tangent =
          unit([radius * :math.sin(a), 0.36 * :math.sin(a) * :math.cos(a), radius * :math.cos(a)])

        sample(point, tangent, 0.45 * :math.sin(a), issue)
      end

    # Exact closure, with matching tangent; no modification to any old sample.
    raw =
      List.update_at(
        raw,
        -1,
        &Map.merge(&1, %{"point" => start, "tangent" => [0, 0, 1], "up" => [0, 1, 0]})
      )

    extra = distances(raw, course["length"], List.last(course["samples"])["point"])
    samples = course["samples"] ++ extra
    total = List.last(samples)["distance"]

    course
    |> Map.put("samples", samples)
    |> Map.put("length", total)
    |> Map.update!("stations", &(&1 ++ [total]))
  end

  defp sample(point, tangent, bank, issue) do
    right = unit(cross([0, 1, 0], tangent))
    up = unit(cross(tangent, right))
    banked_up = add(scale(up, :math.cos(bank)), scale(right, :math.sin(bank)))
    %{"point" => point, "tangent" => tangent, "up" => banked_up, "bank" => bank, "issue" => issue}
  end

  defp distances(raw, initial, prior) do
    {samples, _} =
      Enum.map_reduce(raw, {initial, prior}, fn sample, {distance, before} ->
        next = distance + if(before, do: norm(sub(sample["point"], before)), else: 0)
        {Map.put(sample, "distance", next), {next, sample["point"]}}
      end)

    samples
  end

  defp sign(id, distance, title, front, reverse),
    do: %{
      "id" => id,
      "distance" => distance,
      "title" => title,
      "front" => front,
      "reverse" => reverse,
      "authority" => "official experimental architectural witness; not CH-authored inscription"
    }

  defp hermite(a, b, u, v, t),
    do:
      add(
        add(scale(a, 2 * t * t * t - 3 * t * t + 1), scale(b, -2 * t * t * t + 3 * t * t)),
        add(scale(u, t * t * t - 2 * t * t + t), scale(v, t * t * t - t * t))
      )

  defp hermite_derivative(a, b, u, v, t),
    do:
      add(
        add(scale(a, 6 * t * t - 6 * t), scale(b, -6 * t * t + 6 * t)),
        add(scale(u, 3 * t * t - 4 * t + 1), scale(v, 3 * t * t - 2 * t))
      )

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp scale(a, s), do: Enum.map(a, &(&1 * s))
  defp norm(a), do: :math.sqrt(Enum.reduce(a, 0, &(&2 + &1 * &1)))
  defp unit(a), do: if(norm(a) > 1.0e-10, do: scale(a, 1 / norm(a)), else: [0, 0, 1])
  defp cross([x, y, z], [a, b, c]), do: [y * c - z * b, z * a - x * c, x * b - y * a]
end
