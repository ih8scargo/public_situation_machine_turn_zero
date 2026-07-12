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

    assert has_element?(view, "#position-1-instrument-chamber")
    assert has_element?(view, "#position-1-regard-inward")
    assert has_element?(view, "#unfold-position-2")
    refute has_element?(view, "#tuple-position-2")
  end

  test "unfolds Position Two only from Position One", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#unfold-position-2")
    refute has_element?(view, "#tuple-position-2")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()

    assert has_element?(view, "#tuple-position-0")
    assert has_element?(view, "#tuple-position-1")
    assert has_element?(view, "#tuple-position-2")
    refute has_element?(view, "#unfold-position-2")
    refute has_element?(view, "#unfold-position-3")
  end

  test "maintains independent persistent regard for all furnished positions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()

    view |> element("#position-0-regard-inward") |> render_click()
    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-1-regard-inward")
    assert has_element?(view, "#position-2-regard-inward")

    view |> element("#position-1-regard-inward") |> render_click()
    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-1-recital")
    refute has_element?(view, "#position-2-recital")

    view |> element("#position-2-regard-inward") |> render_click()
    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-1-recital")
    assert has_element?(view, "#position-2-recital")

    view |> element("#position-1-regard-outward") |> render_click()
    assert has_element?(view, "#position-0-recital")
    refute has_element?(view, "#position-1-recital")
    assert has_element?(view, "#position-2-recital")
  end
end
