defmodule PublicSituationMachineTurnZeroWeb.SiteStructureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "root presents the landing sections and archive action", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#site-navigation")
    assert has_element?(view, "#landinging-page")
    assert page_title(view) =~ "This Landinging Page"
    assert has_element?(view, "#landinging-threshold", "This Approaching Landinging Page")
    assert has_element?(view, "#landinging-threshold", "The Bearinging of Bearingings")
    assert has_element?(view, "#landinging-threshold", "may begin situationing")

    assert has_element?(
             view,
             ~s|#tuple-ship-field-harbor-noticingment[href="/this-tuple-ship-field"]|,
             "TERRESTRIAL COMPUTER FREE PUBLIC PARKINGING THIS WAY"
           )

    refute has_element?(view, "#landinging-threshold", "Seven Stewardly Captain COB")
    refute has_element?(view, "#landinging-re-shackling-form")
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

  test "tuple ship field unfolds constitutionally through Position Two", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#tuple-ship-field-page")
    assert has_element?(view, "#harbor-sign")
    refute has_element?(view, "#resonancing-snail-house-entrance")

    view |> element("#enter-resonancing-snail-house") |> render_click()
    assert has_element?(view, "#resonancing-snail-house-entrance", "first destination")

    view |> element("#approach-sittinging-in-room") |> render_click()
    assert has_element?(view, "#sittinging-in-room", "first constitutional locality")
    assert has_element?(view, "#sittinging-in-room", "The Bearinging of Restfullyinglyment")
    refute has_element?(view, "#division-of-constitutioning-humans")

    view |> element("#un-fold-sittinging-in-room") |> render_click()
    assert has_element?(view, "#sittinging-in-room-unfolded")
    assert has_element?(view, "#re-fold-sittinging-in-room")

    view |> element("#continue-to-division") |> render_click()
    assert has_element?(view, "#division-of-constitutioning-humans")
    refute has_element?(view, "#parkinging-standinging-landinging")

    view |> element("#continue-to-investiturement") |> render_click()
    assert has_element?(view, "#stewardly-co-occupancyingship-investiturement")
    refute has_element?(view, "#parkinging-standinging-landinging")

    view |> element("#accept-stewardly-investiturement") |> render_click()
    assert has_element?(view, "#parkinging-standinging-landinging")
    view |> element("#park-terrestrial-computer") |> render_click()
    assert has_element?(view, "#parkinging-stand")
    assert has_element?(view, "#shackling-pin")
    assert has_element?(view, "#position-zero-traversaling-station")

    view |> element("#complete-zeroeth-appointmenting") |> render_click()
    assert has_element?(view, "#position-one-traversaling-station")

    view
    |> form("#first-appointmenting-form",
      first_appointmenting: %{
        subject: "This One Watershed",
        situationing_kind: "Watershed Stewardship"
      }
    )
    |> render_submit()

    assert has_element?(view, "#position-two-soundinging-bell-station")
    assert has_element?(view, "#projectioning-cross", "Across")
    assert has_element?(view, "#three-traversaling-shoes article:nth-child(1)")
    assert has_element?(view, "#three-traversaling-shoes article:nth-child(2)")
    assert has_element?(view, "#three-traversaling-shoes article:nth-child(3)")
    assert has_element?(view, "#subsequent-build-rounds", "RE-Stepping Room")
    refute has_element?(view, "#re-stepping-room")
    refute has_element?(view, "#turn-index-navigation")
  end

  test "Sittinging-In Room may RE-FOLD to its inherited entrance", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#enter-resonancing-snail-house") |> render_click()
    view |> element("#approach-sittinging-in-room") |> render_click()
    view |> element("#un-fold-sittinging-in-room") |> render_click()
    view |> element("#re-fold-sittinging-in-room") |> render_click()

    assert has_element?(view, "#resonancing-snail-house-entrance")
    assert has_element?(view, "#approach-sittinging-in-room")
    refute has_element?(view, "#sittinging-in-room")
    refute has_element?(view, "#division-of-constitutioning-humans")
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
             "Tuple-Ship-to-Tuple-Ship"
           )

    assert has_element?(
             view,
             "#correspondencingment-2",
             "Aboard The Tuple Ship: The Sittinging Room"
           )

    assert has_element?(view, "#correspondencingments[phx-update=stream]")
    assert has_element?(view, "#correspondencingments article")

    assert has_element?(
             view,
             ~s|#correspondencingment-1-parkinging-noticingment a[href="/this-tuple-ship-field"]|,
             "THIS WAY TO TERRESTRIAL COMPUTER PARKINGING LOT"
           )

    {threshold_index, _} = :binary.match(html, "correspondencingments-threshold")
    {publication_index, _} = :binary.match(html, "correspondencingments-publication-title")
    {list_index, _} = :binary.match(html, ~s|id="correspondencingments"|)

    assert threshold_index < publication_index
    assert publication_index < list_index
  end
end
