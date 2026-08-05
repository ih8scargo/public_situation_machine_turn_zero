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
      {~p"/constitutioning-bearingings", "/constitutioning-bearingings"},
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
      assert has_element?(view, ~s|a[href="/constitutioning-bearingings"]|)
      assert has_element?(view, ~s|a[href="/correspondencingments"]|)
    end
  end

  test "Constitutioning Bearingings presents the public constitutional material", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/constitutioning-bearingings")

    assert has_element?(view, "#constitutioning-bearingings-page")
    assert has_element?(view, "#constitutioning-bearingings-threshold-orientationing-title")
    assert has_element?(view, "#observationing-harbors")
    assert has_element?(view, "#embroidery-stitching")
    assert has_element?(view, "#what-becomes-possible")
    assert has_element?(view, "#observationing-harbors-projectioning")

    for row <- 1..11 do
      assert has_element?(
               view,
               "#observationing-harbors-projectioning tbody tr:nth-child(#{row})"
             )
    end

    refute has_element?(view, "#tuple-position-0")
    refute has_element?(view, "#position-0-regard-inward")
    refute has_element?(view, "#unfold-position-1")
    refute has_element?(view, ".psm-knotting-rail")
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
             "This Tuple Ship Field Public Parkinging Lot"
           )

    assert has_element?(
             view,
             "#tuple-ship-field-threshold",
             "The Bearinging of Lawful Encounteringmenting"
           )

    assert has_element?(view, "#tuple-ship-field-threshold", "You've made it Here.")

    assert has_element?(
             view,
             "#tuple-ship-field-threshold",
             "Constitutioning Humans may approach This One Terrestrial Computer Standinging Landing."
           )

    refute has_element?(view, "#tuple-ship-field-threshold", "This One Leashing")
    refute has_element?(view, "#tuple-ship-field-threshold", "Traversaling")
    assert has_element?(view, "#terrestrial-computer-standinging-landing")
    assert has_element?(view, "#inquire-within", "Inquire Within")
    refute has_element?(view, "#constitutional-furnishmenting-rail")

    view |> element("#inquire-within") |> render_click()

    assert has_element?(view, "#constitutional-furnishmenting-rail")
    assert has_element?(view, "#rail-line-opening-ceremony")
    assert has_element?(view, "#unfold-constitutional-rail-line")
    refute has_element?(view, "#terrestrial-computer-parkinging-station")
    refute has_element?(view, "#parkinging-stand")
    refute has_element?(view, "#shackling-pin")
    refute has_element?(view, "#recovery-methods-form")
    refute has_element?(view, ".field-page__section")

    view |> element("#unfold-constitutional-rail-line") |> render_click()

    view |> element("#take-holdinging-of-leashing") |> render_click()

    assert has_element?(view, "#parkinging-stand")
    assert has_element?(view, "#shackling-pin")
    assert has_element?(view, "#leashing-ceremony-time")
    assert has_element?(view, "#leashing-naming")

    view |> element("#continue-without-leashing-name") |> render_click()
    view |> element("#continue-beyond-re-shackling") |> render_click()
    view |> element("#unfold-station-02") |> render_click()
    refute has_element?(view, "#earthly-locality-form")
    view |> element(~s|button[phx-value-appointmenting="lanterning"]|) |> render_click()
    assert has_element?(view, "#place-library")
    view |> element("#continue-without-earthly-locality") |> render_click()

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
    {terminus_index, _} = :binary.match(html, "tuple-field-terminus-harbor")

    {public_field_harbor_index, _} =
      :binary.match(html, "public-field-discoveringmenting-harbor")

    {field_explanation_index, _} =
      :binary.match(html, "By reserving This One Terrestrial Computer")

    assert orientationing_index < furnishmenting_index
    assert furnishmenting_index < terminus_index
    assert terminus_index < public_field_harbor_index
    assert public_field_harbor_index < field_explanation_index
    refute html =~ "This Locality presently furnishes regard"
  end

  test "the appliance locality is furnished", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/the-appliance")

    assert has_element?(view, "#appliance-page")
    assert has_element?(view, ".site-navigation__link--appliance")
    refute has_element?(view, "#canonical-tuple-table")

    assert has_element?(
             view,
             "#appliance-threshold",
             "The Bearinging of Enrichingmenting Inheritancing"
           )

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
    {:ok, view, html} = live(conn, ~p"/correspondencingments")

    assert has_element?(view, "#correspondencingments-page")

    assert has_element?(
             view,
             "#correspondencingments-threshold",
             "The Bearinging of Lawful Correspondencing"
           )

    assert has_element?(
             view,
             "#correspondencingments-threshold",
             "arrive from the Edge of the Field"
           )

    assert has_element?(
             view,
             "#correspondencingments-publication-title",
             "Twople-Ship-to-Twople-Ship"
           )

    assert has_element?(
             view,
             "#correspondencingment-2",
             "Aboard The Tuple Ship: The Sittinging Room"
           )

    assert has_element?(view, "#correspondencingments[phx-update=stream]")
    assert has_element?(view, "#correspondencingments article")

    {threshold_index, _} = :binary.match(html, "correspondencingments-threshold")
    {publication_index, _} = :binary.match(html, "correspondencingments-publication-title")
    {list_index, _} = :binary.match(html, ~s|id="correspondencingments"|)

    assert threshold_index < publication_index
    assert publication_index < list_index
  end
end
