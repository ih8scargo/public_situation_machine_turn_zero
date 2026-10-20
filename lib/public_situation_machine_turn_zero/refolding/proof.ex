defmodule PublicSituationMachineTurnZero.Refolding.Proof do
  @moduledoc """
  Isolated consequential Standing proof. The domain owns the gesture boundary.
  RE-FOLD discards the apparatus; return loads only the consequential record and
  furnishes a fresh Regarding toward FROM and its material.
  """
  alias PublicSituationMachineTurnZero.Refolding.{Apparatus, MemoryStore, Standing}

  @catalogue %{
    "ENZO" => %{id: "ENZO", description: "FROM OUT OF THE GROUND", segments: 3},
    "HUCKLEBERRY" => %{id: "HUCKLEBERRY", description: "A possible Standing TOWARD", segments: 3}
  }
  def catalogue, do: @catalogue

  def return(store, key, adapter \\ MemoryStore) do
    standing = adapter.transact(store, key, &(&1 || %Standing{by_way_of: key}))
    %{standing: standing, apparatus: fresh(standing.from)}
  end

  def refold(session), do: %{session | apparatus: nil}
  def furnished(%{apparatus: %Apparatus{toward: name}}), do: Map.fetch!(@catalogue, name)

  def material(%{standing: standing, apparatus: %Apparatus{regarding: name}}),
    do: Map.get(standing.material, name)

  def gesture(store, key, session, action, target, adapter \\ MemoryStore)

  def gesture(_store, _key, %{apparatus: nil} = session, _action, _target, _adapter),
    do: session

  def gesture(store, key, session, action, target, adapter) do
    standing =
      adapter.transact(store, key, fn current ->
        consequentialize(current, action, target)
      end)

    apparatus =
      cond do
        action in ["zipper", "rezipper"] and Map.has_key?(@catalogue, target) ->
          fresh(standing.from)

        action in ["furnish", "regard", "approach", "traverse"] and
            Map.has_key?(@catalogue, target) ->
          posture(session.apparatus, action, target)

        true ->
          session.apparatus
      end

    %{standing: standing, apparatus: apparatus}
  end

  defp consequentialize(standing, action, target)
       when action in ["zipper", "rezipper"] and is_map_key(@catalogue, target) do
    operation = if action == "zipper", do: :zippering, else: :rezippering

    %{
      standing
      | from: target,
        consequence: %{operation: operation, from: standing.from, to: target}
    }
  end

  defp consequentialize(%Standing{from: "HUCKLEBERRY"} = standing, "material", _) do
    %{standing | material: Map.put(standing.material, standing.from, "A small leaf.")}
  end

  defp consequentialize(standing, _, _), do: standing

  defp fresh(name), do: %Apparatus{toward: name, regarding: name}
  defp posture(apparatus, "furnish", target), do: %{apparatus | toward: target, segment: 0}
  defp posture(apparatus, "regard", target), do: %{apparatus | toward: target, regarding: target}

  defp posture(apparatus, "approach", target),
    do: %{apparatus | toward: target, approached: target}

  defp posture(apparatus, "traverse", target) do
    %{
      apparatus
      | toward: target,
        regarding: target,
        segment: rem(apparatus.segment + 1, Map.fetch!(@catalogue, target).segments)
    }
  end
end
