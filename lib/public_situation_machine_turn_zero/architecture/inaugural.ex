defmodule PublicSituationMachineTurnZero.Architecture.Inaugural do
  @moduledoc "Ordered reception of a pre-furnished inaugural approach; not Human-authored consequential turns."
  alias PublicSituationMachineTurnZero.Architecture, as: A

  def model(m) do
    state =
      m.standing["inaugural_approach"] ||
        %{"revision" => 0, "across" => false, "detent" => false, "over_across" => false}

    Map.merge(
      %{
        "authority" =>
          "pre-furnished inaugural rehearsal; Human receives and NAV-STEPS inherited material",
        "first" => A.puffed?(m),
        "pointing" => A.complete?(m),
        "human_reference" => %{
          "entity" => "human",
          "point" => [0, 0, -24],
          "monitor_distance" => 24,
          "units" => "model units; not physical calibration"
        },
        "monitor_plane" => %{"point" => [0, 0, 0], "normal" => [0, 0, 1]},
        "cabinet_seat" => %{
          "occupant" => "doll",
          "identity" => A.name("doll"),
          "agentive" => false,
          "relation" => "ALONGSIDE WITH Cab-side standing",
          "responsibilities" => [
            "Semantical In-Stringing-Mentings",
            "stitching letters upon the road"
          ],
          "source" => "inaugural handoff / existing doll identity"
        },
        "reference_extents" =>
          Enum.map(0..2, fn i ->
            %{
              "id" => "behind-monitor-#{i + 1}",
              "min" => [-1.2, -1.2, i],
              "max" => [1.2, 1.2, i + 1],
              "status" => "working pre-quadranglement reference, not a new room"
            }
          end),
        "segments" => 8,
        "bend_angles" => [45, 45],
        "angle_status" => "approximate inspection hypothesis; not a mechanical canon"
      },
      state
    )
  end

  def operate(m, params) do
    state = model(m)

    with true <- !A.legacy?(m) && A.complete?(m),
         true <- params["revision"] == state["revision"],
         {:ok, next} <- transition(m, state, params) do
      next =
        next
        |> Map.take([
          "revision",
          "across",
          "detent",
          "over_across",
          "detent_witness",
          "cabinet_seat",
          "authority"
        ])
        |> Map.update!("revision", &(&1 + 1))

      {:ok, %{m | standing: Map.put(m.standing, "inaugural_approach", next)}}
    else
      _ -> {:error, :unavailable}
    end
  end

  defp transition(_, %{"across" => false} = s, %{"action" => "puff-across"}),
    do: {:ok, Map.put(s, "across", true)}

  defp transition(m, %{"across" => true, "detent" => false} = s, %{
         "action" => "detent",
         "distance" => d
       })
       when is_number(d) do
    traversal = m.standing["traversal_rehearsal"]

    if traversal && traversal["appointed"] && abs(d - traversal["course"]["base_length"]) < 1.0e-7 do
      {:ok,
       s
       |> Map.put("detent", true)
       |> Map.put("detent_witness", %{
         "distance" => d,
         "course" => traversal["course"]["id"],
         "kind" => "completed NAV motion at inherited endpoint; no RE-STEP"
       })}
    else
      {:error, :unavailable}
    end
  end

  defp transition(_, %{"detent" => true, "over_across" => false} = s, %{
         "action" => "puff-over-across"
       }),
       do: {:ok, Map.put(s, "over_across", true)}

  defp transition(_, _, _), do: {:error, :unavailable}
end
