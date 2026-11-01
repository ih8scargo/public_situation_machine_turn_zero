defmodule PublicSituationMachineTurnZeroWeb.DrawerLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.{Diorama, Store}

  defp appointed_record do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 12, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 19, "pitch" => -8, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    {:ok, r} = Store.save(Store.create(), m.standing)
    r
  end

  defp operation(view, record_id, params) do
    {:ok, before} = Store.fetch(record_id)
    revision = Diorama.mechanical(A.restore(before.standing))["revision"]
    render_hook(view, "diorama-operation", Map.put(params, "revision", revision))
  end

  test "browser hook boundary persists only fourth furnishing plus recoverable mechanical condition",
       %{conn: conn} do
    r = appointed_record()
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=retained")
    operation(v, r.id, %{"action" => "travel", "progress" => 1})
    assert_reply v, %{accepted: false}
    render_hook(v, "second-puff", %{})
    assert_reply v, %{accepted: true}
    {:ok, puffed} = Store.fetch(r.id)

    assert Enum.map(puffed.standing["events"], & &1["id"]) == [
             "first-pull",
             "first-puffing",
             "appoint-pointingable",
             "second-puffing"
           ]

    assert Enum.take(puffed.standing["events"], 3) == r.standing["events"]
    render_hook(v, "second-puff", %{})
    assert_reply v, %{accepted: false}
    operation(v, r.id, %{"action" => "compose", "side" => "ch", "slot" => 2})
    assert_reply v, %{accepted: true}
    operation(v, r.id, %{"action" => "compose", "side" => "cob", "slot" => 0})
    assert_reply v, %{accepted: true}
    operation(v, r.id, %{"action" => "travel", "progress" => 0.5})
    assert_reply v, %{accepted: true}
    operation(v, r.id, %{"action" => "travel", "progress" => 1})
    assert_reply v, %{accepted: true}
    {:ok, locked} = Store.fetch(r.id)
    assert locked.standing["diorama_operation"]["detent"]
    {:ok, resumed, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=retained")
    assert has_element?(resumed, "#opening-geometry[phx-hook=ElementaryOpening]")
    operation(resumed, r.id, %{"action" => "travel", "progress" => 0})
    assert_reply resumed, %{accepted: false}
    operation(resumed, r.id, %{"action" => "release"})
    assert_reply resumed, %{accepted: true}
    operation(resumed, r.id, %{"action" => "travel", "progress" => 0})
    assert_reply resumed, %{accepted: true}
    {:ok, returned} = Store.fetch(r.id)
    assert Map.delete(returned.standing, "diorama_operation") == puffed.standing
    assert returned.standing["from"] == r.standing["from"]
    assert returned.standing["localities"] == r.standing["localities"]
  end

  test "concurrent mechanical operation adopts persisted condition without overwriting it", %{
    conn: conn
  } do
    r = appointed_record()
    {:ok, m} = A.operate(A.restore(r.standing), :second_puff)
    {:ok, r} = Store.save(r, m.standing)
    path = ~p"/experiments/architecture?id=#{r.id}&mode=retained"
    {:ok, one, _} = live(conn, path)
    {:ok, two, _} = live(conn, path)
    params = %{"action" => "compose", "side" => "ch", "slot" => 0, "revision" => 0}
    render_hook(one, "diorama-operation", params)
    assert_reply one, %{accepted: true}
    render_hook(two, "diorama-operation", Map.put(params, "slot", 2))
    assert_reply two, %{accepted: false}
    assert has_element?(two, "#rehearsal-status")
    {:ok, held} = Store.fetch(r.id)
    assert held.standing["diorama_operation"]["ch_slot"] == 0
    assert length(held.standing["events"]) == 4
  end
end
