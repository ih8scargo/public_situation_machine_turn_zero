defmodule PublicSituationMachineTurnZero.Workshop.ComingAboardApplianceTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.ComingAboardAppliance, as: A

  test "door orientation is inherited, staging and approach preserve provenance without acquiring" do
    s = A.new()
    [door | _] = A.doors()
    assert door.id == 0
    assert door.edge == "128,56 272,56"
    staged = A.operate(s, "stage", %{"draft" => %{"text" => "FROM HERE"}})
    record = staged.material[0]
    assert record.from == s.here
    assert record.ship == s.ship
    refute record.pinned?
    refute record.acquired?
    assert staged.approach == nil
    approached = A.operate(staged, "approach", %{})
    assert approached.approach == record

    changed =
      approached
      |> A.operate("door", %{"door" => "7"})
      |> A.operate("gallery", %{"selection" => "roundabout"})
      |> A.operate("view", %{"selection" => "dollside"})

    assert changed.approach == record
    assert changed.here == s.here
    assert changed.material == staged.material
    assert changed.illuminations == 0
    assert A.operate(staged, "stage", %{"draft" => %{"text" => "overwrite"}}) == staged
  end

  test "hook gates communication and neither input contaminates the other" do
    s = A.new()
    params = %{"inquiry" => %{"text" => "Which bearing?"}}
    assert A.operate(s, "inquire", params) == s
    open = A.operate(s, "hook", %{})
    inquired = A.operate(open, "inquire", params)
    assert inquired.material == %{}
    assert inquired.outreading =~ "IN-QUESTIONINGMENTING"
    closed = A.operate(inquired, "hook", %{})
    assert closed.outreading == nil
    assert A.operate(closed, "inquire", params) == closed
    draft = A.operate(inquired, "stage", %{"draft" => %{"text" => "material"}})
    assert draft.inquiry == inquired.inquiry
    assert draft.outreading == inquired.outreading
  end

  test "WITHIN-CAB PUFF and candidate selection change only the inspection" do
    flat = A.new()
    assert A.operate(flat, "cab-puff", %{}) == flat
    cab = A.operate(flat, "view", %{"selection" => "within-cab"})
    assert A.operate(cab, "cab-select", %{}) == cab

    inspecting = A.operate(cab, "cab-puff", %{})
    assert inspecting == %{cab | cab_inspection: :regarding}
    selected = A.operate(inspecting, "cab-select", %{})
    assert selected == %{cab | cab_inspection: :selected}

    for operation <- ~w(re-step nav-step pittoning zippering pin acquire) do
      assert A.operate(selected, operation, %{}) == selected
    end
  end

  test "ship isolation, bounded appointmentings and protected operations" do
    a = A.new()
    b = A.new()
    refute a.ship == b.ship
    refute a.cob == b.cob
    refute a.here == b.here
    assert {a.bugs, a.restep} == {1, 6}
    configured = A.operate(a, "configure", %{"config" => %{"bugs" => "3", "restep" => "12"}})
    assert {configured.bugs, configured.restep} == {3, 12}

    for op <- ~w(pin acquire re-step re-zipper pending-un-buttoning) do
      assert A.operate(configured, op, %{}) == configured
    end

    assert A.operate(a, "door", %{"door" => "8"}) == a
    assert A.operate(a, "stage", %{"draft" => %{"text" => String.duplicate("a", 2001)}}) == a
  end
end
