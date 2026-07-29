defmodule PublicSituationMachineTurnZeroWeb.SiteStructureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "root presents the landing sections and archive action", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#site-navigation")
    assert has_element?(view, "#landinging-page")
    assert has_element?(view, "#arriving-correspondencing")
    assert has_element?(view, "#featured-correspondencingment")
    assert has_element?(view, "#holding-correspondencingments")
    assert has_element?(view, ~s|a[href="/correspondencingments"]|)
  end

  test "top-level destinations are persistently available", %{conn: conn} do
    for path <- [
          ~p"/",
          ~p"/our-canonical-tuple",
          ~p"/the-appliance",
          ~p"/this-tuple-ship-field",
          ~p"/constitutioning-foundations"
        ] do
      {:ok, view, _html} = live(conn, path)

      assert has_element?(view, "#site-navigation")
      assert has_element?(view, ~s|a[href="/"]|)
      assert has_element?(view, ~s|a[href="/our-canonical-tuple"]|)
      assert has_element?(view, ~s|a[href="/the-appliance"]|)
      assert has_element?(view, ~s|a[href="/this-tuple-ship-field"]|)
      assert has_element?(view, ~s|a[href="/constitutioning-foundations"]|)
      assert has_element?(view, ~s|a[href="/correspondencingments"]|)
    end
  end

  test "both independent Turn Zero copies retain the experience", %{conn: conn} do
    for path <- [~p"/our-canonical-tuple", ~p"/constitutioning-foundations"] do
      {:ok, view, _html} = live(conn, path)

      assert has_element?(view, "#tuple-position-0")
      assert has_element?(view, "#position-0-regard-inward")
      assert has_element?(view, "#unfold-position-1")
    end
  end

  test "tuple ship field is a placeholder", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#tuple-ship-field-page")
    assert has_element?(view, ".field-page__section")
  end

  test "the appliance locality is furnished", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/the-appliance")

    assert has_element?(view, "#appliance-page")
    assert has_element?(view, ".site-navigation__link--appliance")
  end

  test "Correspondencingment archive lists publications", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/correspondencingments")

    assert has_element?(view, "#correspondencingments-page")
    assert has_element?(view, "#correspondencingments[phx-update=stream]")
    assert has_element?(view, "#correspondencingments article")
  end
end
