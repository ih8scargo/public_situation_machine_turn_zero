defmodule PublicSituationMachineTurnZero.Refolding.Proof do
  @moduledoc """
  Domain-owned lawful approach to the sole consequential boundary: ZIPPERING.
  Material may be Regarded FROM THERE before furnishing is authorized.
  Regard, Approach, Seating, STEP and worked furnishing are disposable relations.
  ZIPPERING atomically consequentializes FROM and worked material; RE-FOLD only
  relinquishes apparatus. Return furnishes fresh apparatus BY-WAY-OF Standing.
  """
  alias PublicSituationMachineTurnZero.Refolding.{Apparatus, MemoryStore, Standing}

  @catalogue %{
    "ENZO" => %{
      id: "ENZO",
      description: "FROM OUT OF THE GROUND",
      segments: 3,
      material: nil
    },
    "HUCKLEBERRY" => %{
      id: "HUCKLEBERRY",
      description: "An approaching Landinging, Regardable FROM THERE",
      segments: 3,
      material: "THIS ONE LEASHING"
    }
  }

  def catalogue, do: @catalogue

  def return(store, key, adapter \\ MemoryStore) do
    standing = adapter.transact(store, key, &(&1 || %Standing{by_way_of: key}))
    %{standing: standing, apparatus: fresh(standing)}
  end

  def refold(session), do: %{session | apparatus: nil}

  def furnished(%{apparatus: %Apparatus{regarding: name}}),
    do: Map.fetch!(@catalogue, name)

  @doc "Regardable material; catalogue visibility does not grant furnishing authority."
  def material(%{standing: standing, apparatus: %Apparatus{regarding: name}}) do
    Map.get(standing.material, name) || Map.fetch!(@catalogue, name).material
  end

  @doc "The same guard governs public controls and domain gestures."
  def allowed?(%{standing: standing, apparatus: %Apparatus{} = apparatus}, action, target) do
    anchored? = apparatus.from == standing.from and apparatus.basis == standing.consequence
    known? = Map.has_key?(@catalogue, target)
    regarded? = apparatus.regarding == target
    approached? = regarded? and apparatus.approached == target and target != standing.from
    seated? = approached? and apparatus.seated == target
    stepped? = seated? and apparatus.stepped == target

    anchored? and known? and
      case action do
        "regard" ->
          true

        "approach" ->
          regarded? and target != standing.from

        "traverse" ->
          approached?

        "seat" ->
          approached?

        "step" ->
          seated?

        "furnish" ->
          stepped? and Map.fetch!(@catalogue, target).material != nil

        "zipper" ->
          stepped? and apparatus.furnishing != nil and
            apparatus.furnishing.standing == target

        _ ->
          false
      end
  end

  def allowed?(_session, _action, _target), do: false

  def gesture(store, key, session, action, target, adapter \\ MemoryStore)

  def gesture(_store, _key, %{apparatus: nil} = session, _action, _target, _adapter),
    do: session

  def gesture(store, key, session, action, target, adapter) do
    standing =
      if action == "zipper" do
        adapter.transact(store, key, fn current ->
          if allowed?(%{session | standing: current}, action, target) do
            consequentialize(current, session.apparatus.furnishing)
          else
            current
          end
        end)
      else
        adapter.load(store, key)
      end

    # A different consequential basis invalidates all prior bodily authority.
    # Check ZIPPERING inside the transaction before re-furnishing stale apparatus.
    session = synchronize(session, standing)

    if action != "zipper" and allowed?(session, action, target) do
      %{session | apparatus: relate(session.apparatus, action, target)}
    else
      session
    end
  end

  @doc """
  Inspection-only projection of constitutional continuity and currently standing
  apparatus relations. It never writes state or records attempted gestures.
  """
  def continuity(session) do
    nodes =
      session.standing.consequence
      |> consequential_nodes()
      |> Enum.with_index(fn {kind, name}, index ->
        text = if kind == :from, do: "FROM #{name}", else: "ZIPPERING"

        %{
          id: "consequence-#{index}",
          scope: :consequential,
          kind: kind,
          standing: name,
          text: text
        }
      end)

    nodes ++ apparatus_nodes(session.apparatus)
  end

  defp consequentialize(standing, %{standing: target, material: material}) do
    %{
      standing
      | from: target,
        material: Map.put(standing.material, target, material),
        consequence: %{
          operation: :zippering,
          from: standing.from,
          to: target,
          prior: standing.consequence
        }
    }
  end

  defp synchronize(session, standing) do
    if session.standing.consequence == standing.consequence do
      %{session | standing: standing}
    else
      %{standing: standing, apparatus: fresh(standing)}
    end
  end

  defp fresh(standing) do
    %Apparatus{from: standing.from, basis: standing.consequence, regarding: standing.from}
  end

  defp relate(%Apparatus{regarding: target} = apparatus, "regard", target), do: apparatus

  defp relate(apparatus, "regard", target) do
    %Apparatus{from: apparatus.from, basis: apparatus.basis, regarding: target}
  end

  defp relate(apparatus, "approach", target), do: %{apparatus | approached: target}
  defp relate(apparatus, "seat", target), do: %{apparatus | seated: target}
  defp relate(apparatus, "step", target), do: %{apparatus | stepped: target}

  defp relate(apparatus, "furnish", target) do
    %{
      apparatus
      | furnishing: %{standing: target, material: Map.fetch!(@catalogue, target).material}
    }
  end

  defp relate(apparatus, "traverse", target) do
    %{apparatus | segment: rem(apparatus.segment + 1, Map.fetch!(@catalogue, target).segments)}
  end

  defp consequential_nodes(%{operation: :initial, from: name}), do: [{:from, name}]

  defp consequential_nodes(%{operation: :zippering, to: name, prior: prior}) do
    consequential_nodes(prior) ++ [{:zippering, name}, {:from, name}]
  end

  defp apparatus_nodes(nil), do: []

  defp apparatus_nodes(apparatus) do
    [
      {:apparatus, apparatus.from,
       "APPARATUS FURNISHED FROM #{apparatus.from} · BY-WAY-OF Standing"},
      {:regarding, apparatus.regarding, "REGARDING TOWARD #{apparatus.regarding} FROM THERE"},
      {:approach, apparatus.approached, "APPROACHING #{apparatus.approached}"},
      {:seating, apparatus.seated, "THIS NEXT APPROACHINGING LANDINGING SEATED TOWARD FROM HERE"},
      {:step, apparatus.stepped, "STEP TOWARD #{apparatus.stepped}"},
      {:furnishing, apparatus.furnishing && apparatus.furnishing.standing,
       "FURNISHINGMENTING · awaiting ZIPPERING"}
    ]
    |> Enum.filter(fn {_kind, name, _text} -> name != nil end)
    |> Enum.map(fn {kind, name, text} ->
      %{id: Atom.to_string(kind), scope: :ephemeral, kind: kind, standing: name, text: text}
    end)
  end
end
