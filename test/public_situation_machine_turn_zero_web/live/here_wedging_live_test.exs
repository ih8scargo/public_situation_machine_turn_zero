defmodule PublicSituationMachineTurnZeroWeb.HereWedgingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "integrated wedge/source study retains identity and reports blocked return and fit", %{
    conn: conn
  } do
    {:ok, v, _} = live(conn, "/workshop/string-ribbon")
    initial = world(v)
    v |> element("#hw-side-right") |> render_click()
    assert world(v) == initial
    v |> element("#hw-trial-returns") |> render_click()
    assert has_element?(v, "#hw-status", "BLOCKED")
    assert has_element?(v, "#hw-snail-fit", "false")
    v |> element("#hw-trial-simple") |> render_click()
    assert world(v) == initial
    assert has_element?(v, "#geometry-exploration[data-index='0']")
  end

  defp world(v),
    do:
      v
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#hw-snail")
      |> LazyHTML.attribute("data-world")
end
