defmodule PublicSituationMachineTurnZero.Workshop.StringRibbon do
  # Geometry reconciliation: Authored provide/take remains rehearsal; it does not satisfy the revised physical acquisition contract.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "One bounded SnailWeave provide/take rehearsal. Inspection and software revisions are not constitutional turns."
  alias PublicSituationMachineTurnZero.Workshop.{SnailWeave, SnailBody, ComingAboardMachine}

  def new do
    source = SnailWeave.new()

    %{
      id: source["id"],
      revision: 0,
      registered?: false,
      source: source,
      material: nil,
      view: "flat",
      course: "ribbon",
      progress: 0.0,
      fold: 0.0,
      taken?: false,
      bugs: 1,
      from: "THIS HERE APPROACHING LANDINGING",
      next: "THIS NEXT APPROACHING LANDINGING"
    }
  end

  def operate(s, revision, command) do
    if revision == s.revision do
      case command(s, command) do
        {:ok, next} -> {:ok, %{next | revision: s.revision + 1}}
        error -> error
      end
    else
      {:error, :stale}
    end
  end

  defp command(%{registered?: false} = s, :register) do
    # This is explicit inheritance of workshop standing, not another public arrival tutorial.
    with {:ok, source} <-
           run(s.source, [{:pull, 1, -1}, :puff, :seat, {:appoint, "xt"}, {:appoint, "yt"}]) do
      {:ok, %{s | registered?: true, source: source}}
    end
  end

  defp command(%{registered?: true, material: nil} = s, {:provide, text})
       when is_binary(text) and byte_size(text) <= 160 do
    with true <- String.trim(text) != "",
         {:ok, source} <- run(s.source, [:pull_brace, {:quill, text}, :provide]),
         record <- List.last(source["body"]["material"]),
         {:ok, source} <- run(source, [{:register, record["id"]}, :settle]) do
      turn = List.last(source["turns"])

      material = %{
        id: record["id"],
        cargo_id: record["id"],
        ribbon_id: record["id"] <> ":ribbon",
        text: record["text"],
        source_piece: record["piece"],
        turn: turn["id"],
        interval: turn["interval"],
        arc: turn["arc"],
        from: s.from,
        toward: s.next,
        author: record["author"],
        status: "STAGED · furnished FOR Standing",
        pinned?: false,
        acquired?: false,
        office: source["offices"]["xt"]["id"]
      }

      {:ok, %{s | source: source, material: material, progress: 1.0}}
    else
      _ -> {:error, :human_marking_required}
    end
  end

  defp command(%{material: material, taken?: false} = s, :take) when not is_nil(material) do
    turn = List.last(s.source["turns"])

    with {:ok, source} <-
           run(s.source, [{:take, turn["id"], turn["passage"], "rehearsal", "Human FROM HERE"}]) do
      {:ok, %{s | source: source, taken?: true}}
    end
  end

  defp command(%{taken?: true} = s, :advance) do
    with {:ok, source} <- run(s.source, [:advance]), do: {:ok, %{s | source: source}}
  end

  defp command(s, {:inspect, view, course, progress, fold})
       when view in ~w(flat tunneling top roundabout) and
              course in ~w(ribbon square-lock rising pocketing triangles) and
              is_number(progress) and progress >= 0 and progress <= 1 and is_number(fold) and
              fold >= 0 and fold <= 1,
       do: {:ok, %{s | view: view, course: course, progress: progress, fold: fold}}

  defp command(s, {:bugs, count}) when count in [1, 2, 3], do: {:ok, %{s | bugs: count}}
  defp command(_, _), do: {:error, :unavailable}

  defp run(source, commands) do
    Enum.reduce_while(commands, {:ok, source}, fn command, {:ok, current} ->
      case SnailWeave.operate(current, current["revision"], command) do
        {:ok, next} -> {:cont, {:ok, next}}
        error -> {:halt, error}
      end
    end)
  end

  def material_course(%{material: nil}), do: []

  def material_course(s) do
    [a, b] = s.material.interval

    arc =
      Enum.map(0..24, fn i ->
        SnailBody.arc_point(a + (b - a) * i / 24) |> ComingAboardMachine.snail_point()
      end)

    # Explicit provisional connection to the preserved native arc, not a claimed physical joint.
    [[0, 0, 2], [0, 0, 0]] ++ arc
  end
end
