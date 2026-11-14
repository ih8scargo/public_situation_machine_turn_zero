defmodule PublicSituationMachineTurnZeroWeb.MaterialRibbonLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "same material across views; blocked candidate and Human reference remain non-acquiring",
       %{conn: conn} do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")
    assert has_element?(view, "#paired-motor[data-index='0']")
    assert has_element?(view, "#material-bench[data-index='0']")
    initial = world(view)
    assert length(initial) == 1

    for camera <- ~w(flat backstage gallery through along side) do
      view |> element("#mr-view-#{camera}") |> render_click()
      assert has_element?(view, "#material-bench[data-view='#{camera}']")
      assert world(view) == initial
    end

    view |> element("#mr-toggle-obstacle") |> render_click()
    view |> element("#mr-fold-end") |> render_click()
    assert has_element?(view, "#material-bench[data-q='0.0']")
    assert has_element?(view, "#mr-fold-notice", "BLOCKED")
    assert world(view) == initial

    view
    |> form("#mr-inscription-form", reference: %{reference: "SIX", text: "My SIX reference"})
    |> render_submit()

    assert has_element?(view, "#mr-appointments", "My SIX reference")
    assert world(view) == initial
    view |> element("#mr-toggle-obstacle") |> render_click()
    view |> element("#mr-fold-end") |> render_click()
    assert has_element?(view, "#material-bench[data-q='1.0']")
    refute world(view) == initial
    assert has_element?(view, "#material-bench[data-index='0']")
    assert has_element?(view, "#mr-rail-flat-face-140")
    assert has_element?(view, "#mr-ordinal-link-18")
    view |> element("#motor-ground") |> render_click()
    assert has_element?(view, "[id='mr-trial-footing-1:entrance']")
  end

  defp world(view) do
    view
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#mr-piece-outgoing")
    |> LazyHTML.attribute("data-world")
  end
end
