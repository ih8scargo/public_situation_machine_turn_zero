defmodule PublicSituationMachineTurnZero.Architecture.Room do
  @moduledoc "Ephemeral pointing room and sheet Regarding. No command here changes material locality, seating, or passage."
  alias PublicSituationMachineTurnZero.Architecture, as: Lab

  defstruct entered?: false,
            pointer?: false,
            held?: false,
            turned?: false,
            turn: 0.0,
            position: 0.0,
            across: 0.0,
            sheet: nil,
            corners: [],
            tension: 0.0,
            regard: "center",
            sweep: 0.0,
            readable_scale: 1.0

  def enter(room), do: %{room | entered?: true}

  def pointer(room, :draw),
    do:
      if(room.entered?,
        do: {:ok, %{room | pointer?: true, held?: true}},
        else: {:error, :room_required}
      )

  def pointer(%{pointer?: true} = room, :hold), do: {:ok, %{room | held?: true}}

  def pointer(%{pointer?: true} = room, {:turn, angle})
      when is_number(angle) and angle >= -3600 and angle <= 3600,
      do: {:ok, %{room | turn: angle, turned?: room.turned? || abs(angle) >= 8}}

  def pointer(room, :release), do: {:ok, %{room | held?: false}}
  def pointer(_, _), do: {:error, :pointer_not_furnished}

  def appointable?(room), do: room.entered? && room.pointer? && room.turned? && !room.held?

  def motion(room, position, across) when is_number(position) and is_number(across),
    do: %{room | position: min(6.0, max(0.0, position)), across: min(0.65, max(-0.65, across))}

  def sheets(lab) do
    lab.standing["materials"]
    |> Map.values()
    |> Enum.filter(&(&1["location"] in ["ZEROETH-ONE", "ONE"]))
    |> Enum.sort_by(&{&1["course"], &1["id"]})
  end

  @doc "Real source associations for XT; no generated semantic explanation."
  def context(lab, id) do
    case lab.standing["materials"][id] do
      nil ->
        tunnel = lab.standing["tunnels"]["ZEROETH-ONE"]

        %{
          materials:
            Enum.filter(sheets(lab), &(&1["region"] in ["groundward", "continuing-from"])),
          relations:
            lab.standing["relations"]
            |> Map.values()
            |> Enum.filter(&(&1["origin"] == tunnel["from"])),
          revisions: [],
          origin: tunnel["from"],
          location: tunnel["id"]
        }

      material ->
        contextual =
          sheets(lab)
          |> Enum.filter(fn other ->
            other["id"] != id && other["origin"] == material["origin"] &&
              other["region"] in ["groundward", "continuing-from"]
          end)

        relations =
          material["dependencies"]
          |> Enum.flat_map(fn dependency ->
            case lab.standing["relations"][dependency] do
              nil -> []
              relation -> [relation]
            end
          end)

        %{
          materials: contextual,
          relations: relations,
          revisions: material["provenance"],
          origin: material["origin"],
          location: material["location"]
        }
    end
  end

  def resolve(room, lab, id) do
    available =
      Lab.stepped?(lab) &&
        Enum.any?(
          sheets(lab),
          &(&1["id"] == id && abs(&1["course"] - room.position) <= 2.5)
        )

    if available,
      do: {:ok, %{room | sheet: id, corners: [], tension: 1.0, regard: "yt", sweep: 1.0}},
      else: {:error, :sheet_not_available}
  end

  def look(room, direction) when direction in ["center", "up", "down", "xt", "yt"] do
    sweep =
      case direction do
        "xt" -> -1.0
        "yt" -> 1.0
        _ -> room.sweep
      end

    {:ok, %{room | regard: direction, sweep: sweep}}
  end

  def look(_, _), do: {:error, :unknown_regard}

  def calibrate(room, scale) when is_number(scale),
    do: {:ok, %{room | readable_scale: max(0.85, min(1.15, scale))}}

  def catch_corner(room, lab, id, corner) when corner in 0..3 do
    available =
      Lab.stepped?(lab) &&
        Enum.any?(sheets(lab), &(&1["id"] == id && abs(&1["course"] - room.position) <= 2.5))

    if available do
      corners = if room.sheet == id, do: Enum.uniq(room.corners ++ [corner]), else: [corner]

      {:ok,
       %{
         room
         | sheet: id,
           corners: corners,
           tension: if(room.sheet == id, do: room.tension, else: 0.0)
       }}
    else
      {:error, :sheet_not_available}
    end
  end

  def catch_corner(_, _, _, _), do: {:error, :unknown_corner}

  def draw(%{sheet: id} = room, amount) when not is_nil(id) and is_number(amount) do
    limit = if length(room.corners) >= 2, do: 1.0, else: 0.55
    {:ok, %{room | tension: min(limit, max(0.0, amount))}}
  end

  def draw(_, _), do: {:error, :catch_a_corner}

  def square(room) do
    if length(room.corners) >= 2,
      do: {:ok, %{room | tension: 1.0}},
      else: {:error, :additional_corner_required}
  end

  def relinquish(room),
    do: %{room | sheet: nil, corners: [], tension: 0.0, regard: "center", sweep: 0.0}
end
