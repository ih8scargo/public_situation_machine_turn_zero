defmodule PublicSituationMachineTurnZeroWeb.CrossingRehearsalLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "bounded geometry persists reception, inherits the instrument in reference modes, and rejects later operations",
       %{conn: conn} do
    r = Store.create()
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}")
    assert has_element?(v, "#crossing-wheel")
    refute has_element?(v, "#inaugural-third-puff")

    for {action, value, revision} <- [{"pull", 1, 0}, {"feed", 1, 1}, {"receive", 1, 2}] do
      render_hook(v, "crossing-rehearsal", %{
        "action" => action,
        "value" => value,
        "revision" => revision
      })

      assert_reply v, %{accepted: true}
    end

    {:ok, saved} = Store.fetch(r.id)
    stick = saved.standing["opening_geometry"]["stick"]
    assert stick["via"]["participant"] == "doll"
    assert stick["nozzle"]["kind"] == "mounting-able CUBICAL"

    for event <- ["puff", "inaugural", "traversal-rehearsal", "step", "re-step", "re-stomp"] do
      render_hook(v, event, %{})
      assert_reply v, %{accepted: false}
    end

    {:ok, after_read} = Store.fetch(r.id)
    assert saved == after_read
    {:ok, _, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}&mode=companion")
    {:ok, inherited} = Store.fetch(r.id)
    assert inherited.standing["opening_geometry"]["stick"] == stick
    assert A.restore(inherited.standing).standing == saved.standing
  end
end
