defmodule PublicSituationMachineTurnZero.Architecture.CraftTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.{Craft, Projection}

  defp drive(lab, operations),
    do:
      Enum.reduce(operations, lab, fn op, state ->
        assert {:ok, next} = Lab.operate(state, {:craft, op})
        next
      end)

  defp held_tc do
    drive(Lab.new(), [:open, :draw_pointer, :box, {:point, "projected-tc"}, :grasp])
  end

  test "Co-Bobbing and Doll have separate identities before the Pointing-able Thing is drawn" do
    lab = Lab.new()
    assert lab.standing["entities"]["co-bobbing"]["job"] =~ "ATTENTIONING"

    refute lab.standing["entities"]["co-bobbing"] ==
             lab.standing["entities"]["co-situationing-doll"]

    refute lab.craft.pointer?
    assert Craft.articulation(lab) == "rest"
    assert {:error, :labor_locality_required} = Lab.operate(lab, {:craft, :grasp})
  end

  test "pointing, grasp, lift, arbitrary pose, turn, approach and release do not furnish Standing" do
    initial = Lab.new()
    lab = held_tc()
    assert Craft.articulation(lab) == "grasp"
    lab = drive(lab, [:lift, {:turn, 30}, {:pose, 640, 390, 360}, :toward, :align])
    assert Craft.articulation(lab) == "square"
    assert lab.standing == initial.standing
    # Even exact pixel overlap, alignment and an explicit seating attempt cannot
    # replace the missing Pointing-able calibration dependency.
    assert {:error, :unavailable_here} = Lab.operate(lab, {:craft, :seat})
    released = drive(lab, [:release])
    assert released.craft.held == nil
    assert released.standing == initial.standing
    assert Craft.articulation(released) in ["offer", "rest"]
  end

  test "the TC can be seated explicitly and a wrapped Buckle rehearses Appointmenting without passage" do
    initial = Lab.new()

    lab =
      drive(initial, [
        :open,
        :draw_pointer,
        {:point, "calibration-mark"},
        :calibrate,
        :box,
        {:point, "projected-tc"},
        :grasp,
        :lift,
        {:turn, 30},
        :toward,
        :align
      ])

    assert {:ok, seated} = Lab.operate(lab, {:craft, :seat})
    assert Lab.furnished?(seated, "tc-positioned")
    refute Lab.furnished?(seated, "tc-appointed")
    assert seated.craft.held == nil
    assert seated.craft.offered == "square-buckle"
    buckling = drive(seated, [{:point, "square-buckle"}, :grasp, {:turn, 30}, :toward, :align])
    assert {:error, :wrap_and_align_first} = Lab.operate(buckling, {:craft, :buckle})
    wrapped = drive(buckling, [:wrap])
    assert wrapped.standing == seated.standing
    appointed = drive(wrapped, [:buckle])
    assert Lab.zeroeth_complete?(appointed)
    assert appointed.standing["relations"]["tc-appointed"]["provenance"] =~ "Buckle"
    assert appointed.standing["from"] == "ZEROETH"
    assert appointed.standing["passages"] == []

    assert appointed.standing["entities"]["actual-tc"] ==
             initial.standing["entities"]["actual-tc"]

    assert {:ok, stepped} = Lab.operate(appointed, :step)
    assert length(stepped.standing["passages"]) == 1
    assert {:error, :labor_locality_required} = Lab.operate(stepped, {:craft, :open})
  end

  test "turning or carrying invalidates alignment and a read-only inscription never becomes graspable" do
    lab = held_tc() |> drive([:toward, :align, {:turn, 30}])
    refute lab.craft.aligned?
    assert {:error, :select_and_align_receiver} = Lab.operate(lab, {:craft, :seat})
    lab = drive(lab, [:release, {:point, "this-place"}])
    refute Craft.graspable?(lab, "this-place")
    assert {:error, :not_furnished_for_grasp} = Lab.operate(lab, {:craft, :grasp})
    # Discovering the Buckle first is allowed, but it cannot appoint an absent TC.
    buckle = drive(lab, [:next_piece, {:point, "square-buckle"}, :grasp, :toward, :align])
    assert {:error, :seated_tc_required_for_wrap} = Lab.operate(buckle, {:craft, :wrap})
  end

  test "wheel, material approach, directional reading NAV and back preserve the same ledger" do
    lab = Lab.new()
    assert {:ok, turned} = Lab.operate(lab, {:wheel, 73.5})
    assert turned.wheel == 73.5
    assert turned.nav == 0
    assert turned.standing == lab.standing
    assert {:ok, approached} = Lab.operate(turned, {:approach, "this-place"})
    assert {:ok, close} = Lab.operate(approached, {:approach, "this-place"})
    assert close.approach_depth == 2
    assert {:ok, read} = Lab.operate(close, {:read_nav, 1, 1})
    assert read.read_x == 1 && read.read_y == 1
    assert {:ok, back} = Lab.operate(read, :back_regard)
    assert {:ok, broad} = Lab.operate(back, :back_regard)
    assert broad.approach == nil
    assert broad.standing == lab.standing

    assert Enum.map(Projection.materials(lab), & &1["id"]) ==
             Enum.map(Projection.materials(read), & &1["id"])

    assert {:error, :not_available_for_regard} = Lab.operate(lab, {:approach, "tunnel-notice"})
  end

  test "OFF and reload discard handling without deleting seated relations or publishing local material" do
    lab = held_tc() |> drive([:lift, :toward, :align])
    assert {:ok, off} = Lab.operate(lab, :projection)
    assert off.craft == %Craft{}
    assert off.standing == lab.standing
    assert Lab.restore(lab.standing).craft == %Craft{}
    local = lab.standing["materials"]["this-place"]
    assert {:ok, edited} = Lab.compose(lab, "this-place", %{"text" => "Local revision"})
    assert edited.standing["materials"]["this-place"]["location"] == local["location"]

    assert edited.standing["materials"]["tunnel-notice"] ==
             lab.standing["materials"]["tunnel-notice"]
  end

  test "older records gain apparatus identities additively without rewriting any recovered work" do
    initial = Lab.new().standing
    old = put_in(initial["entities"], Map.drop(initial["entities"], Map.keys(Craft.catalog())))
    restored = Lab.restore(old).standing
    assert Map.delete(restored, "entities") == Map.delete(old, "entities")
    assert Map.take(restored["entities"], Map.keys(old["entities"])) == old["entities"]
    assert restored == initial
  end
end
