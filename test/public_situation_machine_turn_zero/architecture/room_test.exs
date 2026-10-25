defmodule PublicSituationMachineTurnZero.Architecture.RoomTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.Room

  defp tunnel do
    Enum.reduce([:calibrate, :position, :appoint, :step], Lab.new(), fn op, lab ->
      {:ok, next} = Lab.operate(lab, op)
      next
    end)
  end

  test "Pointing-able rehearsal requires the little room and deliberate turn/release" do
    room = %Room{}
    assert {:error, :room_required} = Room.pointer(room, :draw)
    room = Room.enter(room)
    assert {:ok, room} = Room.pointer(room, :draw)
    refute Room.appointable?(room)
    assert {:ok, room} = Room.pointer(room, {:turn, 45})
    refute Room.appointable?(room)
    assert {:ok, room} = Room.pointer(room, :release)
    assert Room.appointable?(room)
    assert room.pointer?
    assert {:ok, held} = Room.pointer(room, :hold)
    refute Room.appointable?(held)
  end

  test "sheet corners, draw, square and relinquish never change underlying material" do
    lab = tunnel()
    standing = lab.standing
    room = Room.motion(%Room{}, 2.0, 0.4)
    assert {:ok, one} = Room.catch_corner(room, lab, "tunnel-notice", 0)
    assert {:ok, drawn} = Room.draw(one, 1.0)
    assert drawn.tension == 0.55
    assert {:error, :additional_corner_required} = Room.square(drawn)
    assert {:ok, same} = Room.catch_corner(drawn, lab, "tunnel-notice", 0)
    assert same.corners == [0]
    assert {:ok, two} = Room.catch_corner(same, lab, "tunnel-notice", 3)
    assert {:ok, square} = Room.square(two)
    assert square.tension == 1.0
    assert square.corners == [0, 3]
    assert Room.relinquish(square).sheet == nil
    assert lab.standing == standing
    assert lab.standing["materials"]["tunnel-notice"]["location"] == "ZEROETH-ONE"
    assert lab.standing["from"] == "ONE-APPROACH"
    assert length(lab.standing["passages"]) == 1
  end

  test "only material actually available along the Tunnel can be caught" do
    lab = tunnel()
    assert {:error, :sheet_not_available} = Room.catch_corner(%Room{}, lab, "quiet-aim", 0)
    assert {:error, :sheet_not_available} = Room.catch_corner(%Room{}, lab, "this-place", 0)

    assert {:error, :sheet_not_available} =
             Room.catch_corner(%Room{}, Lab.new(), "tunnel-notice", 0)

    assert {:error, :unknown_corner} = Room.catch_corner(%Room{}, lab, "tunnel-notice", 9)
    assert {:ok, _} = Room.catch_corner(Room.motion(%Room{}, 6, 0.1), lab, "quiet-aim", 2)
    bounded = Room.motion(%Room{}, 1.0e10, -1.0e10)
    assert bounded.position == 6.0 && bounded.across == -0.65
  end
end
