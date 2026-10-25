defmodule PublicSituationMachineTurnZero.Instrumentation do
  @moduledoc """
  Isolated already-standing Rail laboratory. Only `standing` is saved.
  Alignment is an explicit Human operation on a selected identity/bearing,
  never a conclusion drawn from SVG coordinates. No motor operations exist here.
  """
  defstruct origin: "A",
            standing: nil,
            tray?: false,
            held: nil,
            turn: 0,
            selected: nil,
            aligned?: false,
            over?: false,
            reciprocal?: false,
            illuminated?: false

  def new do
    %__MODULE__{
      standing: %{
        "from" => "A",
        "next" => nil,
        "passages" => [],
        "seated" => %{"station" => "A", "bearing" => "place"},
        "rail" => ["A", "B", "C"],
        "stations" => %{
          "A" => %{
            "label" => "Human Place-Square",
            "bearings" => ["place", "edge"],
            "parent" => nil
          },
          "B" => %{
            "label" => "Doll-side Square",
            "bearings" => ["square", "facing"],
            "parent" => nil
          },
          "C" => %{
            "label" => "Tensioning",
            "bearings" => ["tension", "toward-place"],
            "parent" => "A"
          }
        },
        "relations" => [
          %{
            "id" => "place-tension",
            "source" => "A",
            "target" => "C",
            "bearing" => "toward-place"
          }
        ]
      }
    }
  end

  def restore(standing),
    do: %__MODULE__{standing: standing, origin: standing["seated"]["station"]}

  def station(m, id), do: m.standing["stations"][id]
  def bearing(m), do: m.held && Enum.at(station(m, m.held)["bearings"], m.turn)
  def rail(m), do: Enum.map(m.standing["rail"], &Map.merge(station(m, &1), %{"id" => &1}))

  def selected_relation(m) do
    Enum.find(m.standing["relations"], fn relation ->
      m.selected == %{"station" => relation["target"], "bearing" => relation["bearing"]}
    end)
  end

  def available?(m, :select), do: m.tray? && m.held != nil
  def available?(m, :align), do: m.tray? && m.selected != nil
  def available?(m, :over), do: available?(m, :align) && m.aligned?
  def available?(m, :seat), do: available?(m, :over) && m.over?

  def operate(m, :tray),
    do: {:ok, %{restore(m.standing) | tray?: !m.tray?, reciprocal?: m.reciprocal?}}

  def operate(m, :pivot), do: {:ok, %{m | reciprocal?: !m.reciprocal?}}

  def operate(%{tray?: true} = m, {:lift, id}) do
    if station(m, id),
      do:
        {:ok,
         %{
           m
           | held: id,
             origin: m.standing["seated"]["station"],
             turn: 0,
             selected: nil,
             aligned?: false,
             over?: false,
             illuminated?: false
         }},
      else: {:error, :unknown_station}
  end

  def operate(m, :return),
    do: {:ok, %{restore(m.standing) | tray?: m.tray?, reciprocal?: m.reciprocal?}}

  def operate(%{tray?: true, held: id} = m, :turn) when not is_nil(id) do
    {:ok,
     %{
       m
       | turn: rem(m.turn + 1, length(station(m, id)["bearings"])),
         selected: nil,
         aligned?: false,
         over?: false,
         illuminated?: false
     }}
  end

  def operate(m, op) when op in [:select, :align, :over, :seat] do
    if available?(m, op) do
      case op do
        :select ->
          {:ok,
           %{
             m
             | selected: %{"station" => m.held, "bearing" => bearing(m)},
               aligned?: false,
               over?: false
           }}

        :align ->
          {:ok, %{m | aligned?: true}}

        :over ->
          {:ok, %{m | over?: true}}

        :seat ->
          {:ok,
           %{
             restore(Map.put(m.standing, "seated", m.selected))
             | tray?: m.tray?,
               reciprocal?: m.reciprocal?,
               origin: m.origin
           }}
      end
    else
      {:error, :unavailable}
    end
  end

  def operate(m, :illuminate) do
    if selected_relation(m),
      do: {:ok, %{m | illuminated?: !m.illuminated?}},
      else: {:error, :unavailable}
  end

  def operate(_, _), do: {:error, :unavailable}
end
