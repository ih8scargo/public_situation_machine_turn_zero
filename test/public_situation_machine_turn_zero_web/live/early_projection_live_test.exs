defmodule PublicSituationMachineTurnZeroWeb.EarlyProjectionLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "early encounter reserves six possibilities and stops consequential continuation at appointment",
       %{conn: conn} do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 12, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 12, "pitch" => 0, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    {:ok, r} = Store.save(Store.create(), m.standing)
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=early")
    assert has_element?(v, "#early-appliance-tools")
    assert has_element?(v, "#resolution-target")
    render_hook(v, "second-puff", %{})
    assert_reply v, %{accepted: false}
    {:ok, unchanged} = Store.fetch(r.id)
    assert unchanged.standing == m.standing
    {:ok, retained, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=retained")
    refute has_element?(retained, "#early-appliance-tools")
    render_hook(retained, "second-puff", %{})
    assert_reply retained, %{accepted: true}
  end
end
