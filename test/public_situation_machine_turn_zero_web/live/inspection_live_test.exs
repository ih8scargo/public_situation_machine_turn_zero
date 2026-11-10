defmodule PublicSituationMachineTurnZeroWeb.InspectionLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop, as: W

  test "five stand appointments, temporary focus, overview, monitor approach and schema-5 restoration",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")

    view |> element("#gw-view-reverse") |> render_click()
    view |> element("#gw-pivot-form") |> render_change(%{"inspection" => %{"yaw" => "31"}})

    for i <- [3, 8, 13, 18, 23] do
      view |> element("#ip-stand-#{i}") |> render_click()
      assert has_element?(view, "#ip-stand-#{i}[aria-pressed=true]")
    end

    view
    |> element("#ip-locality-form")
    |> render_change(%{"locality" => %{"target" => "letter:13"}})

    assert has_element?(view, "#ip-standing", "I23")
    view |> element("#ip-next_letter") |> render_click()
    assert has_element?(view, "#ip-standing", "I23")

    view
    |> element("#ip-locality-form")
    |> render_change(%{"locality" => %{"target" => "plane:lower-surface-z-min"}})

    view |> element("#ip-surface_along") |> render_click()
    assert has_element?(view, "#ip-standing", "surface_along")
    view |> element("#ip-surface_toward") |> render_click()
    view |> element("#ip-monitor") |> render_click()
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json})
    assert {:ok, m, v} = W.import(json)
    assert m["rehearsal"]["collected"] == []
    assert v["inspection_v1"]["parameters"]["stand"] == 23
    assert v["inspection_v1"]["parameters"]["mode"] == "monitor"
    view |> element("#ip-overview") |> render_click()
    refute has_element?(view, "#ip-renderer")
    assert has_element?(view, "#gw-renderer[data-regard=reverse][data-yaw='31.0']")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#ip-renderer")
    view |> element("#ip-from") |> render_click()
    assert has_element?(view, "#ip-standing", "along_forward")
    plain = W.export(m, "front")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => plain}})
    refute has_element?(view, "#ip-controls")
  end
end
