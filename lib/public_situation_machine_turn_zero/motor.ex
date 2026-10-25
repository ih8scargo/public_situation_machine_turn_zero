defmodule PublicSituationMachineTurnZero.Motor do
  @moduledoc """
  Experimental motor. Standing is durable; Regarding, pointing, selection and pace
  are temporary posture. Laboratory approach units and curve are not calibration
  standings (4/6/8). NAV-STEP integrates rate over an explicit time quantum.
  RE-STEP takes up either singular PUFF-next or a selected re-seated differentiated
  landing. Occupancy is furnished from within after primitive passage.
  """
  defstruct standing: nil, bearing: nil, pointed: nil, selected: nil, progress: 0.0, rate: 5.0

  def new do
    restore(%{
      "next" => nil,
      "version" => 2,
      "from" => "A",
      "extents" => %{"A" => %{"parent" => nil, "what_for" => "Initial laboratory standing"}},
      "landings" => %{},
      "passages" => []
    })
  end

  def restore(standing) do
    # Old snapshots never recorded a singular THIS NEXT. Do not invent one.
    extents =
      Map.new(standing["extents"], fn {id, extent} ->
        inhabited =
          id == standing["from"] ||
            Enum.any?(standing["passages"], &(&1["toward"] == id || &1["from"] == id))

        {id, Map.put_new(extent, "kind", if(inhabited, do: "standing", else: "possibility"))}
      end)

    %__MODULE__{
      standing:
        standing
        |> Map.put("extents", extents)
        |> Map.put_new("next", nil)
        |> Map.put("version", 2)
    }
  end

  def operate(m, :puff) do
    if m.standing["next"] do
      {:error, :this_next_already_furnished}
    else
      id =
        Enum.find(
          Stream.map(1..1_000_000, fn n -> if n < 26, do: <<?A + n>>, else: "E#{n}" end),
          &(not Map.has_key?(m.standing["extents"], &1))
        )

      extent = %{"parent" => m.standing["from"], "what_for" => nil, "kind" => "possibility"}

      standing =
        m.standing
        |> put_in(["extents", id], extent)
        |> Map.put("next", %{"from" => m.standing["from"], "toward" => id, "by_way_of" => "PUFF"})

      {:ok, %{m | standing: standing}}
    end
  end

  def operate(m, {:in_string, id, text}) when is_binary(text) do
    if id == m.standing["from"] && String.trim(text) != "" &&
         is_nil(m.standing["extents"][id]["what_for"]) do
      {:ok, put_in(m.standing["extents"][id]["what_for"], text)}
    else
      {:error, :requires_character_from_within_unoccupied_standing}
    end
  end

  def operate(m, :fixture) do
    if Map.has_key?(m.standing["extents"], "LAB-Y") do
      {:error, :fixture_already_registered}
    else
      {:ok,
       put_in(m.standing["extents"]["LAB-Y"], %{
         "parent" => nil,
         "kind" => "fixture",
         "what_for" => "Laboratory differentiated standing FROM THERE"
       })}
    end
  end

  def operate(m, {:pivot, id}) do
    if projectable?(m, id) do
      {:ok, %{m | bearing: id, pointed: nil, selected: nil, progress: 0.0}}
    else
      {:error, :not_projectable}
    end
  end

  def operate(m, :point) do
    if projectable?(m, m.bearing) && m.bearing != m.standing["from"],
      do: {:ok, %{m | pointed: m.bearing}},
      else: {:error, :no_toward}
  end

  def operate(m, :select) do
    if m.pointed && m.pointed == m.bearing && m.pointed != m.standing["from"],
      do: {:ok, %{m | selected: m.pointed}},
      else: {:error, :point_toward_differentiated_standing}
  end

  def operate(m, :re_seat) do
    if m.selected && m.selected == m.bearing && projectable?(m, m.selected) do
      key = landing_key(m)

      landing = %{
        "from" => m.standing["from"],
        "toward" => m.selected,
        "length" => 100.0,
        "curve" => [[0.0, 0.0], [40.0, 65.0], [0.0, 100.0]],
        "markers" => [10.0, 30.0, 55.0, 80.0, 95.0]
      }

      {:ok, put_in(m.standing["landings"][key], Map.get(m.standing["landings"], key, landing))}
    else
      {:error, :select_a_projectable_landing}
    end
  end

  def operate(m, {:rate, rate}) when is_number(rate) and rate >= 0.05 and rate <= 100,
    do: {:ok, %{m | rate: rate}}

  def operate(m, {:nav_step, seconds})
      when is_number(seconds) and seconds > 0 and seconds <= 10 do
    case approach(m) do
      nil -> {:error, :no_approach_in_regard}
      landing -> {:ok, %{m | progress: min(landing["length"], m.progress + m.rate * seconds)}}
    end
  end

  def operate(m, :re_step) do
    next = m.standing["next"]

    cond do
      next && next["from"] == m.standing["from"] ->
        target = next["toward"]

        passage = %{
          "from" => next["from"],
          "toward" => target,
          "by_way_of" => "PUFF",
          "operation" => "RE-STEP"
        }

        standing =
          m.standing
          |> Map.put("from", target)
          |> Map.put("next", nil)
          |> put_in(["extents", target, "kind"], "standing")
          |> Map.update!("passages", &(&1 ++ [passage]))

        {:ok, %{restore(standing) | rate: m.rate}}

      m.selected && m.selected == m.bearing && approach(m) ->
        passage = %{
          "from" => m.standing["from"],
          "toward" => m.selected,
          "by_way_of" => "RE-SEATING",
          "landing" => landing_key(m),
          "operation" => "RE-STEP"
        }

        standing =
          m.standing
          |> Map.put("from", m.selected)
          |> Map.update!("passages", &(&1 ++ [passage]))

        {:ok, %{restore(standing) | rate: m.rate}}

      true ->
        {:error, :requires_this_next_or_selected_re_seated_landing}
    end
  end

  def operate(_m, _operation), do: {:error, :unavailable_operation}

  def projectable?(m, id) do
    extent = m.standing["extents"][id]
    extent != nil && extent["kind"] in ["standing", "fixture"] && extent["what_for"] != nil
  end

  def available?(m, operation), do: match?({:ok, _}, operate(m, operation))

  def availability(m) do
    Map.new(
      [
        {"puff", :puff},
        {"point", :point},
        {"select", :select},
        {"re-seat", :re_seat},
        {"nav-step", {:nav_step, 1.0}},
        {"re-step", :re_step},
        {"fixture", :fixture}
      ],
      fn {name, op} -> {name, available?(m, op)} end
    )
  end

  def can_inscribe?(m), do: is_nil(m.standing["extents"][m.standing["from"]]["what_for"])

  def approach(m), do: Map.get(m.standing["landings"], landing_key(m))
  defp landing_key(m), do: "#{m.standing["from"]}:#{m.bearing}"

  def projection(m) do
    landing = approach(m)

    %{
      re_step:
        case operate(m, :re_step) do
          {:ok, next} -> List.last(next.standing["passages"])
          {:error, _} -> nil
        end,
      from: m.standing["from"],
      toward: m.bearing,
      approach: landing,
      progress: m.progress,
      path: if(landing, do: curve_path(landing["curve"]), else: ""),
      markers:
        if(landing,
          do:
            Enum.map(landing["markers"], fn at ->
              %{at: at, position: curve_point(landing["curve"], at / landing["length"])}
            end),
          else: []
        ),
      passed_markers:
        if(landing, do: Enum.filter(landing["markers"], &(&1 <= m.progress)), else: []),
      position:
        if(landing,
          do: curve_point(landing["curve"], m.progress / landing["length"]),
          else: {0, 0}
        )
    }
  end

  defp curve_path([[x0, y0], [x1, y1], [x2, y2]]),
    do: "M#{x0} #{y0} Q#{x1} #{y1} #{x2} #{y2}"

  defp curve_point([[x0, y0], [x1, y1], [x2, y2]], t),
    do:
      {(1 - t) * (1 - t) * x0 + 2 * (1 - t) * t * x1 + t * t * x2,
       (1 - t) * (1 - t) * y0 + 2 * (1 - t) * t * y1 + t * t * y2}
end
