defmodule PublicSituationMachineTurnZero.Architecture.InnerApertureTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.Room

  defp tunnel do
    Enum.reduce([:calibrate, :position, :appoint, :step], Lab.new(), fn op, lab ->
      {:ok, next} = Lab.operate(lab, op)
      next
    end)
  end

  test "Inner Aperture resolves an identity with no corner ritual or source replacement" do
    lab = tunnel()
    standing = lab.standing
    assert {:ok, room} = Room.resolve(Room.motion(%Room{}, 2, 0.1), lab, "tunnel-notice")
    assert room.sheet == "tunnel-notice"
    assert room.corners == []
    assert room.tension == 1

    for direction <- ["xt", "yt", "down", "up", "yt"] do
      assert {:ok, next} = Room.look(room, direction)
      assert next.sheet == room.sheet
      assert next.regard == direction
      assert lab.standing == standing
    end

    assert Room.relinquish(room).sheet == nil
    assert lab.standing["materials"]["tunnel-notice"]["location"] == "ZEROETH-ONE"
    assert lab.standing["from"] == "ONE-APPROACH"
  end

  test "the same sheet resolves from either navigational approach without changing bearing or ancestry" do
    lab = tunnel()

    for position <- [1.1, 2.8, 1.8, 3.2, 2.0] do
      assert {:ok, room} = Room.resolve(Room.motion(%Room{}, position, 0), lab, "tunnel-notice")
      assert room.sheet == "tunnel-notice"
      assert lab.standing["tunnels"]["ZEROETH-ONE"]["toward"] == "ONE"
      assert [first] = lab.standing["passages"]
      assert first["operation"] == "STEP"
      assert first["from"] == "ZEROETH"
    end

    assert {:error, :sheet_not_available} = Room.resolve(%Room{}, Lab.new(), "tunnel-notice")
    assert {:error, :sheet_not_available} = Room.resolve(%Room{}, lab, "this-place")
  end

  test "XT context comprises real associations, not fabricated explanatory prose" do
    lab = tunnel()
    item = lab.standing["materials"]["toward-one"]
    context = Room.context(lab, item["id"])
    assert context.revisions == item["provenance"]
    assert context.relations == [lab.standing["relations"]["tc-appointed"]]
    refute Enum.any?(context.relations, &(&1["id"] == "quiet-enclosure"))
    assert Enum.any?(context.materials, &(&1["id"] == "from-zeroeth"))

    for material <- context.materials,
        do: assert(material == lab.standing["materials"][material["id"]])

    broad = Room.context(lab, nil)
    assert broad.origin == "ZEROETH"
    assert broad.location == "ZEROETH-ONE"
    assert Enum.all?(broad.relations, &(&1 == lab.standing["relations"][&1["id"]]))
  end

  test "calibration has a bounded Human range without redefining system geometry" do
    room = %Room{}
    assert {:ok, low} = Room.calibrate(room, -100)
    assert {:ok, high} = Room.calibrate(room, 100)
    assert low.readable_scale == 0.85
    assert high.readable_scale == 1.15

    assert Map.from_struct(low) |> Map.delete(:readable_scale) ==
             Map.from_struct(room) |> Map.delete(:readable_scale)

    assert {:error, :unknown_regard} = Room.look(room, "invented")
  end
end
