defmodule PublicSituationMachineTurnZeroWeb.BearingRegistrationLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "bearing selection exposes the two gap witnesses without acquiring extent", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/workshop/string-ribbon")
    view |> element("#ge-experiment-10") |> render_click()

    assert has_element?(view, "#ge-bearing-study[data-face-match=true]")
    assert has_element?(view, "#ge-bearing-face[data-point-match=false]")
    assert has_element?(view, "#ge-bearing-transverse[data-point-match=false]")
    assert has_element?(view, "#ge-bearing-historical[data-point-match=true][data-overlap=true]")
    assert has_element?(view, "#geometry-exploration[data-index='0'][data-coils='0']")
    view |> element("#ge-experiment-9") |> render_click()
    assert has_element?(view, "#ge-shared-face-study")
    refute has_element?(view, "#ge-bearing-study")
  end
end
