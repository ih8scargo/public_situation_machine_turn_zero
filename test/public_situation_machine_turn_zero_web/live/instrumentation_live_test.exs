defmodule PublicSituationMachineTurnZeroWeb.InstrumentationLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Instrumentation.Store

  defp click(view, selector), do: view |> element(selector) |> render_click()

  test "acceptance drive preserves durable Standing during Regard and resumes only completed seating",
       %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/instrumentation?id=#{record.id}"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#seating-receiver[data-seated=A]")
    click(view, "#tray-toggle")
    assert has_element?(view, "#seating-receiver[data-seated=A]")
    assert has_element?(view, "#flat-rail[data-rail='A,B,C']")
    assert has_element?(view, "#curved-rail[data-rail='A,B,C']")
    click(view, "#loop-B")
    assert has_element?(view, "#aperture-bearing", "square")
    click(view, "#bulb-turn")
    assert has_element?(view, "#aperture-bearing", "facing")
    click(view, "#bulb-return")
    click(view, "#lift-C")
    click(view, "#bulb-turn")

    for selector <- [
          "#bulb-select",
          "#bulb-align",
          "#relation-illuminate",
          "#regard-pivot",
          "#bulb-over"
        ] do
      click(view, selector)
      assert has_element?(view, "#seating-receiver[data-seated=A]")
      {:ok, saved} = Store.fetch(record.id)
      assert saved.standing == record.standing
    end

    assert has_element?(view, "#illuminated-relation[data-source=A][data-target=C]")
    assert has_element?(view, "#bulb-seat:not([disabled])")
    click(view, "#bulb-seat")
    assert has_element?(view, "#seating-receiver[data-seated=C][data-bearing=toward-place]")
    assert has_element?(view, "#exchange-1")
    click(view, "#tray-toggle")
    {:ok, saved} = Store.fetch(record.id)
    assert Map.delete(saved.standing, "seated") == Map.delete(record.standing, "seated")
    {:ok, resumed, _} = live(conn, path)
    refute has_element?(resumed, "#rail-open")
    refute has_element?(resumed, "#inspection-controls")
    assert has_element?(resumed, "#seating-receiver[data-seated=C]")
    click(resumed, "#tray-toggle")
    assert has_element?(resumed, "#loop-A")

    for selector <- ["#lift-A", "#bulb-select", "#bulb-align", "#bulb-over", "#bulb-seat"] do
      click(resumed, selector)
    end

    assert has_element?(resumed, "#seating-receiver[data-seated=A]")
    {:ok, final} = Store.fetch(record.id)
    assert final.standing == record.standing
  end

  test "stale seating is rejected and invalid record cannot operate", %{conn: conn} do
    record = Store.create()
    {:ok, one, _} = live(conn, ~p"/experiments/instrumentation?id=#{record.id}")
    {:ok, two, _} = live(conn, ~p"/experiments/instrumentation?id=#{record.id}")

    for view <- [one, two],
        selector <- ["#tray-toggle", "#lift-C", "#bulb-select", "#bulb-align", "#bulb-over"] do
      click(view, selector)
    end

    click(one, "#bulb-seat")
    click(two, "#bulb-seat")
    assert has_element?(two, "#instrument-status", "Reload")
    assert has_element?(two, "#seating-receiver[data-seated=A]")
    {:ok, invalid, _} = live(conn, ~p"/experiments/instrumentation?id=invalid")
    assert has_element?(invalid, "#tray-toggle[disabled]")
  end
end
