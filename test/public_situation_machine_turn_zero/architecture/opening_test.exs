defmodule PublicSituationMachineTurnZero.OpeningTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Opening
  defp pull(m \\ A.new()), do: A.operate(m, {:opening_pull, %{"dx" => 15, "dy" => -20}})

  defp puff do
    {:ok, m} = pull()
    A.operate(m, :puff)
  end

  test "initial sheet has one planar circle and no unearned volume or later apparatus" do
    m = A.new()

    assert Map.keys(m.standing["opening_geometry"]) |> Enum.sort() == [
             "circle",
             "purchase",
             "sheet"
           ]

    assert m.standing["opening_geometry"]["sheet"]["half_width"] ==
             m.standing["opening_geometry"]["sheet"]["half_height"]

    assert m.standing["events"] == []
    refute A.opened?(m)
    assert {:error, :unavailable} = A.operate(m, :puff)
    assert {:error, :unavailable} = A.operate(m, :opening_appoint)

    for key <- ["landings", "road", "geometry", "stations"],
        do: refute(Map.has_key?(m.standing, key))
  end

  test "pull alone earns wireframe toward Place and initial square; circle identity unchanged" do
    before = A.new()
    assert {:error, :unavailable} = A.operate(before, {:opening_pull, %{"dx" => 0, "dy" => 0}})
    {:ok, m} = pull(before)
    assert A.opened?(m)

    assert m.standing["opening_geometry"]["circle"] ==
             before.standing["opening_geometry"]["circle"]

    assert m.standing["opening_geometry"]["cob"]["kind"] == "square"
    refute Map.has_key?(m.standing["opening_geometry"], "janusite")
    assert List.last(m.standing["events"])["id"] == "first-pull"
    assert m.standing["relations"]["opening-accomplished"]["object"] == "place-for-human"
    assert {:error, :unavailable} = pull(m)
  end

  test "puff earns JANUSITE and outward rounded COB without moving Human FROM" do
    before = A.new()
    {:ok, m} = puff()
    refute Map.has_key?(m.standing["opening_geometry"], "receiver")
    assert m.standing["opening_geometry"]["aperture"]["relation"] == "aperture-available"
    assert A.puffed?(m)
    assert m.standing["opening_geometry"]["cob"]["kind"] == "rounded"

    assert Enum.at(m.standing["opening_geometry"]["cob"]["center"], 0) >
             Enum.at(m.standing["opening_geometry"]["wireframe"]["max"], 0)

    assert m.standing["from"] == before.standing["from"]
    assert Enum.map(m.standing["events"], & &1["id"]) == ["first-pull", "first-puffing"]
    assert Enum.any?(A.ancestry(m, "cob-standing"), &(&1["id"] == "cob-square-standing"))
    assert {:error, :unavailable} = A.operate(m, :puff)
  end

  test "partial extension cannot lock; lock is staging; UP OVER persists exact Human bearing" do
    {:ok, m} = puff()

    assert {:error, :unavailable} =
             A.operate(
               m,
               {:opening_feed,
                %{"yaw" => 37, "pitch" => -12, "length" => 2.6, "extension" => 0.8}}
             )

    {:ok, locked} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 37, "pitch" => -12, "length" => 2.6, "extension" => 1}}
      )

    assert locked.standing == m.standing
    refute A.complete?(locked)
    assert A.restore(locked.standing).opening_stage == nil
    {:ok, appointed} = A.operate(locked, :opening_appoint)
    assert A.complete?(appointed)
    stick = appointed.standing["opening_geometry"]["stick"]
    assert stick["receiver"]["cylinder"]["axis"] == stick["direction"]
    assert stick["receiver"]["grasp"]["kind"] == "four-point take-hold"

    assert appointed.standing["relations"]["receiving-cylinder-standing"]["provenance"] ==
             "appoint-pointingable"

    assert Enum.any?(
             A.ancestry(appointed, "receiving-cylinder-standing"),
             &(&1["id"] == "aperture-available")
           )

    assert stick["yaw"] == 37
    assert stick["pitch"] == -12
    assert_in_delta Enum.map(stick["direction"], &(&1 * &1)) |> Enum.sum(), 1, 0.000001
    assert appointed.standing["opening_geometry"]["cob"]["orientation"] == stick["direction"]
    assert List.last(appointed.standing["events"])["furnished_geometry"] == stick

    assert appointed.standing["relations"]["pointingable-standing"]["pretending_ancestry"] ==
             "stick-available"

    assert A.restore(appointed.standing).standing == appointed.standing
    assert {:error, :unavailable} = A.operate(appointed, :opening_appoint)
    assert {:error, :unavailable} = A.operate(m, :appoint_pointingable)
  end

  test "invalid bearings cannot substitute arbitrary camera or direction data" do
    for params <- [
          %{},
          %{"yaw" => 90, "pitch" => 0, "length" => 2.6, "extension" => 1},
          %{"yaw" => "20", "pitch" => 0, "length" => 2.6, "extension" => 1},
          %{"yaw" => 20, "pitch" => 46, "length" => 2.6, "extension" => 1}
        ],
        do: assert({:error, :invalid_bearing} = Opening.bearing(params))
  end
end
