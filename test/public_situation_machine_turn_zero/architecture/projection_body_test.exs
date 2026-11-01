defmodule PublicSituationMachineTurnZero.ProjectionBodyTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.ProjectionBody, as: B

  defp appointed do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 18, "pitch" => 9, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    m
  end

  test "three versioned normalized pairs furnish six distinguishable candidate sections, not six turns" do
    m = A.new()
    body = B.model(m)
    assert body["version"] == m.standing["projection_foundation"]["version"]
    assert String.contains?(body["status"], "PROVISIONAL")
    assert Enum.count(body["extents"], &(&1["family"] == "square")) == 3
    assert Enum.count(body["extents"], &(&1["family"] == "circle")) == 3
    assert length(Enum.uniq_by(body["extents"], & &1["id"])) == 6

    for extent <- body["extents"] do
      refute extent["furnished"]
      refute extent["occupied"]
      partner = Enum.find(body["extents"], &(&1["id"] == extent["pair"]))
      assert partner["pair"] == extent["id"]
      assert partner["plane"] == extent["plane"]
    end

    assert body["tunnel"] == nil
    assert m.standing["events"] == []
  end

  test "one immutable geometric body derives a continuous circle-transported tunnel through the appointed bearing" do
    m = appointed()
    standing = m.standing
    body = B.model(m)
    tunnel = body["tunnel"]
    assert length(tunnel["samples"]) == 97
    assert tunnel["entrance"] == standing["opening_geometry"]["stick"]["cob_center"]

    for {actual, expected} <-
          Enum.zip(
            hd(tunnel["samples"])["tangent"],
            standing["opening_geometry"]["stick"]["direction"]
          ),
        do: assert_in_delta(actual, expected, 1.0e-12)

    for sample <- tunnel["samples"] do
      assert_in_delta Enum.reduce(sample["tangent"], 0, &(&2 + &1 * &1)), 1, 1.0e-10
    end

    for [a, b] <- Enum.chunk_every(tunnel["samples"], 2, 1, :discard) do
      step =
        Enum.zip_with(a["point"], b["point"], &(&1 - &2))
        |> Enum.reduce(0, &(&2 + &1 * &1))
        |> :math.sqrt()

      assert step > 0 && step < tunnel["radius"] * 0.04
    end

    assert B.model(A.restore(standing)) == body
    assert m.standing == standing
    assert length(standing["events"]) == 3
    assert body["aperture"]["normal"] == [0, 0, 1]
    assert Enum.all?(body["floor"], &(Enum.at(&1, 1) == -1.2))
    assert Enum.all?(tunnel["markers"], &String.starts_with?(&1["text"], "TEST"))
    assert Enum.all?(tunnel["markers"], &String.contains?(&1["status"], "not CH-authored"))
  end
end
