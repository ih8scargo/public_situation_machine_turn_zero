defmodule PublicSituationMachineTurnZeroWeb.RoomLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  defp snapshot(record) do
    {:ok, saved} = Store.fetch(record.id)
    saved.standing
  end

  test "public drive is one appointment and a sparse room; recovered work stays on a separate surface",
       %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}")
    assert has_element?(view, "#pointing-appointment")
    assert has_element?(view, "#quiet-bobbing")
    assert has_element?(view, "#quiet-bobbing [data-part=points] circle:nth-child(4)")
    refute has_element?(view, "#quiet-appliance form")
    refute has_element?(view, "#material-editor")
    refute has_element?(view, "#development-instruments")
    refute has_element?(view, "#first-step")
    refute has_element?(view, "#craft-controls")
    refute has_element?(view, "#quiet-appliance", "SQUARE CHAIR")
    refute has_element?(view, "#quiet-appliance", "BUCKLE")

    assert has_element?(
             view,
             "#engineering-link[href='/experiments/architecture/engineering?id=#{record.id}']"
           )

    render_hook(view, "wheel", %{angle: 40.5})
    assert snapshot(record) == record.standing
    view |> element("#pointing-appointment") |> render_click()
    assert has_element?(view, "#quiet-stage[data-entered=true]")
    refute has_element?(view, "#quiet-wheel")

    for params <- [%{op: "draw"}, %{op: "turn", angle: 65}, %{op: "release"}],
        do: render_hook(view, "pointer", params)

    assert snapshot(record) == record.standing
    assert has_element?(view, "#appoint-pointer")
    view |> element("#appoint-pointer") |> render_click()
    appointed = snapshot(record)
    assert Map.has_key?(appointed["relations"], "pointing-calibrated")
    refute Map.has_key?(appointed["relations"], "tc-positioned")
    assert appointed["passages"] == []
    assert appointed["from"] == "ZEROETH"
    assert has_element?(view, "#pointer-appointed")
    refute has_element?(view, "#first-step")
    view |> element("#quiet-projection-toggle") |> render_click()
    refute has_element?(view, "#quiet-stage")
    assert has_element?(view, "#quiet-cabinet")
    view |> element("#quiet-projection-toggle") |> render_click()
    assert has_element?(view, "#quiet-stage[data-entered=false]")
    refute has_element?(view, "#appoint-pointer")
    assert snapshot(record) == appointed
    {:ok, engineering, _} = live(conn, ~p"/experiments/architecture/engineering?id=#{record.id}")
    assert has_element?(engineering, "#material-editor")
    assert has_element?(engineering, "#toy-box-ledger")
  end

  test "continuous navigation and sheet Regarding preserve first-passage Standing", %{conn: conn} do
    record = Store.create_tunnel_fixture()
    path = ~p"/experiments/architecture/tunnel?id=#{record.id}"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#quiet-cabinet", "FIRST-PASSAGE TEST STANDING")
    refute has_element?(view, "#quiet-wheel")
    refute has_element?(view, "#quiet-appliance form")

    for position <- [0.2, 0.8, 1.7, 2.1, 1.6, 2.4] do
      render_hook(view, "nav-motion", %{position: position, across: -0.35})
      assert snapshot(record) == record.standing
    end

    for params <- [
          %{op: "catch", id: "tunnel-notice", corner: 0},
          %{op: "draw", amount: 1},
          %{op: "catch", id: "tunnel-notice", corner: 2},
          %{op: "square"},
          %{op: "relinquish"}
        ] do
      render_hook(view, "sheet", params)
      assert snapshot(record) == record.standing
    end

    # This route offers no craft operation that could repair inherited standing.
    render_hook(view, "appoint-pointer", %{})
    assert snapshot(record) == record.standing
    view |> element("#quiet-projection-toggle") |> render_click()
    render_hook(view, "nav-motion", %{position: 6, across: 0.5})
    assert snapshot(record) == record.standing
    {:ok, resumed, _} = live(conn, path)
    assert has_element?(resumed, "#quiet-bobbing")
    assert snapshot(record)["passages"] == record.standing["passages"]
    assert length(record.standing["passages"]) == 1
  end
end
