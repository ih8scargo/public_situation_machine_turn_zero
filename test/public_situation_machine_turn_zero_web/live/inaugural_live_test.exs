defmodule PublicSituationMachineTurnZeroWeb.InauguralLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "default route gates inherited NAV reception and retains opening provenance", %{conn: conn} do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 0, "pitch" => 0, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    {:ok, record} = Store.save(Store.create(), m.standing)
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}&mode=inaugural")
    assert has_element?(view, "#inaugural-first-puff")
    assert has_element?(view, "#inspect-cabinet-seat")
    render_hook(view, "traversal-rehearsal", %{"action" => "appoint", "revision" => 0})
    assert_reply view, %{accepted: false}
    render_hook(view, "inaugural", %{"action" => "puff-across", "revision" => 0})
    assert_reply view, %{accepted: true}
    render_hook(view, "traversal-rehearsal", %{"action" => "appoint", "revision" => 0})
    assert_reply view, %{accepted: true}
    {:ok, saved} = Store.fetch(record.id)
    assert Map.drop(saved.standing, ["traversal_rehearsal", "inaugural_approach"]) == m.standing
  end
end
