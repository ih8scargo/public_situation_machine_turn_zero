defmodule PublicSituationMachineTurnZeroWeb.ApplianceLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "cab retains an explicitly appointed same-turn continuation and rejects stale issuance", %{
    conn: conn
  } do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 12, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 0, "pitch" => 0, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    {:ok, r} = Store.save(Store.create(), m.standing)
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=companion")
    assert has_element?(view, "#appliance-cab")
    assert has_element?(view, "#crossing-width")
    assert has_element?(view, "#course-map")
    assert has_element?(view, "#cob-handoff-depth")
    assert has_element?(view, "#treadmill-strong[data-treadmill-purchase=strong]")
    assert has_element?(view, "#take-cob-regarding")
    assert has_element?(view, "#cob-immediate-stop")
    render_hook(view, "traversal-rehearsal", %{"action" => "appoint", "revision" => 0})
    assert_reply view, %{accepted: true}

    render_hook(view, "traversal-rehearsal", %{
      "action" => "appoint-continuation",
      "revision" => 1
    })

    assert_reply view, %{accepted: true}
    render_hook(view, "traversal-rehearsal", %{"action" => "issue", "revision" => 1})
    assert_reply view, %{accepted: false}
    render_hook(view, "traversal-rehearsal", %{"action" => "issue", "revision" => 2})
    assert_reply view, %{accepted: true}
    {:ok, saved} = Store.fetch(r.id)
    assert length(saved.standing["traversal_rehearsal"]["issues"]) == 1
    assert Map.delete(saved.standing, "traversal_rehearsal") == m.standing
    {:ok, retained, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=retained")
    render_hook(retained, "traversal-rehearsal", %{"action" => "issue", "revision" => 3})
    assert_reply retained, %{accepted: false}
  end
end
