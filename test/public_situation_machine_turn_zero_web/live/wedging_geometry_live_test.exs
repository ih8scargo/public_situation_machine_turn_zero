defmodule PublicSituationMachineTurnZeroWeb.WedgingGeometryLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "local selection follows Regarding and inspection is independent of standing", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(view, "#wg-bay-7")
    view |> element("#wg-mouth") |> render_click()
    refute has_element?(view, "#wg-bay-7")
    render_click(view, "select", %{"bay" => "7"})
    assert has_element?(view, "#wg-restand[disabled]")

    view |> element("#wg-bay-0") |> render_click()
    assert has_element?(view, "#wg-transfer-witness")
    refute has_element?(view, "#wg-standing-marker")
    view |> element("#wg-restand") |> render_click()
    assert has_element?(view, "#wg-standing-marker")

    view |> element("#wg-inspect") |> render_click()
    assert has_element?(view, ~s|#wg-inspection[transform="rotate(45)"]|)
    assert has_element?(view, "#wg-bay-0[aria-pressed=true]")

    view |> element("#wg-next") |> render_click()
    refute has_element?(view, "#wg-bay-0")
    assert has_element?(view, "#wg-bay-2")
    assert has_element?(view, "#wg-restand[disabled]")
    assert has_element?(view, "#wg-standing", "Bay 1")
    refute has_element?(view, "#wg-transfer-witness")

    view |> element("#wg-reset") |> render_click()
    refute has_element?(view, "#wg-standing-marker")
    assert has_element?(view, "#wg-bay-0[aria-pressed=false]")
  end

  test "accretion depth changes local geometry and preserves the pillar witnesses", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(view, "#wg-geometry-0 polygon:nth-of-type(3)")
    refute has_element?(view, "#wg-geometry-4 polygon")

    view |> element("#wg-depth-3") |> render_click()
    assert has_element?(view, "#wg-geometry-0 polygon:nth-of-type(7)")
    refute has_element?(view, "#wg-geometry-0 polygon:nth-of-type(8)")

    view |> element("#wg-depth-0") |> render_click()
    refute has_element?(view, "#wg-geometry-0 polygon")
    assert has_element?(view, "#wg-geometry-0 circle")
    assert has_element?(view, "#wg-pillars-y line[data-overlap='2']")
    assert has_element?(view, "#wg-pillars-x line:nth-of-type(4)")
  end
end
