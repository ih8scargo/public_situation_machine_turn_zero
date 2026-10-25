defmodule PublicSituationMachineTurnZero.Architecture do
  @moduledoc """
  First architectural slice, isolated from the motor and instrumentation benches.
  Standing contains authored material and lawful consequences. The remaining
  struct fields are ephemeral Regard; none are saved. STEP admits the already
  registered ZEROETH–ONE course toward ONE's receiving approach, not a completed ONE.
  """
  alias PublicSituationMachineTurnZero.Architecture.{Seed, Craft}
  import Ecto.Changeset

  defstruct standing: nil,
            projection?: true,
            flat?: false,
            bearing: "approach",
            nav: 0,
            wheel: 0.0,
            approach: nil,
            approach_depth: 0,
            read_x: 0,
            read_y: 0,
            craft: nil

  @material_types %{
    title: :string,
    text: :string,
    location: :string,
    origin: :string,
    region: :string,
    bearing: :string,
    course: :integer,
    categories: {:array, :string},
    dependencies: {:array, :string}
  }
  @toy_types %{
    label: :string,
    encounter: :string,
    aim: :string,
    dependencies: {:array, :string},
    pretendingable: :boolean,
    usingable: :boolean,
    job: :string,
    provenance: :string,
    notes: :string
  }

  def new, do: restore(Seed.standing())

  def restore(standing) do
    # Additive fixture registration. No relation, material, inventory or passage
    # is rewritten when an older composition acquires these apparatus identities.
    entities = Map.merge(Craft.catalog(), standing["entities"])

    %__MODULE__{
      standing: standing |> Map.put("entities", entities) |> Craft.register_inventory(),
      craft: %Craft{}
    }
  end

  def stepped?(m), do: m.standing["passages"] != []
  def zeroeth_complete?(m), do: furnished?(m, "tc-appointed")
  def quiet_complete?(m), do: furnished?(m, "quiet-enclosure")
  def furnished?(m, id), do: Map.has_key?(m.standing["relations"], id)

  def dependency_ids(m),
    do:
      Enum.sort(Map.keys(m.standing["relations"]) ++ Map.keys(m.standing["requirements"]))
      |> Enum.uniq()

  def dependencies_hold?(m, ids), do: Enum.all?(ids, &furnished?(m, &1))
  def available?(m, :step), do: m.projection? && !stepped?(m) && zeroeth_complete?(m)
  def available?(m, :nav), do: m.projection? && stepped?(m)

  def available?(m, op) when op in [:calibrate, :position, :appoint] do
    id = operation_relation(op)

    m.projection? && !stepped?(m) && !furnished?(m, id) &&
      dependencies_hold?(m, m.standing["requirements"][id])
  end

  def next(m),
    do:
      if(!stepped?(m) && zeroeth_complete?(m),
        do: %{"id" => "first-landing", "toward" => "ONE", "by_way_of" => "ZEROETH-ONE"}
      )

  def regarding_materials(m) do
    location = if stepped?(m), do: "ZEROETH-ONE", else: "ZEROETH"

    m.standing["materials"]
    |> Map.values()
    |> Enum.filter(fn item ->
      (item["location"] == location && (!stepped?(m) || abs(item["course"] - m.nav) <= 2)) ||
        (stepped?(m) && m.nav >= 4 && item["location"] == "ONE")
    end)
  end

  def operate(m, {:craft, op}), do: Craft.operate(m, op)

  def operate(%{projection?: true} = m, {:wheel, angle})
      when is_number(angle) and angle >= -100_000 and angle <= 100_000 do
    angle = angle - :math.floor(angle / 360) * 360

    bearing =
      cond do
        angle >= 45 && angle < 135 -> "wallward"
        angle >= 135 && angle < 225 -> "groundward"
        angle >= 225 && angle < 315 -> "toybox"
        true -> "approach"
      end

    {:ok, %{m | wheel: angle, bearing: bearing, approach: nil, approach_depth: 0}}
  end

  def operate(%{projection?: true} = m, {:approach, id}) do
    if !m.craft.open? && Enum.any?(regarding_materials(m), &(&1["id"] == id)),
      do:
        {:ok,
         %{
           m
           | approach: id,
             approach_depth: min(2, if(m.approach == id, do: m.approach_depth + 1, else: 1)),
             read_x: 0,
             read_y: 0
         }},
      else: {:error, :not_available_for_regard}
  end

  def operate(%{projection?: true, approach: id} = m, :back_regard) when not is_nil(id) do
    depth = max(0, m.approach_depth - 1)

    {:ok,
     %{
       m
       | approach_depth: depth,
         approach: if(depth == 0, do: nil, else: id),
         read_x: 0,
         read_y: 0
     }}
  end

  def operate(%{projection?: true, approach: id} = m, {:read_nav, x, y})
      when not is_nil(id) and x in [-1, 0, 1] and y in [-1, 0, 1],
      do:
        {:ok, %{m | read_x: max(-4, min(4, m.read_x + x)), read_y: max(0, min(20, m.read_y + y))}}

  def operate(m, :projection), do: {:ok, %{restore(m.standing) | projection?: !m.projection?}}
  def operate(%{projection?: true} = m, :flat), do: {:ok, %{m | flat?: !m.flat?}}

  def operate(%{projection?: true} = m, {:pivot, bearing}) do
    if bearing in Seed.bearings(),
      do:
        {:ok,
         %{
           m
           | bearing: bearing,
             wheel:
               case bearing do
                 "approach" -> 0.0
                 "wallward" -> 90.0
                 "groundward" -> 180.0
                 "toybox" -> 270.0
               end
         }},
      else: {:error, :unknown_bearing}
  end

  def operate(m, {:nav, delta}) when delta in [-1, 1] do
    if available?(m, :nav),
      do: {:ok, %{m | nav: min(6, max(0, m.nav + delta)), approach: nil, approach_depth: 0}},
      else: {:error, :step_required}
  end

  def operate(m, op) when op in [:calibrate, :position, :appoint] do
    if available?(m, op) do
      id = operation_relation(op)

      note =
        case op do
          :calibrate ->
            "Human exercised Pointing-able calibration using development instrumentation FROM ZEROETH."

          :position ->
            "Human placed the projected TC furnishing in its grounded Little Square Chair relation. Actual TC did not move."

          :appoint ->
            "Human appointed projected TC furnishing FOR the already-present actual terrestrial computer. No passage."
        end

      relation = Seed.relation(id, "ZEROETH", m.standing["requirements"][id], note)
      {:ok, %{m | standing: put_in(m.standing, ["relations", id], relation)}}
    else
      {:error, :unavailable_here}
    end
  end

  def operate(m, :step) do
    if available?(m, :step) do
      passage = %{
        "id" => "first-step",
        "operation" => "STEP",
        "from" => "ZEROETH",
        "toward" => "ONE-APPROACH",
        "by_way_of" => "ZEROETH-ONE",
        "inherited" => Enum.sort(Map.keys(m.standing["relations"]))
      }

      {:ok,
       %{
         m
         | standing:
             m.standing |> Map.put("from", "ONE-APPROACH") |> Map.put("passages", [passage]),
           nav: 0,
           craft: %Craft{},
           approach: nil,
           approach_depth: 0
       }}
    else
      {:error, :first_relation_required}
    end
  end

  def operate(_, _), do: {:error, :unavailable}

  # Development composement, explicitly authored FROM ONE; not a Human tunnel operation.
  def fixture_enclosure(m, enabled?) when is_boolean(enabled?) do
    if dependencies_hold?(m, m.standing["requirements"]["quiet-enclosure"]) do
      relations =
        if enabled? do
          Map.put(
            m.standing["relations"],
            "quiet-enclosure",
            Seed.relation(
              "quiet-enclosure",
              "ONE",
              ["tc-appointed"],
              "DEVELOPMENT FIXTURE ONLY, composed FROM ONE; public enclosingmenting labor unresolved."
            )
            |> Map.put("kind", "development fixture")
          )
        else
          Map.delete(m.standing["relations"], "quiet-enclosure")
        end

      {:ok, %{m | standing: Map.put(m.standing, "relations", relations)}}
    else
      {:error, :appointment_required}
    end
  end

  def material_changeset(m, material, attrs \\ %{}) do
    {typed(material, @material_types), @material_types}
    |> cast(normalize_lists(attrs), Map.keys(@material_types))
    |> validate_required([
      :title,
      :text,
      :location,
      :origin,
      :region,
      :bearing,
      :course,
      :categories
    ])
    |> validate_length(:title, max: 160)
    |> validate_length(:text, max: 12000)
    |> validate_inclusion(
      :location,
      Map.keys(m.standing["localities"]) ++ Map.keys(m.standing["tunnels"])
    )
    |> validate_inclusion(:origin, Map.keys(m.standing["localities"]))
    |> validate_inclusion(:region, Seed.regions())
    |> validate_inclusion(:bearing, Seed.bearings())
    |> validate_number(:course, greater_than_or_equal_to: 0, less_than_or_equal_to: 6)
    |> validate_subset(:categories, Seed.categories())
    |> validate_subset(:dependencies, dependency_ids(m))
    |> validate_tunnel_origin(m)
  end

  def compose(m, id, attrs) do
    existing = m.standing["materials"][id] || %{}
    cs = material_changeset(m, existing, attrs)

    if cs.valid? do
      fields = apply_changes(cs) |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      revision = Map.get(existing, "revision", 0) + 1
      location = fields["location"]

      toward =
        if Map.has_key?(m.standing["tunnels"], location),
          do: m.standing["tunnels"][location]["toward"],
          else: location

      item =
        Map.merge(fields, %{
          "id" => id,
          "revision" => revision,
          "toward" => toward,
          "provenance" =>
            Map.get(existing, "provenance", []) ++
              [%{"origin" => fields["origin"], "action" => "composement", "revision" => revision}]
        })

      {:ok, %{m | standing: put_in(m.standing, ["materials", id], item)}}
    else
      {:error, %{cs | action: :validate}}
    end
  end

  def toy_changeset(m, item, attrs \\ %{}) do
    {typed(item, @toy_types), @toy_types}
    |> cast(normalize_lists(attrs), Map.keys(@toy_types))
    |> validate_required([:label, :encounter, :aim, :job, :provenance])
    |> validate_inclusion(:encounter, Seed.localities())
    |> validate_subset(:dependencies, dependency_ids(m))
    |> validate_length(:label, max: 200)
  end

  def compose_toy(m, id, attrs) do
    case m.standing["toys"][id] do
      nil ->
        {:error, :unknown_toy}

      item ->
        cs = toy_changeset(m, item, attrs)

        if cs.valid? do
          changes = apply_changes(cs) |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
          {:ok, %{m | standing: put_in(m.standing, ["toys", id], Map.merge(item, changes))}}
        else
          {:error, %{cs | action: :validate}}
        end
    end
  end

  defp normalize_lists(attrs) do
    Enum.reduce(["categories", "dependencies"], attrs, fn key, acc ->
      case Map.get(acc, key) do
        values when is_list(values) -> Map.put(acc, key, Enum.reject(values, &(&1 == "")))
        _ -> acc
      end
    end)
  end

  defp typed(map, types),
    do:
      Map.new(types, fn {key, _} ->
        {key,
         Map.get(map, Atom.to_string(key), if(match?({:array, _}, types[key]), do: [], else: nil))}
      end)

  defp validate_tunnel_origin(cs, m) do
    case m.standing["tunnels"][get_field(cs, :location)] do
      nil ->
        cs

      tunnel ->
        if get_field(cs, :origin) == tunnel["from"],
          do: cs,
          else:
            add_error(cs, :origin, "must be the Tunnel's furnishing locality #{tunnel["from"]}")
    end
  end

  defp operation_relation(:calibrate), do: "pointing-calibrated"
  defp operation_relation(:position), do: "tc-positioned"
  defp operation_relation(:appoint), do: "tc-appointed"
end
