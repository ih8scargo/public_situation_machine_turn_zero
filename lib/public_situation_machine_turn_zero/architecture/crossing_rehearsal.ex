defmodule PublicSituationMachineTurnZero.Architecture.CrossingRehearsal do
  # Geometry reconciliation: Historical 5x5x6 operating reference is not the new default SIX cube; preserve saved source versions.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Bounded paired-aperture hypothesis through reception only. View and slice are never constitutional transforms."
  alias PublicSituationMachineTurnZero.Architecture, as: A
  @version "paired-apertures-v1"
  def operating_reference do
    %{
      "version" => "ground-monitor-head-v1",
      "monitor" => %{"origin" => [0, 0, 0], "normal" => [0, 0, 1]},
      "ground" => %{"origin" => [0, -2.5, 0], "normal" => [0, 1, 0]},
      "head_purchase" => [0, 0, 0],
      "cabinet_outward_extent" => 3,
      "cabinet_front_z" => -3,
      "here_square" => [[-2.5, -2.5, -3], [2.5, -2.5, -3], [2.5, -2.5, 0], [-2.5, -2.5, 0]],
      "tc_locality" =>
        "ordinary operating locality; no physical direction or distance stipulated",
      "place" => "CH place; rugging assumed furnished for this rehearsal",
      "standinging_landinging" => "stands FROM this CH place; distinct from rugging",
      "basis" => "Toy Box already opened FROM HERE by square tab through round aperture"
    }
  end

  def model(m) do
    received = A.complete?(m)

    state =
      m.standing["crossing_rehearsal"] ||
        %{
          "revision" => 0,
          "pull" => 0.0,
          "feed" => 0.0
        }

    Map.merge(state, %{
      "version" => @version,
      "received" => received,
      "registration" => state["registration"],
      "pin" => [0, 0, 0],
      "monitor_normal" => [0, 0, 1],
      "operating_reference" => state["operating_reference"] || operating_reference(),
      "framework" => [5, 5, 6],
      "inscription_resolution" =>
        PublicSituationMachineTurnZero.Architecture.InscriptionResolution.model(),
      "words" => [
        %{"text" => "THE", "count" => 3},
        %{"text" => "PUBLIC", "count" => 6},
        %{"text" => "SITUATION", "count" => 9},
        %{"text" => "MACHINE", "count" => 7}
      ],
      "doll" => %{
        "id" => "doll",
        "name" => A.name("doll"),
        "agentive" => false,
        "duties" => ["Semantical In-Stringing-Mentings", "stitching letters upon the road"]
      },
      "stick" => m.standing["opening_geometry"]["stick"],
      "status" => "geometric hypothesis; no Craft seating, navigation or further PUFFING"
    })
  end

  def operate(m, params) do
    s = model(m)

    with false <- A.legacy?(m),
         true <- params["revision"] == s["revision"],
         {:ok, next} <- change(m, s, params) do
      {:ok, next}
    else
      _ -> {:error, :unavailable}
    end
  end

  defp change(m, %{"pull" => pull, "registration" => nil} = s, %{"action" => "lock"})
       when pull == 1 do
    registration = %{
      "operation" => "CH aperture registration LOCK",
      "cabinet_degrees" => 0,
      "doll_degrees" => 45,
      "pin" => [0, 0, 0],
      "basis" => "completed steering pull; shared-head hinge hypothesis"
    }

    {:ok, save(m, Map.put(s, "registration", registration))}
  end

  defp change(m, %{"registration" => registration} = s, %{"action" => "unlock"})
       when is_map(registration),
       do: {:ok, save(m, Map.put(s, "registration", nil))}

  defp change(m, s, %{"action" => action, "value" => value})
       when action in ["pull", "feed"] and is_number(value) and value >= 0 and value <= 1 do
    if (action == "pull" && is_map(s["registration"])) ||
         (action == "feed" && (s["pull"] < 1 || s["received"])) do
      {:error, :unavailable}
    else
      key = if(action == "pull", do: "pull", else: "feed")
      {:ok, save(m, s |> Map.put(key, value))}
    end
  end

  defp change(
         m,
         %{"received" => false, "pull" => p, "feed" => f, "registration" => registration} = s,
         %{"action" => "receive"}
       )
       when p == 1 and f == 1 and is_map(registration) do
    # The existing opening supplies its retained prerequisites; no later PUFFING is performed.
    with {:ok, m} <- prepare(m),
         samples <- for(i <- 0..64, do: point(i / 64)),
         stick <- %{
           "origin" => [0, 0, 0],
           "tip" => List.last(samples),
           "direction" => [0, 0, 1],
           "yaw" => 0,
           "pitch" => 0,
           "length" => :math.pi() * 1.6 / 2,
           "extension" => 1,
           "cob_center" => [1.6, 0.32, 1.6],
           "curve" => %{
             "version" => @version,
             "samples" => samples,
             "ancestry" => "Doll pinned-head seam / wedge / swept CUBICAL passage"
           },
           "nozzle" => %{
             "kind" => "mounting-able CUBICAL",
             "half" => 0.23,
             "passage_half" => 0.16,
             "glass_half" => 0.24,
             "status" => "finite aperture clearance hypothesis"
           },
           "via" => %{
             "participant" => "doll",
             "agentive" => false,
             "pin" => [0, 0, 0],
             "aperture" => "Looking THROUGHING THROUGHING Glass"
           },
           "token" => Ecto.UUID.generate()
         },
         {:ok, m} <- A.operate(%{m | opening_stage: stick}, :opening_appoint) do
      {:ok, save(m, Map.put(s, "appointed_passage", Map.delete(stick, "token")))}
    end
  end

  defp change(_, _, _), do: {:error, :unavailable}

  defp prepare(m) do
    with {:ok, m} <-
           if(A.opened?(m),
             do: {:ok, m},
             else:
               A.operate(
                 m,
                 {:opening_pull,
                  %{"dx" => 1, "dy" => 0, "source" => "geometry rehearsal prerequisites"}}
               )
           ),
         {:ok, m} <- if(A.puffed?(m), do: {:ok, m}, else: A.operate(m, :puff)),
         do: {:ok, m}
  end

  def point(t),
    do: [1.6 * :math.sin(t * :math.pi() / 2), 0, 1.6 * (1 - :math.cos(t * :math.pi() / 2))]

  defp save(m, s) do
    state =
      s
      |> Map.take([
        "revision",
        "pull",
        "feed",
        "appointed_passage",
        "operating_reference",
        "registration"
      ])
      |> Map.update!("revision", &(&1 + 1))

    %{m | standing: Map.put(m.standing, "crossing_rehearsal", state)}
  end
end
