defmodule PublicSituationMachineTurnZeroWeb.TurnZeroLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "changes Position Zero between outward and inward regard", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

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
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

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
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    refute has_element?(view, "#unfold-position-2")
    refute has_element?(view, "#tuple-position-2")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()

    assert has_element?(view, "#tuple-position-0")
    assert has_element?(view, "#tuple-position-1")
    assert has_element?(view, "#tuple-position-2")
    refute has_element?(view, "#unfold-position-2")
    assert has_element?(view, "#unfold-position-3")
  end

  test "maintains independent persistent regard for all furnished positions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

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

  test "unfolds the Knotting Rail tunnel and Position Three from Position Two", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()

    assert has_element?(view, "#unfold-position-3")
    refute has_element?(view, "#turn-zero-knotting-rail")
    refute has_element?(view, "#tuple-position-3")

    view |> element("#unfold-position-3") |> render_click()

    assert has_element?(view, "#turn-zero-knotting-rail")
    assert has_element?(view, "#tuple-position-3")
    assert has_element?(view, "#position-3-instrument-chamber")
    assert has_element?(view, "#position-3-regard-inward")
    refute has_element?(view, "#unfold-position-3")
  end

  test "maintains independent Position Three regard", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()

    view |> element("#position-2-regard-inward") |> render_click()
    view |> element("#position-3-regard-inward") |> render_click()

    assert has_element?(view, "#position-2-recital")
    assert has_element?(view, "#position-3-recital")

    view |> element("#position-3-regard-outward") |> render_click()

    assert has_element?(view, "#position-2-recital")
    refute has_element?(view, "#position-3-recital")
    assert has_element?(view, "#position-3-regard-inward")
  end

  test "unfolds Position Four only after Position Three", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    refute has_element?(view, "#unfold-position-4")
    refute has_element?(view, "#tuple-position-4")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()

    refute has_element?(view, "#unfold-position-4")

    view |> element("#unfold-position-3") |> render_click()

    assert has_element?(view, "#unfold-position-4")
    refute has_element?(view, "#tuple-position-4")

    view |> element("#unfold-position-4") |> render_click()

    assert has_element?(view, "#tuple-position-3")
    assert has_element?(view, "#tuple-position-4")
    assert has_element?(view, "#position-4-instrument-chamber")
    assert has_element?(view, "#position-4-regard-inward")
    refute has_element?(view, "#unfold-position-4")
  end

  test "maintains independent Position Four regard", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()
    view |> element("#unfold-position-4") |> render_click()

    view |> element("#position-0-regard-inward") |> render_click()
    view |> element("#position-3-regard-inward") |> render_click()
    view |> element("#position-4-regard-inward") |> render_click()

    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-3-recital")
    assert has_element?(view, "#position-4-recital")

    view |> element("#position-4-regard-outward") |> render_click()

    assert has_element?(view, "#position-0-recital")
    assert has_element?(view, "#position-3-recital")
    refute has_element?(view, "#position-4-recital")
    assert has_element?(view, "#position-4-regard-inward")
  end

  test "shows the Position Five control only after Position Four unfolds", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()

    refute has_element?(view, "#unfold-position-5")

    view |> element("#unfold-position-4") |> render_click()

    assert has_element?(view, "#unfold-position-5")
    refute has_element?(view, "#tuple-position-5")
  end

  test "unfolds Positions Five and Six in sequence", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()
    view |> element("#unfold-position-4") |> render_click()

    refute has_element?(view, "#unfold-position-6")
    view |> element("#unfold-position-5") |> render_click()

    assert has_element?(view, "#tuple-position-5")
    assert has_element?(view, "#position-5-instrument-chamber")
    assert has_element?(view, "#unfold-position-6")
    refute has_element?(view, "#tuple-position-6")

    view |> element("#unfold-position-6") |> render_click()

    assert has_element?(view, "#tuple-position-6")
    assert has_element?(view, "#position-6-instrument-chamber")
    refute has_element?(view, "#unfold-position-6")
    refute has_element?(view, "#unfold-position-7")
  end

  test "maintains independent regard for Positions Five and Six", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()
    view |> element("#unfold-position-4") |> render_click()
    view |> element("#unfold-position-5") |> render_click()
    view |> element("#unfold-position-6") |> render_click()

    view |> element("#position-4-regard-inward") |> render_click()
    view |> element("#position-5-regard-inward") |> render_click()
    view |> element("#position-6-regard-inward") |> render_click()

    assert has_element?(view, "#position-4-recital")
    assert has_element?(view, "#position-5-recital")
    assert has_element?(view, "#position-6-recital")

    view |> element("#position-5-regard-outward") |> render_click()

    assert has_element?(view, "#position-4-recital")
    refute has_element?(view, "#position-5-recital")
    assert has_element?(view, "#position-6-recital")
  end

  test "renders the supplied Position Four through Six constitutional material", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    view |> element("#unfold-position-1") |> render_click()
    view |> element("#unfold-position-2") |> render_click()
    view |> element("#unfold-position-3") |> render_click()
    view |> element("#unfold-position-4") |> render_click()
    view |> element("#unfold-position-5") |> render_click()
    view |> element("#unfold-position-6") |> render_click()

    assert has_element?(view, "#position-4-oag-title", "Regarded in Distinguishingment")
    assert has_element?(view, "#position-5-harbor-title", "THIS RE-STEP")
    assert has_element?(view, "#position-6-harbor-title", "THIS RE-STEP-MENT MOMENT")
    assert has_element?(view, "#position-6-readiness")
  end
end
