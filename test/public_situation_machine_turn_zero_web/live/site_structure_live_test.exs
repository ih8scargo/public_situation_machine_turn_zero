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
    localities = [
      {~p"/", "/"},
      {~p"/our-canonical-tuple", "/our-canonical-tuple"},
      {~p"/the-appliance", "/the-appliance"},
      {~p"/this-tuple-ship-field", "/this-tuple-ship-field"},
      {~p"/constitutioning-foundations", "/constitutioning-foundations"},
      {~p"/correspondencingments", "/correspondencingments"}
    ]

    for {path, active_href} <- localities do
      {:ok, view, _html} = live(conn, path)

      assert has_element?(view, "#site-navigation")
      assert has_element?(view, ~s|#site-navigation a.is-active[href="#{active_href}"]|)

      for {_locality_path, inactive_href} <- localities, inactive_href != active_href do
        refute has_element?(view, ~s|#site-navigation a.is-active[href="#{inactive_href}"]|)
      end

      assert has_element?(view, ~s|a[href="/"]|)
      assert has_element?(view, ~s|a[href="/our-canonical-tuple"]|)
      assert has_element?(view, ~s|a[href="/the-appliance"]|)
      assert has_element?(view, ~s|a[href="/this-tuple-ship-field"]|)
      assert has_element?(view, ~s|a[href="/constitutioning-foundations"]|)
      assert has_element?(view, ~s|a[href="/correspondencingments"]|)
    end
  end

  test "Constitutioning Foundations retains the Turn Zero experience", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/constitutioning-foundations")

    assert has_element?(view, "#tuple-position-0")
    assert has_element?(view, "#position-0-regard-inward")
    assert has_element?(view, "#unfold-position-1")
    assert has_element?(view, "#orientationing-panel-title")

    html = render(view)
    {orientationing_index, _} = :binary.match(html, "orientationing-panel-title")
    {identification_index, _} = :binary.match(html, "psm-identification")
    assert orientationing_index < identification_index
  end

  test "Our Canonical Tuple is a two-column constitutional reading journey", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    assert has_element?(view, "#canonical-tuple-page")
    assert has_element?(view, "#canonical-accompaniment")
    assert has_element?(view, "#canonical-narrative")
    assert has_element?(view, "#appliance-ceremony")
    assert has_element?(view, "#canonical-tuple-table")
    assert has_element?(view, "#canonical-position-0")
    assert has_element?(view, "#unfold-position-1", "UNFOLD POSITION 1")
    assert has_element?(view, ".appliance-ceremony__sealing", "THE SEALINGING OF THE")
    assert has_element?(view, ".canonical-table-caption", "one complete Stewardly Advancementing")

    view |> element("#unfold-position-1") |> render_click()
    assert has_element?(view, "#canonical-position-1")
    assert has_element?(view, "#unfold-position-2", "UNFOLD POSITION 2")

    view |> element("#unfold-position-2") |> render_click()
    assert has_element?(view, "#canonical-position-2")
    assert has_element?(view, "#unfold-position-3", "UNFOLD POSITION 3")

    view |> element("#unfold-position-3") |> render_click()
    assert has_element?(view, "#canonical-position-3")
    assert has_element?(view, "#canonical-caterpillar-tunnel")

    for fold <- 1..6 do
      fold_selector = ".canonical-caterpillar__fold:nth-child(#{fold})"
      assert has_element?(view, fold_selector)
      assert has_element?(view, "#{fold_selector} li:nth-child(1)", "Through")
      assert has_element?(view, "#{fold_selector} li:nth-child(2)", "Across")
      assert has_element?(view, "#{fold_selector} li:nth-child(3)", "Projectioning Crossing")
      assert has_element?(view, "#{fold_selector} li:nth-child(4)", "Lean")
      assert has_element?(view, "#{fold_selector} li:nth-child(5)", "This Moment of Purchase")
      assert has_element?(view, "#{fold_selector} li:nth-child(6)", "Getting Stitched")
    end

    view |> element("#unfold-position-4") |> render_click()
    assert has_element?(view, "#canonical-position-4")
    view |> element("#unfold-position-5") |> render_click()
    assert has_element?(view, "#canonical-position-5")
    view |> element("#unfold-position-6") |> render_click()
    assert has_element?(view, "#canonical-position-6")
    refute has_element?(view, "#unfold-position-7")
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
    refute has_element?(view, "#canonical-tuple-table")
  end

  test "Correspondencingment archive lists publications", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/correspondencingments")

    assert has_element?(view, "#correspondencingments-page")
    assert has_element?(view, "#correspondencingments[phx-update=stream]")
    assert has_element?(view, "#correspondencingments article")
  end
end
