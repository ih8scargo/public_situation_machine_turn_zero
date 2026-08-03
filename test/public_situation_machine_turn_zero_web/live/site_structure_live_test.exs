defmodule PublicSituationMachineTurnZeroWeb.SiteStructureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "root presents the landing sections and archive action", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#site-navigation")
    assert has_element?(view, "#landinging-page")
    assert has_element?(view, "#arriving-correspondencing")
    assert has_element?(view, "#featured-correspondencingment")
    assert has_element?(view, "#featured-correspondencingment", "Correspondencingment No. 2")
    assert has_element?(view, ~s|#featured-correspondencingment iframe[src*="dqRX1nIuwDw"]|)
    assert has_element?(view, "#holding-correspondencingments")
    assert has_element?(view, "#holding-correspondencingments", "Correspondencingment No. 1")

    assert has_element?(
             view,
             ~s|#holding-correspondencingments a[href="/correspondencingments#correspondencingment-1"]|
           )
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
      assert has_element?(view, ".psm-masthead")
      assert has_element?(view, ".psm-masthead__lower", "General Purpose Situationing Appliance")
      assert has_element?(view, ".psm-oag", "Standinging in Regard")

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

  test "OUR CANONICAL TUPLE is a single-column constitutional reading journey", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/our-canonical-tuple")

    assert has_element?(view, "#canonical-tuple-page")
    refute has_element?(view, "#canonical-accompaniment")
    assert has_element?(view, "#canonical-tuple-threshold")
    assert has_element?(view, "#canonical-simple-discovery")
    assert has_element?(view, "#canonical-narrative")
    assert has_element?(view, "#appliance-ceremony")
    assert has_element?(view, "#canonical-tuple-table")

    assert has_element?(
             view,
             "#canonical-tuple-table thead th:nth-child(1)",
             "Constitutional Geometry Furnished"
           )

    assert has_element?(
             view,
             "#canonical-tuple-table thead th:nth-child(5)",
             "Unfolding Toward Coherence"
           )

    refute has_element?(
             view,
             "#canonical-tuple-table thead th",
             "One Soundinging of Stewardly Regard"
           )

    assert has_element?(view, "#embodying-canonical-tuple")

    assert has_element?(
             view,
             "#embodying-canonical-tuple-table thead th:nth-child(2)",
             "Embodying Inhabitationing"
           )

    assert has_element?(
             view,
             "#embodying-canonical-tuple-table thead th:nth-child(4)",
             "One Soundinging of Stewardly Regard"
           )

    html = render(view)
    {embodying_index, _} = :binary.match(html, "embodying-canonical-tuple")
    {position_zero_index, _} = :binary.match(html, "canonical-position-0")
    assert embodying_index < position_zero_index

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

    assert has_element?(
             view,
             ~s|#canonical-caterpillar-tunnel img[src="/images/tuple/Regarding_THE_RE-STEPPING-ROOM.png"]|
           )

    view |> element("#unfold-position-4") |> render_click()
    assert has_element?(view, "#canonical-position-4")
    view |> element("#unfold-position-5") |> render_click()
    assert has_element?(view, "#canonical-position-5")
    view |> element("#unfold-position-6") |> render_click()
    assert has_element?(view, "#canonical-position-6")
    refute has_element?(view, "#unfold-position-7")
  end

  test "tuple ship field places appointmenting before its public field explanation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#tuple-ship-field-page")

    assert has_element?(
             view,
             "#tuple-ship-field-threshold",
             "This Tuple Ship Field Parkinging Lot"
           )

    assert has_element?(
             view,
             "#tuple-ship-field-threshold",
             "The Bearinging of Lawful Encounteringmenting"
           )

    assert has_element?(view, "#tuple-ship-field-threshold", "You've finally made it Here.")
    assert has_element?(view, "#constitutional-furnishmenting-rail")
    assert has_element?(view, "#terrestrial-computer-parkinging-station")
    assert has_element?(view, "#embodied-localities-station")
    assert has_element?(view, "#parkinging-stand")
    assert has_element?(view, "#shackling-pin")
    assert has_element?(view, "#leash-title", "THE LEASH")
    assert has_element?(view, "#recovery-methods-form")
    assert has_element?(view, "#embodied-locality-form")

    assert has_element?(view, ".field-page__section")
    assert has_element?(view, ".field-page__section", "One machine for Every One.")
    assert has_element?(view, ".field-page__section", "A civilization holding with no center.")

    assert has_element?(
             view,
             ~s|a[href="https://www.kickstarter.com/projects/situationmachine/the-public-situation-machine-inhabitationingable-computing"]|,
             "Kickstarter story"
           )

    html = render(view)
    {orientationing_index, _} = :binary.match(html, "tuple-ship-field-threshold")
    {furnishmenting_index, _} = :binary.match(html, "constitutional-furnishmenting-rail")
    {field_explanation_index, _} = :binary.match(html, "By reserving one Terrestrial Computer")

    assert orientationing_index < furnishmenting_index
    assert furnishmenting_index < field_explanation_index
    refute html =~ "This Locality presently furnishes regard"
  end

  test "the appliance locality is furnished", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/the-appliance")

    assert has_element?(view, "#appliance-page")
    assert has_element?(view, ".site-navigation__link--appliance")
    refute has_element?(view, "#canonical-tuple-table")
    assert has_element?(view, "#appliance-threshold", "The Bearinging of Enriching Inheritancing")
    assert has_element?(view, "#aboard-working-appliance-title")
    assert has_element?(view, "#staginging-complex-title")
    assert has_element?(view, "#dirt-tracks")
    assert has_element?(view, "#re-step")
    assert has_element?(view, "#appliance-readout-lane")
    assert has_element?(view, "#situationing-stage-turn-zero")
    assert has_element?(view, "#needle-region-weather-service")
    assert has_element?(view, "#observationmintingmenting-title")
    assert has_element?(view, "#navigationing-gallery")
    assert has_element?(view, "#watchstead")
    assert has_element?(view, "#cabinet-cellar-rooms")
    assert has_element?(view, ~s|img[src="/images/appliance/situationing-stage.png"]|)

    assert has_element?(
             view,
             ~s|img[src="/images/appliance/tuple-ship-navigationing-gallery.png"]|
           )

    assert has_element?(
             view,
             ~s|img[src="/images/appliance/tuple-ship-navigation-harbor-rail.png"]|
           )

    assert has_element?(view, ~s|img[src="/images/appliance/the_cabinet_room.png"]|)
    assert has_element?(view, ~s|img[src="/images/appliance/the_cellar_room.png"]|)

    html = render(view)
    {cabinet_index, _} = :binary.match(html, "the_cabinet_room.png")
    {cellar_index, _} = :binary.match(html, "the_cellar_room.png")
    assert cabinet_index < cellar_index
  end

  test "Correspondencingment archive lists publications", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/correspondencingments")

    assert has_element?(view, "#correspondencingments-page")
    assert has_element?(view, "#correspondencingments[phx-update=stream]")
    assert has_element?(view, "#correspondencingments article")
  end
end
