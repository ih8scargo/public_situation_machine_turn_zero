defmodule PublicSituationMachineTurnZeroWeb.RoomFromHereLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "Human can inspect, appoint and rehearse pivots without changing acquired standing", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)
    assert has_element?(v, "#room-toy-box[data-contract='room-from-here-2026-11-17.v12']")

    for id <- ~w(source bearing return standing),
        do: assert(has_element?(v, "#rfh-corner-" <> id))

    v |> element("#rtb-select-O2") |> render_click()
    v |> element("#rtb-appoint-stage") |> render_click()
    assert has_element?(v, "#rfh-authoring-state", "STAGING FOR STANDING")
    v |> element("#rtb-pivot-seat") |> render_click()
    v |> element("#rtb-steer") |> render_click()
    assert has_element?(v, "#room-toy-box[data-active-pivot='seat']")
    v |> element("#rtb-pivot-table") |> render_click()
    assert has_element?(v, "#room-toy-box[data-active-pivot='seat']")
    assert has_element?(v, "#rtb-notice", "Lock the active pivot")
    v |> element("#rtb-pivot-locked") |> render_click()
    v |> element("#rtb-pivot-table") |> render_click()
    v |> element("#rtb-steer") |> render_click()
    assert has_element?(v, "#room-toy-box[data-active-pivot='table']")

    v
    |> element("#rfh-seam-settings")
    |> render_change(%{"_target" => ["toy", "seam"], "toy" => %{"seam" => "42"}})

    for view <- ~w(fore aft), do: v |> element("#rtb-view-" <> view) |> render_click()
    assert has_element?(v, "#rfh-seam-status[data-source-id='room-ribbon:1/seam-42']")
    assert has_element?(v, "#rfh-seam-faces polygon")
    for i <- 1..3, do: v |> element("#rtb-pin-#{i}") |> render_click()
    assert has_element?(v, "#rtb-pins", "[1, 2, 3]")
    assert has_element?(v, "#room-toy-box[data-acquired-delta='0']")
    assert has_element?(v, "#room-historical #co-building")
    {:ok, after_read} = Store.fetch(record.id)
    assert after_read == before
  end
end
