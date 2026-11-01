defmodule PublicSituationMachineTurnZero.CrossingRehearsalTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.CrossingRehearsal, as: C

  defp op(m, action, value, revision),
    do:
      A.operate(
        m,
        {:crossing_rehearsal, %{"action" => action, "value" => value, "revision" => revision}}
      )

  test "curved reception persists once and view/mode model reads never reset the held Pointing-able Thing" do
    m = A.new()
    assert {:error, :unavailable} = op(m, "receive", 1, 0)
    assert {:error, :unavailable} = op(m, "feed", 1, 0)
    {:ok, m} = op(m, "pull", 1, 0)
    {:ok, m} = op(m, "feed", 1, 1)
    {:ok, m} = op(m, "receive", 1, 2)
    assert C.model(m)["received"]
    stick = m.standing["opening_geometry"]["stick"]
    assert length(stick["curve"]["samples"]) == 65
    assert hd(stick["curve"]["samples"]) == [0.0, 0, 0.0]
    assert List.last(stick["curve"]["samples"]) == stick["tip"]
    assert {:error, :unavailable} = op(m, "receive", 1, 3)
    {:ok, reversed} = op(m, "pull", 0, 3)
    assert reversed.standing["opening_geometry"]["stick"] == stick

    for read <- [
          A.restore(reversed.standing),
          A.restore(Jason.decode!(Jason.encode!(reversed.standing)))
        ] do
      assert C.model(read)["stick"] == stick
      assert read.standing["from"] == A.new().standing["from"]

      assert Enum.map(read.standing["events"], & &1["id"]) == [
               "first-pull",
               "first-puffing",
               "appoint-pointingable"
             ]
    end
  end

  test "an earlier appointed instrument is inherited without inventing a paired pull or replacing its bearing" do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 4, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 31, "pitch" => -12, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    source = m.standing
    assert C.model(m)["received"]
    assert C.model(m)["pull"] == 0
    {:ok, m} = op(m, "pull", 1, 0)
    assert Map.delete(m.standing, "crossing_rehearsal") == source
    assert {:error, :unavailable} = op(m, "receive", 1, 1)
  end
end
