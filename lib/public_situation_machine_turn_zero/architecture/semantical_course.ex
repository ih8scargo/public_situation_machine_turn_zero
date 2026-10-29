defmodule PublicSituationMachineTurnZero.Architecture.SemanticalCourse do
  @moduledoc "One short, typed semantic course. Numerical drawing purchases cannot introduce a semantic transition. Not a geometry DSL."
  @id "semantical-rehearsal"
  @transitions [
    {"sc-source", "from_out_of", "FROM OUT OF", "Ground"},
    {"sc-initial", "end_on", "NEARLY END-ON UPON", "Ground"},
    {"sc-up-over", "up_over", "CURVING UP OVER", "Ground"},
    {"sc-pivot", "pivoting", "PIVOTING FROM PRIOR BEARING", "sc-up-over"},
    {"sc-up-from", "up_from_here", "UP FROM", "HERE"},
    {"sc-through", "through", "THROUGH", "XT"},
    {"sc-along", "along_through", "ALONG THROUGH", "XT"},
    {"sc-toward", "toward", "TOWARD", "XT"}
  ]
  @parameters %{
    origin: [430.0, 350.0],
    initial_length: 75.0,
    over_radius: 55.0,
    pivot_radius: 75.0,
    over_turn: 45.0,
    pivot_turn: 90.0,
    along_length: 125.0,
    toward_length: 45.0
  }
  def id, do: @id
  def specs, do: @transitions
  def parameters, do: @parameters

  def material do
    "Stringing"
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {glyph, i} ->
      %{
        "id" => "ordinary-stringing-#{i}",
        "glyph" => glyph,
        "order" => i,
        "course" => @id,
        "relation" => "ordinary-material-standing",
        "stringing_available" => true,
        "stitched" => false
      }
    end)
  end

  def held_course do
    {steps, _} =
      Enum.map_reduce(@transitions, "fountaining-standing", fn {id, kind, _, _}, previous ->
        {%{"id" => id, "kind" => kind, "relation" => id, "through" => previous}, id}
      end)

    %{"id" => @id, "steps" => steps, "event" => "stand-semantic-course"}
  end

  def compile(standing, parameters \\ %{}) do
    p = Map.merge(@parameters, parameters)
    course = standing["semantical_course"]
    expected = Enum.map(@transitions, fn {id, kind, _, _} -> {id, kind} end)
    actual = if course, do: Enum.map(course["steps"], &{&1["id"], &1["kind"]}), else: []

    valid =
      actual == expected &&
        Enum.map(course["steps"], & &1["through"]) ==
          Enum.map(held_course()["steps"], & &1["through"]) && valid_parameters?(p) &&
        Enum.all?(Enum.zip(course["steps"], @transitions), fn {step, {_, _, predicate, object}} ->
          r = standing["relations"][step["relation"]]

          r && r["course"] == @id && r["relation"] == predicate && r["object"] == object &&
            r["through_by_way_of"] == step["through"] &&
            Map.has_key?(standing["relations"], step["through"])
        end)

    if valid do
      {segments, _} =
        Enum.map_reduce(course["steps"], %{point: p.origin, heading: 180.0, face: 88.0}, fn step,
                                                                                            state ->
          {samples, next} = place(step["kind"], state, p)

          segment = %{
            "id" => step["id"],
            "kind" => step["kind"],
            "relation" => step["relation"],
            "through" => step["through"],
            "samples" => samples,
            "path" => path(samples),
            "bend" => step["kind"] in ["up_over", "pivoting"],
            "anchor" => Enum.at(samples, div(length(samples), 2))
          }

          {segment, next}
        end)

      samples =
        Enum.flat_map(segments, fn s ->
          Enum.map(s["samples"], &Map.put(&1, "relation", s["relation"]))
        end)

      {samples, length} = distances(samples)

      {:ok,
       %{
         "id" => @id,
         "segments" => segments,
         "samples" => samples,
         "length" => length,
         "source" => p.origin,
         "view_box" => [0, 0, 800, 600],
         "parameters" => Map.new(p, fn {k, v} -> {Atom.to_string(k), v} end)
       }}
    else
      {:error, :unfurnished_semantical_transition}
    end
  end

  defp valid_parameters?(p) do
    Enum.all?(
      [
        p.initial_length,
        p.over_radius,
        p.pivot_radius,
        p.along_length,
        p.toward_length,
        p.over_turn,
        p.pivot_turn
      ],
      fn n -> is_number(n) && n > 0 && n < 10000 end
    ) && p.over_turn + p.pivot_turn > 90 && p.over_turn + p.pivot_turn < 180
  end

  defp place("from_out_of", s, _), do: straight(s, 12, 88)
  defp place("end_on", s, p), do: straight(s, p.initial_length, 88)
  defp place("up_over", s, p), do: arc(s, p.over_radius, p.over_turn, 54)
  defp place("pivoting", s, p), do: arc(s, p.pivot_radius, p.pivot_turn, 0)
  defp place("up_from_here", s, _), do: straight(s, 25, 0)
  defp place("through", s, _), do: straight(s, 15, 0)
  defp place("along_through", s, p), do: straight(s, p.along_length, 0)
  defp place("toward", s, p), do: straight(s, p.toward_length, 0)

  defp sample([x, y], heading, face),
    do: %{
      "x" => x,
      "y" => y,
      "heading" => heading,
      "face_angle" => face,
      "text_angle" => -45 * (1 - face / 88)
    }

  defp straight(s, length, face) do
    a = s.heading * :math.pi() / 180
    [x, y] = s.point
    next = [x + length * :math.cos(a), y + length * :math.sin(a)]

    {[sample(s.point, s.heading, s.face), sample(next, s.heading, face)],
     %{s | point: next, face: face}}
  end

  defp arc(s, radius, turn, face) do
    [x, y] = s.point
    start = s.heading * :math.pi() / 180

    samples =
      for i <- 0..16 do
        f = i / 16
        angle = (s.heading + turn * f) * :math.pi() / 180

        sample(
          [
            x + radius * (:math.sin(angle) - :math.sin(start)),
            y + radius * (-:math.cos(angle) + :math.cos(start))
          ],
          s.heading + turn * f,
          s.face + (face - s.face) * f
        )
      end

    last = List.last(samples)
    {samples, %{point: [last["x"], last["y"]], heading: s.heading + turn, face: face}}
  end

  defp path(samples) do
    samples
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {p, i} -> "#{if i == 0, do: "M", else: "L"} #{p["x"]} #{p["y"]}" end)
  end

  defp distances(samples) do
    {list, {_, total}} =
      Enum.map_reduce(samples, {nil, 0.0}, fn p, {previous, total} ->
        distance =
          if previous,
            do:
              :math.sqrt(
                :math.pow(p["x"] - previous["x"], 2) + :math.pow(p["y"] - previous["y"], 2)
              ),
            else: 0

        next = total + distance
        {Map.put(p, "distance", next), {p, next}}
      end)

    {list, total}
  end
end
