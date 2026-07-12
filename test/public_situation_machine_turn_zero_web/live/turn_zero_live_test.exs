defmodule PublicSituationMachineTurnZeroWeb.TurnZeroLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "changes Position Zero between outward and inward regard", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#position-0-instrument-chamber")
    assert has_element?(view, "#position-0-regard-inward")
    refute has_element?(view, "#position-0-recital")

    view
    |> element("#position-0-regard-inward")
    |> render_click()

    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-0-regard-outward")

    view
    |> element("#position-0-regard-outward")
    |> render_click()

    assert has_element?(view, "#position-0-regard-inward")
    refute has_element?(view, "#position-0-recital")
  end

  test "unfolds Position One while preserving Position Zero", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#tuple-position-0")
    assert has_element?(view, "#unfold-position-1")
    refute has_element?(view, "#tuple-position-1")

    view
    |> element("#unfold-position-1")
    |> render_click()

    assert has_element?(view, "#tuple-position-0")
    assert has_element?(view, "#tuple-position-1")
    refute has_element?(view, "#unfold-position-1")

    assert render(view) =~ "Position One Now Stands Encounterable"
  end
end
