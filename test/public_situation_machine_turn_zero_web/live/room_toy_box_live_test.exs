defmodule PublicSituationMachineTurnZeroWeb.RoomToyBoxLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "primary Toy Box retains protected standing and historical witnesses through all four movements",
       %{conn: conn} do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)
    assert has_element?(v, "#room-toy-box") and has_element?(v, "#room-historical #co-building")

    for movement <- ~w(room wedging pinning stands) do
      v |> element("#rtb-movement-" <> movement) |> render_click()
    end

    for n <- 1..3, do: v |> element("#rtb-pin-#{n}") |> render_click()
    assert has_element?(v, "#rtb-pins", "[1, 2, 3]")

    v
    |> element("#rtb-settings")
    |> render_change(%{"_target" => ["toy", "travel"], "toy" => %{"travel" => "1"}})

    v |> element("#rtb-projection") |> render_click()
    v |> element("#rtb-view-five") |> render_click()
    assert has_element?(v, "#room-toy-box[data-acquired-delta='0']")
    assert has_element?(v, "#rtb-clearance", "false")
    assert has_element?(v, "#rtb-inspect-cb-square-axle")

    for id <-
          ~w(tuple-re-step-wall tuple-gimbalizing-piton tuple-purchase-surface-five toybox-regarding-five tuple-six-return-reference) do
      assert has_element?(v, "#rtb-inheritance-" <> id)
    end

    assert has_element?(v, "#rtb-tuple-material-status", "Push-off alone is not RE-STEP")
    {:ok, after_read} = Store.fetch(record.id)
    assert after_read == before
  end

  test "a stale or attempted constitutional command cannot turn a hold into acquisition", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)
    v |> element("#rtb-pin-2") |> render_click()
    assert has_element?(v, "#rtb-notice")
    v |> element("#rtb-pin-1") |> render_click()
    render_click(v, "room-toy-action", %{"action" => "pin", "choice" => "3", "revision" => "0"})
    render_click(v, "room-toy-action", %{"action" => "re_step", "revision" => "1"})
    assert has_element?(v, "#rtb-pins", "[1]")
    {:ok, after_read} = Store.fetch(record.id)
    assert after_read == before
  end
end
