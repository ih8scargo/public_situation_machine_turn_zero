defmodule PublicSituationMachineTurnZeroWeb.ArchitectureCraftLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  defp click(view, selector), do: view |> element(selector) |> render_click()

  defp saved(id) do
    {:ok, record} = Store.fetch(id)
    record.standing
  end

  test "body-first TC/Chair/Buckle drive and later from-within Tunnel keep the verified constitutional boundary",
       %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/architecture/engineering?id=#{record.id}"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#co-bobbing[data-identity=co-bobbing]")
    assert has_element?(view, "#co-bobbing [data-point-index='3']")
    refute has_element?(view, "#co-bobbing [data-point-index='4']")
    refute has_element?(view, "#craft-controls")
    refute has_element?(view, "#regard-approach")
    view |> form("#wheel-input-form", wheel: %{angle: "47"}) |> render_change()
    assert has_element?(view, "#regarding-wheel[data-angle='47.0']")
    assert saved(record.id) == record.standing
    click(view, "#composement-toggle")
    assert has_element?(view, "#architecture-projection[data-craft=true]")
    assert has_element?(view, "#architecture-materials[inert]")
    assert has_element?(view, "#flat-toggle[disabled]")
    click(view, "#craft-draw-pointer")
    click(view, "#craft-point-calibration")
    click(view, "#craft-calibrate")
    calibrated = saved(record.id)
    click(view, "#craft-box")
    click(view, "#craft-point-offer")
    assert has_element?(view, "#craft-projection[data-articulation=offer]")
    click(view, "#craft-grasp")

    assert has_element?(
             view,
             "#craft-projection[data-held=projected-tc][data-articulation=grasp]"
           )

    click(view, "#craft-lift")
    click(view, "#craft-turn")
    render_hook(view, "craft-pose", %{x: 620, y: 370, turn: 75})
    click(view, "#craft-toward")
    click(view, "#craft-align")
    assert saved(record.id) == calibrated
    assert has_element?(view, "#craft-projection[data-articulation=square]")
    click(view, "#craft-seat")
    seated = saved(record.id)
    assert seated["relations"]["tc-positioned"]["object"] == "little-square-chair"
    refute Map.has_key?(seated["relations"], "tc-appointed")
    click(view, "#craft-point-offer")
    click(view, "#craft-grasp")
    assert has_element?(view, "#craft-projection[data-held=square-buckle]")
    click(view, "#craft-turn")
    click(view, "#craft-toward")
    click(view, "#craft-align")
    click(view, "#craft-wrap")
    assert saved(record.id) == seated
    click(view, "#craft-buckle")
    assert has_element?(view, "#first-step:not([disabled])")
    appointed = saved(record.id)
    assert appointed["from"] == "ZEROETH"
    assert appointed["passages"] == []
    click(view, "#composement-toggle")
    refute has_element?(view, "#craft-controls")
    click(view, "#first-step")
    assert has_element?(view, "#tunnel-geometry[data-regard=from-within]")
    assert has_element?(view, "#rail-left")
    assert has_element?(view, "#rail-right")
    refute has_element?(view, "#composement-toggle")
    stepped = saved(record.id)
    click(view, "#nav-forward")
    assert has_element?(view, "#craft-projection[data-nav='1']")
    click(view, "#approach-tunnel-notice")

    assert has_element?(
             view,
             "#architecture-materials [data-material=tunnel-notice][data-approached=true]"
           )

    click(view, "#material-down")
    click(view, "#material-back")
    refute has_element?(view, "#material-nav")
    view |> form("#wheel-input-form", wheel: %{angle: "180"}) |> render_change()
    assert has_element?(view, "#continuing-from[data-tunnel=true] #inherited-tc-appointed")
    assert saved(record.id) == stepped
    # A forged craft request in the Tunnel cannot turn reading into labor.
    render_hook(view, "craft", %{op: "grasp"})
    assert saved(record.id) == stepped
    click(view, "#projection-toggle")
    refute has_element?(view, "#architecture-projection")
    click(view, "#projection-toggle")
    assert has_element?(view, "#craft-projection[data-held=''][data-nav='0']")
    {:ok, resumed, _} = live(conn, path)
    assert has_element?(resumed, "#architecture-passage", "1")
    assert saved(record.id) == stepped
  end

  test "a prospective artifact may be handled and released without satisfying missing dependencies",
       %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture/engineering?id=#{record.id}")

    for selector <- [
          "#composement-toggle",
          "#craft-draw-pointer",
          "#craft-box",
          "#craft-next-piece",
          "#craft-point-offer",
          "#craft-grasp",
          "#craft-turn",
          "#craft-release"
        ] do
      click(view, selector)
    end

    assert saved(record.id) == record.standing
    render_hook(view, "point-artifact", %{id: "this-place"})
    render_hook(view, "craft", %{op: "grasp"})
    assert has_element?(view, "#craft-projection[data-held='']")
    assert saved(record.id) == record.standing
  end
end
