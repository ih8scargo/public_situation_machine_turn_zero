defmodule PublicSituationMachineTurnZero.Architecture.Diorama do
  @moduledoc "Second PUFFING furnishes extent; composed drawer operation is recoverable mechanical state."
  alias PublicSituationMachineTurnZero.Architecture, as: A
  @reserve Path.expand("../../../docs/machine-instructionings/material-reserve.json", __DIR__)
  @external_resource @reserve
  @markings @reserve |> File.read!() |> Jason.decode!()

  def markings, do: @markings

  def furnished?(m), do: A.furnished?(m, "drawer-extent-standing")

  def mechanical(m),
    do:
      m.standing["diorama_operation"] ||
        %{
          "ch_slot" => nil,
          "cob_slot" => nil,
          "progress" => 0,
          "detent" => false,
          "revision" => 0
        }

  def second_puff(m) do
    if !A.legacy?(m) && A.complete?(m) && !furnished?(m) do
      globe = m.standing["opening_geometry"]["janusite"]
      [rx, ry, rz] = globe["radii"]

      extent = %{
        "center" => globe["center"],
        "radii" => [rx + 2.5, ry + 2.4, rz + 3.2],
        "rail" => %{
          "height" => 3.25,
          "inward" => 1.5,
          "depth" => 5.2,
          "x_slots" => [3.8, 4.1, 4.4],
          "return_degrees" => 180
        },
        "travel" => 1.4,
        "relation" => "drawer-extent-standing",
        "source" => "second-puffing"
      }

      m =
        A.furnish(
          m,
          "second-puffing",
          "human THROUGH BY cob",
          "SECOND PUFFING OVER ACROSS, AROUND ABOUT",
          "Furnish the available Diorama drawer extent",
          ["pointingable-standing", "janusite-extent-standing"],
          "second-puffing-course",
          [
            %{
              id: "drawer-extent-standing",
              subject: "drawer-extent",
              predicate: "OVER ACROSS, AROUND ABOUT",
              object: "janusite",
              through: "pointingable-standing",
              role: "furnishing"
            }
          ]
        )

      standing =
        m.standing
        |> put_in(["opening_geometry", "drawer_extent"], extent)
        |> Map.update!("events", fn events ->
          List.update_at(events, -1, &Map.put(&1, "furnished_geometry", extent))
        end)

      {:ok, %{m | standing: standing}}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, params) do
    state = mechanical(m)

    if !A.legacy?(m) && furnished?(m) && params["revision"] == state["revision"] do
      case transition(state, params) do
        {:ok, changed} ->
          changed = Map.update!(changed, "revision", &(&1 + 1))
          {:ok, %{m | standing: Map.put(m.standing, "diorama_operation", changed)}}

        error ->
          error
      end
    else
      {:error, :unavailable}
    end
  end

  defp transition(
         %{"progress" => 0, "detent" => false} = s,
         %{"action" => "compose", "side" => side, "slot" => slot}
       )
       when side in ["ch", "cob"] and slot in [0, 1, 2],
       do: {:ok, Map.put(s, side <> "_slot", slot)}

  defp transition(
         %{"detent" => false, "ch_slot" => ch, "cob_slot" => cob} = s,
         %{"action" => "travel", "progress" => progress}
       )
       when not is_nil(ch) and not is_nil(cob) and is_number(progress) and progress >= 0 and
              progress <= 1,
       do: {:ok, s |> Map.put("progress", progress) |> Map.put("detent", progress == 1)}

  defp transition(%{"detent" => true} = s, %{"action" => "release"}),
    do: {:ok, Map.put(s, "detent", false)}

  defp transition(_, _), do: {:error, :unavailable}

  def presentation(m) do
    if !A.legacy?(m) && A.complete?(m) do
      %{
        "mechanical" => mechanical(m),
        "extent" => m.standing["opening_geometry"]["drawer_extent"],
        "reference" => m.standing["opening_geometry"]["wireframe"],
        "ancestry" => ["opening-accomplished", "aperture-available", "pointingable-standing"],
        "status" => "provisional mechanical rehearsal",
        "markings" => Enum.filter(@markings, &(&1["region"] != nil))
      }
    end
  end
end
