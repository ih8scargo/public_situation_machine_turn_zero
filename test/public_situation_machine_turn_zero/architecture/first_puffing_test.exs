defmodule PublicSituationMachineTurnZero.FirstPuffingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A

  test "reserved square is not embodied COB, and Landinging is distinct from Place" do
    m = A.puffing_witness()
    assert A.furnished?(m, "toy-box-standing")
    assert A.furnished?(m, "cob-square-standing")
    refute A.furnished?(m, "cob-standing")
    refute A.puffed?(m)

    assert m.standing["relations"]["human-upon-landinging"]["object"] ==
             "standinging-landinging-0"

    assert m.standing["relations"]["place-standing"]["subject"] == "place-for-human"
    assert m.standing["landings"]["standinging-landinging-0"]["number"] == 0
    refute Map.has_key?(m.standing["landings"], "next")
    assert {:error, :unavailable} = A.operate(m, :appoint_pointingable)
    assert {:error, :unavailable} = A.operate(m, :step)
  end

  test "one puff furnishes extent and COB through labor, retaining square and Human FROM" do
    before = A.puffing_witness()
    {:ok, after_puff} = A.operate(before, :puff)
    assert A.puffed?(after_puff)
    assert after_puff.standing["from"] == before.standing["from"]

    assert after_puff.standing["relations"]["cob-square-standing"] ==
             before.standing["relations"]["cob-square-standing"]

    assert after_puff.standing["relations"]["cob-standing"]["relation"] ==
             "EMBODIED BOBBINING FROM WITHIN"

    assert after_puff.standing["relations"]["cob-standing"]["object"] == "toy-box"
    event = List.last(after_puff.standing["events"])
    assert event["id"] == "first-puffing"
    assert event["actor"] == "human"
    assert event["from"] == event["from_after"]
    assert "possibility-extent-standing" in event["consequences"]
    assert "cob-square-standing" in event["dependencies"]
    ids = Enum.map(A.ancestry(after_puff, "cob-standing"), & &1["id"])
    assert "first-puffing-accomplished" in ids
    assert "cob-square-standing" in ids
    assert {:error, :unavailable} = A.operate(after_puff, :puff)
    assert A.restore(after_puff.standing).standing == after_puff.standing
  end

  test "pointing appointment preserves Pretending Stick ancestry WITH COB" do
    {:ok, m} = A.operate(A.puffing_witness(), :puff)
    {:ok, appointed} = A.operate(m, :appoint_pointingable)
    assert A.complete?(appointed)
    assert appointed.standing["from"] == m.standing["from"]

    assert appointed.standing["relations"]["pointingable-standing"]["pretending_ancestry"] ==
             "stick-available"

    assert Enum.any?(
             A.ancestry(appointed, "pointingable-standing"),
             &(&1["id"] == "cob-standing")
           )

    assert {:error, :unavailable} = A.operate(appointed, :appoint_pointingable)
    assert {:error, :unavailable} = A.operate(appointed, :step)
  end

  test "Road has distinct reserved spatial responsibility without a working motor" do
    m = A.puffing_witness()
    assert m.standing["relations"]["road-supply-behind-seat"]["object"] == "traversaling-seat"
    assert m.standing["relations"]["road-end-through-axle"]["relation"] == "RESERVED UP THROUGH"
    assert m.standing["relations"]["road-end-through-axle"]["object"] == "xt-yt-axle"
    refute A.furnished?(m, "road-running")
    assert {:error, :unavailable} = A.operate(m, :re_step)
  end
end
