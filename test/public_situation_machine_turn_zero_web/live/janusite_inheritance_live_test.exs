defmodule PublicSituationMachineTurnZeroWeb.JanusiteInheritanceLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "inspection modes and TWO fixture preserve source and do not acquire", %{conn: conn} do
    {:ok, v, _} = live(conn, "/workshop/string-ribbon")
    initial = world(v)

    for mode <- ~w(A B C) do
      v |> element("#ji-mode-#{mode}") |> render_click()
      assert has_element?(v, "#janusite-inheritance[data-mode='#{mode}']")
    end

    for view <- ~w(flat longhouse tunneling) do
      v |> element("#ji-view-#{view}") |> render_click()
      assert has_element?(v, "#janusite-inheritance[data-view='#{view}']")
      assert world(v) == initial
    end

    v |> element("#ji-footing-two") |> render_click()
    assert has_element?(v, "#ji-origin", "nil")
    v |> element("#ji-toggle-fixture") |> render_click()
    assert has_element?(v, "#ji-origin", "hypothetical_landing_fixture")
    assert has_element?(v, "#geometry-exploration[data-index='0']")
    assert has_element?(v, "#here-wedging-study")
  end

  defp world(v),
    do:
      v
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#ji-source-world")
      |> LazyHTML.attribute("data-world")
end
