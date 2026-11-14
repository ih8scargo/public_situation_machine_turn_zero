defmodule PublicSituationMachineTurnZeroWeb.PairedMotorLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "two Footings and return remain rehearsal on the existing workshop", %{conn: conn} do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")
    assert has_element?(view, "#paired-motor[data-index='0']")

    for _ <- 1..2 do
      view |> element("#motor-ground") |> render_click()
      view |> element("#motor-pending") |> render_click()
      view |> element("#motor-end") |> render_click()
      view |> element("#motor-return") |> render_click()

      if not has_element?(view, "#trial-footing-2"),
        do: view |> element("#motor-next") |> render_click()
    end

    view |> element("#motor-earlier") |> render_click()
    assert has_element?(view, "#trial-footing-1")
    assert has_element?(view, "#trial-footing-2")
    assert has_element?(view, "#motor-view-side")
    assert has_element?(view, "#motor-view-within")
    assert has_element?(view, "#motor-failures")
    assert has_element?(view, "#paired-motor[data-index='0']")
    assert has_element?(view, "#string-ribbon-workshop[data-acquired='false']")
  end
end
