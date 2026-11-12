defmodule PublicSituationMachineTurnZero.Workshop.ComingAboardAppliance do
  @moduledoc "Bounded Coming Aboard staging witness. No PINNING, acquisition or constitutional turn."
  alias PublicSituationMachineTurnZero.Workshop.{WedgingGeometry, SnailBody}
  alias PublicSituationMachineTurnZero.Architecture

  def new do
    ship = Ecto.UUID.generate()

    %{
      ship: ship,
      opening: Architecture.new(),
      machine_open?: false,
      machine_view: "flat",
      road_progress: 0.0,
      wedge: 0,
      puffed?: false,
      needle: SnailBody.new(),
      inscription: nil,
      stitched: MapSet.new(),
      input_device: "keyboard",
      input_kind: "semantical marking",
      machine_notice: nil,
      inspected_part: "table",
      cob: "#{ship}/COB",
      here: "#{ship}/THIS HERE APPROACHING LANDINGING",
      door: 0,
      gallery: "longhouse",
      view: "flat",
      cab_inspection: nil,
      line_open?: false,
      inquiry: nil,
      outreading: nil,
      material: %{},
      approach: nil,
      diagonal: "A",
      bugs: 1,
      restep: 6,
      illuminations: 0
    }
  end

  def doors do
    boundary = WedgingGeometry.outline()

    Enum.map(0..7, fn index ->
      {x, z} = Enum.at(boundary, index)
      {u, v} = Enum.at(boundary, rem(index + 1, 8))
      project = fn {a, b} -> "#{200 + a * 72},#{200 + b * 72}" end

      %{
        id: index,
        wedge: Enum.map_join([{0, 0}, {x, z}, {u, v}], " ", project),
        edge: Enum.map_join([{x, z}, {u, v}], " ", project),
        x: 200 + (x + u) * 36,
        y: 200 + (z + v) * 36
      }
    end)
  end

  def open(s, dx, dy) do
    case Architecture.operate(s.opening, {:opening_pull, %{"dx" => dx, "dy" => dy}}) do
      {:ok, opening} -> %{s | opening: opening, machine_open?: true}
      _ -> s
    end
  end

  def operate(s, "inspect-part", %{"part" => %{"id" => id}}) do
    if Enum.any?(
         PublicSituationMachineTurnZero.Workshop.ComingAboardMachine.scene(s),
         &(&1.id == id)
       ),
       do: %{s | inspected_part: id},
       else: s
  end

  def operate(s, "machine-view", %{"selection" => view})
      when view in ~w(flat dollside tunnel top back),
      do: %{s | machine_view: view}

  def operate(%{machine_open?: true} = s, "needle-take", _), do: needle(s, :take)
  def operate(%{machine_open?: true} = s, "needle-return", _), do: needle(s, :return)
  def operate(%{machine_open?: true} = s, "needle-withdraw", _), do: needle(s, {:withdraw, 500})

  def operate(%{machine_open?: true} = s, "needle-gather", _) do
    if s.needle["outstanding"] > 0, do: needle(s, {:gather, s.needle["outstanding"]}), else: s
  end

  def operate(
        %{machine_open?: true, input_device: "keyboard", input_kind: "semantical marking"} = s,
        "quill",
        %{"quill" => %{"text" => text}}
      ) do
    case SnailBody.operate(s.needle, {:quill, text}) do
      {:ok, body} ->
        %{
          s
          | needle: body,
            inscription: List.last(body["material"])["id"],
            machine_notice: "Human Quilling retained. Doll Stitching is separately available."
        }

      _ ->
        %{
          s
          | machine_notice:
              "Take the Quilling Stitching Needle and inscribe a nonempty marking (at most 2000 bytes)."
        }
    end
  end

  def operate(%{machine_open?: true, inscription: id} = s, "stitch", _) when is_binary(id) do
    %{
      s
      | stitched: MapSet.put(s.stitched, id),
        machine_notice:
          "The non-agentive Doll Stitches the Human's same markings UP ON THE ROAD. No constitutional PINNING or acquisition."
    }
  end

  def operate(
        %{machine_open?: true, view: "within-cab", cab_inspection: :selected, puffed?: false} = s,
        "tunnel-puff",
        _
      ) do
    case Architecture.operate(s.opening, :puff) do
      {:ok, opening} ->
        %{
          s
          | opening: opening,
            puffed?: true,
            machine_view: "tunnel",
            machine_notice:
              "PUFFING furnished JANUSITE extent FOR possibility through the inherited opening operation. Candidate selection did not acquire Standing."
        }

      _ ->
        s
    end
  end

  def operate(%{view: "within-cab"} = s, "wedge-next", _) do
    %{s | wedge: rem(s.wedge + 1, 6), cab_inspection: :regarding}
  end

  def operate(s, "road-regard", %{"selection" => value}) when value in ~w(0 0.5 1),
    do: %{
      s
      | road_progress:
          String.to_float(if value == "0" or value == "1", do: value <> ".0", else: value)
    }

  def operate(s, "input-appointment", %{"input" => %{"device" => device, "kind" => kind}})
      when device in ~w(keyboard pointer) and kind in ["semantical marking", "pointing"],
      do: %{s | input_device: device, input_kind: kind}

  def operate(s, "door", %{"door" => door}) when door in ~w(0 1 2 3 4 5 6 7),
    do: %{s | door: String.to_integer(door)}

  def operate(s, "gallery", %{"selection" => value}) when value in ~w(longhouse roundabout),
    do: %{s | gallery: value}

  def operate(s, "view", %{"selection" => value})
      when value in ~w(flat dollside tunnel within-cab),
      do: %{s | view: value, machine_view: if(value == "within-cab", do: "tunnel", else: value)}

  def operate(%{view: "within-cab", cab_inspection: nil} = s, "cab-puff", _),
    do: %{s | cab_inspection: :regarding}

  def operate(%{view: "within-cab", cab_inspection: :regarding} = s, "cab-select", _),
    do: %{s | cab_inspection: :selected}

  def operate(s, "diagonal", %{"selection" => value}) when value in ~w(A B),
    do: %{s | diagonal: value}

  def operate(s, "hook", _),
    do: %{s | line_open?: !s.line_open?, outreading: nil}

  def operate(%{line_open?: true} = s, "inquire", %{"inquiry" => %{"text" => text}})
      when is_binary(text) and byte_size(text) <= 2000 do
    if String.trim(text) == "" do
      s
    else
      %{
        s
        | inquiry: text,
          outreading: "IN-QUESTIONINGMENTING · What relation shall we inspect THROUGH HERE?"
      }
    end
  end

  def operate(s, "stage", %{"draft" => %{"text" => text}})
      when is_binary(text) and byte_size(text) <= 2000 do
    if String.trim(text) == "" or Map.has_key?(s.material, s.door) do
      s
    else
      record = %{
        id: "#{s.ship}/door-#{s.door}/material",
        text: text,
        ship: s.ship,
        from: s.here,
        door: s.door,
        pocket: "#{s.ship}/door-#{s.door}/Pocketing",
        bearing: s.diagonal,
        status: "STAGED",
        pinned?: false,
        acquired?: false,
        source: "Looking THROUGHING THROUGHING Glass"
      }

      %{s | material: Map.put(s.material, s.door, record)}
    end
  end

  def operate(s, "approach", _) do
    case Map.get(s.material, s.door) do
      nil -> s
      record -> %{s | approach: record}
    end
  end

  def operate(s, "configure", %{"config" => %{"bugs" => bugs, "restep" => restep}})
      when bugs in ~w(1 2 3) and restep in ~w(3 6 12),
      do: %{s | bugs: String.to_integer(bugs), restep: String.to_integer(restep)}

  def operate(s, _, _), do: s

  defp needle(s, command) do
    case SnailBody.operate(s.needle, command) do
      {:ok, body} ->
        %{
          s
          | needle: body,
            machine_notice:
              if(command == :return,
                do:
                  "Needle returned INTO Inkwell; Human hold upon this discrete piece of time relinquished.",
                else: nil
              )
        }

      _ ->
        s
    end
  end
end
