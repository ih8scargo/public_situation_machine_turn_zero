defmodule PublicSituationMachineTurnZeroWeb.InnerApertureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "Grand and Inner Aperture are distinct; the public corner/Square and grid scaffolds are absent",
       %{conn: conn} do
    record = Store.create_tunnel_fixture()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture/tunnel?id=#{record.id}")
    assert has_element?(view, "#quiet-stage[data-aperture=grand]")
    assert has_element?(view, "#quiet-stage #inner-aperture[data-aperture=inner]")
    assert has_element?(view, "#inner-aperture [data-inner-grip]")
    assert has_element?(view, "#inner-aperture [data-inner-release]")
    refute has_element?(view, "#quiet-stage [data-corner]")
    refute has_element?(view, "#quiet-stage [data-sheet-action=square]")
    refute has_element?(view, "#flat-toggle")
    refute has_element?(view, "#quiet-appliance form")
    assert has_element?(view, "#quiet-stage [data-part=bearing-regard]")
  end

  test "Groundworking starts without a pre-staged Pointing-able tip or public future inventory",
       %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}")
    refute has_element?(view, "[data-part=pointer-tip]")
    refute has_element?(view, "#craft-controls")
    refute has_element?(view, "#toy-box-ledger")
    refute has_element?(view, "#quiet-appliance form")
    assert has_element?(view, "#pointing-appointment")
  end

  test "resolution, all four bearings, calibration, reversal and relinquishing persist no consequence",
       %{conn: conn} do
    record = Store.create_tunnel_fixture()
    path = ~p"/experiments/architecture/tunnel?id=#{record.id}"
    {:ok, view, _} = live(conn, path)

    for position <- [1.2, 2.7, 1.8] do
      render_hook(view, "nav-motion", %{position: position, across: -0.2})
      render_hook(view, "sheet", %{op: "resolve", id: "tunnel-notice"})
      assert has_element?(view, "#quiet-stage[data-inner-material=tunnel-notice]")

      for direction <- ["xt", "yt", "down", "up", "yt"] do
        render_hook(view, "sheet", %{op: "regard", direction: direction})

        assert has_element?(
                 view,
                 "#quiet-stage[data-regard=#{direction}][data-from=ONE-APPROACH]"
               )
      end

      render_hook(view, "sheet", %{op: "calibrate", scale: 99})
      render_hook(view, "sheet", %{op: "relinquish"})
      assert has_element?(view, "#quiet-stage[data-inner-material='']")
      {:ok, saved} = Store.fetch(record.id)
      assert saved.standing == record.standing
    end

    view |> element("#quiet-projection-toggle") |> render_click()
    view |> element("#quiet-projection-toggle") |> render_click()
    assert has_element?(view, "#quiet-stage[data-regard=center][data-inner-material='']")
    {:ok, reloaded, _} = live(conn, path)
    assert has_element?(reloaded, "#quiet-stage[data-regard=center]")
    {:ok, saved} = Store.fetch(record.id)
    assert saved.standing == record.standing
  end
end
