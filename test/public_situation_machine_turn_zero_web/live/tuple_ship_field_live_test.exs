defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  test "prepends the Station House, Passageway, and skeletal Sittinging-In Room", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#tuple-ship-field-page.constitutional-rail-line")

    assert has_element?(
             view,
             ".constitutional-rail__harbor-station > #tuple-ship-field-threshold"
           )

    assert has_element?(view, "#tuple-ship-field-threshold")
    assert has_element?(view, "#tuple-ship-field-threshold", "Observationing Harbor stands")
    assert has_element?(view, "#resonancing-snail-station-house.constitutional-rail__station")

    assert has_element?(
             view,
             "#enter-opening-passageway",
             "UN-FOLD to Enter The Opening Rite of Passagingway"
           )

    assert has_element?(
             view,
             "#station-house-general-offices-welcome.constitutional-voice--general_stewarding_offices",
             "Here Now Stand"
           )

    assert has_element?(
             view,
             "#station-house-general-offices-welcome h3",
             "Welcoming Constitutioning Humans."
           )

    assert has_element?(
             view,
             "#station-house-general-offices-welcome .constitutional-voice__kind",
             "The General Stewarding Offices of This Stewardshipmenting Appliance"
           )

    assert has_element?(
             view,
             "#station-house-general-offices-welcome",
             "This One Common Wheeling of The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment"
           )

    assert has_element?(
             view,
             "#resonancing-snail-station-house-title span:nth-child(1)",
             "The Snail House"
           )

    assert has_element?(
             view,
             "#resonancing-snail-station-house-title .field-page__snail-station-formal-title",
             "The Resonancing Snail Shellcaverningmenting Station House"
           )

    assert has_element?(
             view,
             "#resonancing-snail-station-house",
             "The Snail House stands at The Mouth of Observationing Harbor, its great spiraling shell roof rising above This Encounteringmenting Wharf and echoing lawful welcome toward Arrival and Return."
           )

    assert has_element?(
             view,
             "#resonancing-snail-station-house",
             "Here, Constitutioning Humans are gathering their Soundingings together within This One Common Civic Snail Shell while carvinging lawful Passagingway along This Constitutional Furnishmenting Rail Line through The Opening Passagingway that is OUR CANONICAL TUPLE."
           )

    assert has_element?(view, "#resonancing-snail-station-house", "Exterior")
    assert has_element?(view, "#resonancing-snail-station-house", "Interior")

    assert has_element?(
             view,
             "#resonancing-snail-station-house",
             "Within, well-appointmented chambers stand furnishingmentingable for quiet Stewardly Inhabitationing."
           )

    assert has_element?(
             view,
             "#resonancing-snail-station-house",
             "Conversationing, Inquiringmenting, and Constitutioning Laboringings stand resonancing gently throughout the surrounding Shellcaverningmenting as Constitutioning Humans arrive, return, and continue carvinging Stewardly Passagingway together over Discrete Turns."
           )

    assert has_element?(view, "#station-tz-region > #resonancing-snail-station-house")
    refute has_element?(view, "#station-tz-region #tuple-ship-field-threshold")

    refute has_element?(view, "#opening-passageway")
    refute has_element?(view, "#turn-zero-sittinging-in-room")
    refute has_element?(view, "#terrestrial-computer-standinging-landing")

    {harbor_index, _} = :binary.match(html, "tuple-ship-field-threshold")
    {station_house_index, _} = :binary.match(html, "resonancing-snail-station-house")
    assert harbor_index < station_house_index

    view |> element("#enter-opening-passageway") |> render_click()

    assert has_element?(view, "#opening-passageway.constitutional-rail__station")
    assert has_element?(view, "#opening-passageway-title", "The Opening Rite of Passagingway")

    refute has_element?(
             view,
             "#opening-passageway",
             "Approaching the architecture now becomes inquiringmenting within the constitutional order."
           )

    assert has_element?(
             view,
             "#before-prepositioning-marker",
             "Segmentationing through Prepositioning"
           )

    assert has_element?(view, "#before-prepositioning-marker", "BEFORE")

    assert has_element?(
             view,
             "#before-prepositioning-stitch + #amicable-grottoes-district-introduction.field-page__chapel-by-the-sea",
             "The Amicable Grottoes District"
           )

    for description <- [
          "The Snail House stands in Readyingment for lawful Gatheringing and Soundinging.",
          "Every Constitutioning Human's Traversaling through The Snail House begins within the Station's Amicable Grottoes District.",
          "Here, Constitutioning Humans find places of Restfullyinginglyment within quiet shell alcoves, just beyond the bustling Great Hall of Globularly Bobbininging Globular Bobbining overlooking Observationing Harbor.",
          "Within one such alcove stands The Sittinging-In Room, furnished as the Zeroeth Constitutional Locality of This One Tuple Ship."
        ] do
      assert has_element?(view, "#amicable-grottoes-district-introduction", description)
    end

    assert has_element?(view, "#restfullyinglyment-harbor-sign", "Standinging in Regard")

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "The Bearinging of Restfullyinglyment"
           )

    assert has_element?(view, "#opening-passageway", "Rite of Passagingway")

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "The Sittinging-In Room stands furnished as the first Constitutional Locality of Stewardly Inhabitationing."
           )

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "Constitutioning Humans may come Here to rest within their Situationings, standing upon This One Piece of Time."
           )

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "Here, Stewardly Inquiry first comes into lawful Availability through Passagingway over Discrete Turns."
           )

    assert has_element?(view, "#opening-passageway > #restfullyinglyment-harbor-sign")

    refute has_element?(view, "#turn-zero-sittinging-in-room")

    assert has_element?(
             view,
             "#sittinging-in-room-upper-unfold #unfold-turn-zero-sittinging-in-room",
             "UN-FOLD"
           )

    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()

    assert has_element?(view, "#turn-zero-station-depot-header", "TURN ZERO")
    assert has_element?(view, "#turn-zero-station-depot-header", "STATION DEPOT TZ")
    refute has_element?(view, "#turn-zero-station-depot-header", "The Sittinging-In Room")
    assert has_element?(view, "#turn-zero-sittinging-in-room", "THIS ONE PIECE OF TIME")
    assert has_element?(view, "#turn-zero-sittinging-in-room.constitutional-rail__station")
    assert has_element?(view, "#turn-zero-sittinging-in-room-title", "The Sittinging-In Room")

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room-title + .field-page__sittinging-subtitle",
             "The Constitutional Locality of Stewardly Availability"
           )

    assert has_element?(
             view,
             ".field-page__would-be-tuple-heading p > span:first-child",
             "This One Would-Be"
           )

    assert has_element?(
             view,
             ".field-page__would-be-tuple-heading p > br + span",
             "Tuple Ship"
           )

    refute has_element?(view, "#turn-zero-sittinging-in-room", "This One Constitutional Locality")
    refute has_element?(view, "#turn-zero-sittinging-in-room time")
    refute has_element?(view, "#turn-zero-sittinging-in-room", "Proto Tuple Ship")
    refute has_element?(view, "#terrestrial-computer-standinging-landing")

    assert has_element?(view, ~s|#toggle-sittinging-xt-cabinet[aria-expanded="false"]|)
    assert has_element?(view, ~s|#toggle-sittinging-yt-cabinet[aria-expanded="false"]|)
    view |> element("#toggle-sittinging-xt-cabinet") |> render_click()
    assert has_element?(view, "#sittinging-xt-cabinet-title", "This One Presence Cabinet")
    assert has_element?(view, "#sittinging-xt-cabinet", "What is feeling Present to me Here?")
    view |> element("#toggle-sittinging-yt-cabinet") |> render_click()
    assert has_element?(view, "#sittinging-yt-cabinet-title", "This One Absence Cabinet")

    assert has_element?(
             view,
             "#sittinging-yt-cabinet",
             "What is feeling Absent to me Here within what is Present to me Here?"
           )

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room",
             "This Constitutioning Human's Stewardly Affordmentings"
           )

    assert has_element?(view, "#constitutioning-human-instrumentation")
    assert has_element?(view, "#constitutioning-human-instrumentation > ol > li:nth-child(7)")

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation-title",
             "Stewardly Instrumentationing"
           )

    for {affordmenting, index} <-
          Enum.with_index(
            ~w(Zeroeth First Second Third Fourth Fifth Sixth),
            1
          ) do
      assert has_element?(
               view,
               "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) [aria-label=XT]",
               "The #{affordmenting} Affordmenting"
             )
    end

    assert has_element?(
             view,
             "#sittinging-room-stewardly-question.constitutional-voice--inquiringmenting_appliance",
             "Inquiringmenting Appliance"
           )

    refute has_element?(view, "#sittinging-room-stewardly-question h3")

    assert has_element?(
             view,
             "#sittinging-room-stewardly-guidance.constitutional-voice--stewardly_guidance"
           )

    refute has_element?(view, "#turn-zero-sittinging-in-room #sittinging-room-stewardly-guidance")

    assert has_element?(
             view,
             "#turn-zero-rail-wayfinding-title",
             "The Constitutional Furnishmenting Rail Line"
           )

    assert has_element?(view, "#turn-zero-rail-wayfinding", "XT")
    assert has_element?(view, "#turn-zero-rail-wayfinding", "Continuing from:")
    assert has_element?(view, "#turn-zero-rail-wayfinding", "Stewardly Availability")
    assert has_element?(view, "#turn-zero-rail-wayfinding", "YT")
    assert has_element?(view, "#turn-zero-rail-wayfinding", "Continuing toward:")
    assert has_element?(view, "#turn-zero-rail-wayfinding", "Stewardly Co-Occupancyingship")
    refute has_element?(view, "#sittinging-room-stewardly-guidance h3")

    assert has_element?(
             view,
             ".field-page__would-be-tuple-heading",
             "Standingable within OUR CANONICAL TUPLE"
           )

    room_html = render(view)

    {piece_of_time_index, _} =
      :binary.match(room_html, ~s|class="field-page__sittinging-time-band"|)

    {room_title_index, _} =
      :binary.match(room_html, ~s|<h2 id="turn-zero-sittinging-in-room-title"|)

    {inquiry_index, _} = :binary.match(room_html, "sittinging-room-stewardly-question")

    {human_affordmentings_index, _} =
      :binary.match(room_html, "field-page__human-affordmentings-title")

    {cabinets_index, _} = :binary.match(room_html, "field-page__sittinging-cabinets")
    {human_shelves_index, _} = :binary.match(room_html, "constitutioning-human-instrumentation")
    {guidance_index, _} = :binary.match(room_html, "sittinging-room-stewardly-guidance")
    {would_be_tuple_index, _} = :binary.match(room_html, "field-page__would-be-tuple-heading")
    {captain_shelves_index, _} = :binary.match(room_html, "proto-stewardly-captain-cob-shelving")
    {primary_cta_index, _} = :binary.match(room_html, "unfold-existing-rail-line")
    assert room_title_index < inquiry_index
    assert inquiry_index < human_affordmentings_index
    assert human_affordmentings_index < cabinets_index
    assert cabinets_index < human_shelves_index
    assert human_shelves_index < would_be_tuple_index
    assert would_be_tuple_index < captain_shelves_index
    assert captain_shelves_index < piece_of_time_index
    assert piece_of_time_index < primary_cta_index
    assert primary_cta_index < guidance_index

    assert has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving",
             "This Stewardly Captain COB's Shelves"
           )

    assert has_element?(view, "#proto-xt-shelves-title", "Constitutional Standinging")
    assert has_element?(view, "#proto-yt-shelves-title", "Stewardly Furnishingment")

    assert has_element?(
             view,
             "#proto-paired-shelves > li:nth-child(7) [aria-label=XT]",
             "The Sixth Appointmenting"
           )

    for {{appointmenting, purpose}, index} <-
          Enum.with_index(
            [
              {"The Zeroeth Appointmenting", "This One Situationing"},
              {"The First Appointmenting", "Encounteringmentablement"},
              {"The Second Appointmenting", "Distinguishingmenting"},
              {"The Third Appointmenting", "Roomingmentingableroomingablement"},
              {"The Fourth Appointmenting", "This One Purchase Surface"},
              {"The Fifth Appointmenting", "Excursioningmenting"},
              {"The Sixth Appointmenting", "Embroideringmentingenablementingedably"}
            ],
            1
          ) do
      shelf_selector = "#proto-paired-shelves > li:nth-child(#{index}) [aria-label=XT]"
      assert has_element?(view, shelf_selector, appointmenting)
      assert has_element?(view, shelf_selector, purpose)
    end

    refute has_element?(view, "#proto-paired-shelves > li:nth-child(8)")

    assert has_element?(
             view,
             "#proto-paired-shelves > li:nth-child(7) [aria-label=YT][aria-hidden=true]"
           )

    refute has_element?(view, "#proto-stewardly-captain-cob-shelving", "Intentionally empty")

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room .field-page__sittinging-departure #unfold-existing-rail-line"
           )

    assert has_element?(
             view,
             "#unfold-existing-rail-line",
             "RE-FOLD over This One Piece of Time from Here toward The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#sittinging-room-stewardly-guidance",
             "The Snail House stands available for the Return of Constitutioning Humans."
           )

    assert has_element?(
             view,
             "#sittinging-room-stewardly-guidance",
             "Return Here upon any One Piece of Time to continue inquiringmenting."
           )

    assert has_element?(view, "#sittinging-room-stewardly-guidance", "Sit.")

    assert has_element?(
             view,
             "#sittinging-room-stewardly-guidance",
             "When ready, RE-FOLD over This One Piece of Time from Here toward The Zeroeth Appointmenting."
           )

    view |> element("#unfold-existing-rail-line") |> render_click()
    refute has_element?(view, "#turn-zero-sittinging-in-room")
    assert has_element?(view, "#tuple-ship-field-page[data-turn-zero-established=true]")

    assert has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "The Bearinging of Stewardly Co-Occupancyingship"
           )

    assert has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "Stewardly Co-Occupancyingship now stands becoming available through lawful Interrelationing with This Stewardly Captain COB."
           )

    refute has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "Stewardly Readyingmenting now stands before the Investituringment of The Seat of The Stewardly Co-Occupancyingship."
           )

    assert has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "From Here, This Constitutioning Human may approach The Terrestrial Computer Parkinging Standinging Landinging to lawfully appoint This Stewardly Captain COB through This One Leashing."
           )

    assert has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "Through This One Leashing, This Stewardly Captain COB may come into Constitutioningable Standinging FOR This One Some One or This One Some Thing."
           )

    assert has_element?(view, "#terrestrial-computer-standinging-landing")

    assert has_element?(
             view,
             "#terrestrial-computer-standinging-landing.constitutional-rail__station"
           )

    rail_html = render(view)
    {division_harbor_index, _} = :binary.match(rail_html, "division-readyingmenting-harbor-sign")
    {division_index, _} = :binary.match(rail_html, "terrestrial-computer-standinging-landing")
    assert division_harbor_index < division_index

    refute has_element?(view, "#constitutional-furnishmenting-rail")
  end

  test "unfolds horizontally paired stewardships into the Crew", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    unfold_entrance(view)

    assert has_element?(
             view,
             "#terrestrial-computer-standinging-landing",
             "THE TERRESTRIAL COMPUTER FREE PUBLIC PARKINGING STANDINGING LANDINGING"
           )

    assert has_element?(
             view,
             "#first-arrival-path",
             "Continue toward Stewardly Co-Occupancyingship."
           )

    refute has_element?(view, "#constitutional-furnishmenting-rail")
    refute has_element?(view, "#chapel-by-the-sea")
    view |> element("#inquire-within") |> render_click()

    assert has_element?(
             view,
             "#constitutional-furnishmenting-rail-title",
             "This Constitutional Furnishmenting Rail Line"
           )

    assert has_element?(
             view,
             "#station-tz-region .field-page__rail-header",
             "This Constitutional Furnishmenting Rail Line begins at The Chapel-along-the-Sea."
           )

    assert has_element?(
             view,
             "#for-prepositioning-marker",
             "Segmentationing through Prepositioning"
           )

    assert has_element?(view, "#for-prepositioning-marker", "FOR")
    assert has_element?(view, "#rail-opening-piece-of-time", "THIS ONE PIECE OF TIME")
    refute has_element?(view, "#rail-opening-piece-of-time time")
    assert has_element?(view, ".field-page__station-header--opening", "STATION DEPOT 00")
    assert has_element?(view, ".field-page__station-header--opening", "THE CHAPEL-ALONG-THE-SEA")

    assert has_element?(view, "#chapel-by-the-sea-title", "The Chapel-along-the-Sea")

    assert has_element?(
             view,
             "#chapel-by-the-sea",
             "The Chapel-along-the-Sea stands prepared for the lawful Investituringment of The Seat of The Stewardly Co-Occupancyingship."
           )

    assert has_element?(
             view,
             "#chapel-by-the-sea",
             "Here, Stewardly Appointmenting stands awaiting Ceremony."
           )

    rail_opening_html = render(view)

    {rail_introduction_index, _} =
      :binary.match(rail_opening_html, "constitutional-furnishmenting-rail-title")

    {chapel_index, _} = :binary.match(rail_opening_html, ~s|id="chapel-by-the-sea"|)
    {before_index, _} = :binary.match(rail_opening_html, ~s|id="before-prepositioning-marker"|)

    {piece_of_time_index, _} =
      :binary.match(rail_opening_html, ~s|id="rail-opening-piece-of-time"|)

    {harbor_index, _} =
      :binary.match(rail_opening_html, ~s|id="division-readyingmenting-harbor-sign"|)

    {division_index, _} =
      :binary.match(rail_opening_html, ~s|id="terrestrial-computer-standinging-landing"|)

    {for_index, _} = :binary.match(rail_opening_html, ~s|id="for-prepositioning-marker"|)
    {depot_index, _} = :binary.match(rail_opening_html, "STATION DEPOT 00")
    assert before_index < piece_of_time_index
    assert piece_of_time_index < harbor_index
    assert harbor_index < division_index
    assert division_index < for_index
    assert for_index < rail_introduction_index
    assert rail_introduction_index < chapel_index
    assert for_index < chapel_index
    assert chapel_index < depot_index

    assert has_element?(
             view,
             "#before-prepositioning-stitch > #before-prepositioning-marker + #rail-opening-piece-of-time"
           )

    assert has_element?(
             view,
             "#rail-line-opening-ceremony",
             "The Taking Holdinging of This One Leashing"
           )

    for paragraph <- [
          "This Constitutioning Human now stands in Stewardly Regard toward What is the Mattering.",
          "Who or what is This One Some One or This One Some Thing that is the Mattering in This One Situationing?",
          "Through The Ceremony of This One Leashing, This One Stewardly Captain COB may come into Appointmenting in Regard to This One Some One or This One Some Thing."
        ] do
      assert has_element?(view, "#rail-line-opening-ceremony", paragraph)
    end

    assert has_element?(view, "#zeroeth-constitutional-inquiry-title", "WHAT IS THE MATTERING?")

    assert has_element?(
             view,
             "#zeroeth-constitutional-inquiry",
             "This One Some One or This One Some Thing"
           )

    assert has_element?(view, "#zeroeth-mattering")
    assert has_element?(view, "#unfold-constitutional-rail-line", "UNFOLD")
    refute has_element?(view, "#terrestrial-computer-parkinging-station")

    view
    |> form("#zeroeth-mattering-form", zeroeth_inquiry: %{mattering: "My dog Enzo"})
    |> render_submit()

    assert has_element?(
             view,
             "#zeroeth-mattering-reception",
             ~s("My dog Enzo" now stands received)
           )

    assert has_element?(view, "#zeroeth-appliance-commitment")
    assert has_element?(view, ".field-page__appointmenting-ceremony-title-card", "CEREMONY")

    assert has_element?(
             view,
             ".field-page__appointmenting-ceremony-title-card",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(view, "#constitutional-furnishmenting-rail .field-page__station")
    assert has_element?(view, "#dual-stewardship-geometry")
    assert has_element?(view, "#stewardship-rail-split")
    assert has_element?(view, ".field-page__stewardship-pair:nth-child(5)")

    assert has_element?(
             view,
             "#dual-stewardship-geometry",
             "This One Piece of Time Unitting Selectioning"
           )

    assert has_element?(view, "#dual-stewardship-geometry", "House of Shackling Pin Furnishings")
    assert has_element?(view, "#stewardship-crew-convergence")
    refute has_element?(view, ".field-page__stewardship-correspondence")

    assert has_element?(
             view,
             "#leashing-crew-conjunction",
             "This One Crew stands inhabitationing Their Laboringings of Interrelationing through These Particular Stewarding Offices."
           )

    assert has_element?(
             view,
             "#leashing-investituringment-ceremony",
             "The Readyingmenting Recital of The General Stewarding Offices of This One Stewardshipmenting Appliance"
           )

    assert has_element?(
             view,
             "#leashing-investituringment-ceremony",
             "Through This Zeroeth Appointmenting, This Stewardly Captain COB now comes into Constitutioningable Standinging through This One Leashing."
           )

    assert has_element?(
             view,
             "#leashing-investituringment-ceremony",
             "The General Stewarding Offices of the Appliance, Holdinging-in-Standinging through The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment, hereby stand in Readyingment"
           )

    refute has_element?(view, "#leashing-investituringment-ceremony", "now inherits")

    assert has_element?(view, "#appliance-narration-voice", "APPLIANCE NARRATIONING")

    assert has_element?(
             view,
             ".constitutional-voice--appliance_narration[aria-labelledby=appliance-narration-voice]"
           )

    assert has_element?(
             view,
             "#appliance-narration-voice + p",
             "may now stand choosing to Take Holdinging"
           )

    assert has_element?(view, "#institutional-standing-voice", "Institutional Standing")
    assert has_element?(view, "#stewardly-guidance-voice", "Stewardly Guidance")

    unfolded_html = render(view)

    ceremony_index =
      :binary.match(unfolded_html, ~s(id="leashing-investituringment-ceremony")) |> elem(0)

    reception_index =
      :binary.match(unfolded_html, ~s(id="zeroeth-mattering-reception")) |> elem(0)

    commitment_index =
      :binary.match(unfolded_html, ~s(id="zeroeth-appliance-commitment")) |> elem(0)

    recital_index = :binary.match(unfolded_html, "The Readyingmenting Recital") |> elem(0)
    narration_index = :binary.match(unfolded_html, ~s(id="appliance-narration-voice")) |> elem(0)

    standing_index =
      :binary.match(unfolded_html, ~s(id="institutional-standing-voice")) |> elem(0)

    guidance_index = :binary.match(unfolded_html, ~s(id="stewardly-guidance-voice")) |> elem(0)
    crew_index = :binary.match(unfolded_html, ~s(id="leashing-crew-conjunction")) |> elem(0)
    ladder_index = :binary.match(unfolded_html, ~s(id="dual-stewardship-geometry")) |> elem(0)

    assert ceremony_index < reception_index
    assert reception_index < commitment_index
    assert commitment_index < recital_index
    assert recital_index < narration_index
    assert narration_index < standing_index
    assert standing_index < guidance_index
    assert guidance_index < crew_index
    assert crew_index < ladder_index

    assert has_element?(
             view,
             ".constitutional-voice--institutional_standing[aria-labelledby=institutional-standing-voice]"
           )

    assert has_element?(
             view,
             ".constitutional-voice--stewardly_guidance[aria-labelledby=stewardly-guidance-voice]"
           )

    refute has_element?(view, "#leashing-investituringment-ceremony", "unfolding the Rail Line")
  end

  test "persists a furnished Name and practices lawful return", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    inquire_and_unfold_station_01(view)
    assert has_element?(view, "#tuple-ship-field-page[data-zeroeth-appointed=false]")
    view |> element("#take-holdinging-of-leashing") |> render_click()
    assert has_element?(view, "#tuple-ship-field-page[data-zeroeth-appointed=true]")

    assert has_element?(view, "#parkinging-credentials #leashing-ceremony-time")

    assert has_element?(
             view,
             ~s|#parkinging-credentials[phx-hook="PublicSituationMachineTurnZeroWeb.CoreComponents.CopyFurnishing"]|
           )

    assert has_element?(
             view,
             "#station-01-sittinging-in-room[data-constitutional-standing=enriched]"
           )

    assert has_element?(
             view,
             "#station-01-sittinging-in-room-title",
             "The Sittinging-In Room"
           )

    assert has_element?(view, "#station-01-sittinging-in-room #leashing-naming")
    refute has_element?(view, "#station-01-sittinging-in-room #station-01-stewardly-guidance")

    assert has_element?(view, "#station-01-rail-wayfinding", "Encounteringmentablement")
    assert has_element?(view, "#station-01-rail-wayfinding", "Distinguishingmenting")
    assert has_element?(view, "#station-01-rail-wayfinding dt:first-of-type", "Continuing From")
    assert has_element?(view, "#station-01-rail-wayfinding dt:last-of-type", "Continuing Toward")

    assert has_element?(
             view,
             "#station-01-stewardly-guidance",
             "When ready, RE-FOLD over This One Piece of Time from Here toward The First Appointmenting"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__sittinging-heading",
             "The Sittinging-In Room"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__human-affordmentings-title + .field-page__sittinging-cabinets"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__constitutional-locality-heading",
             "Standing within OUR CANONICAL TUPLE"
           )

    assert has_element?(view, "#parkinging-credentials", "This One Tuple Ship")
    refute has_element?(view, "#parkinging-credentials", "This One Would-Be Tuple Ship")

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__constitutional-locality-heading + .field-page__constitutional-divider + .field-page__captain-shelves"
           )

    assert has_element?(view, ".field-page__credentials-ground", "THIS ONE PIECE OF TIME")

    assert has_element?(
             view,
             "#parkinging-credentials .field-page__leashing-landing-heading",
             "This One Leashing Landing"
           )

    [_preceding_html, enriched_room_html] =
      render(view) |> String.split(~s|id="parkinging-credentials"|, parts: 2)

    {enriched_room_index, _} =
      :binary.match(enriched_room_html, ~s|<h2 id="parkinging-credentials-title"|)

    {enriched_tuple_index, _} = :binary.match(enriched_room_html, "This One Tuple Ship")

    {enriched_shelves_index, _} =
      :binary.match(enriched_room_html, "parkinging-credentials-shelving-title")

    {enriched_time_index, _} = :binary.match(enriched_room_html, "leashing-ceremony-time")

    {enriched_guidance_index, _} =
      :binary.match(enriched_room_html, "station-01-stewardly-guidance")

    {landing_index, _} = :binary.match(enriched_room_html, "field-page__leashing-landing-heading")
    {stand_index, _} = :binary.match(enriched_room_html, ~s|id="parkinging-stand"|)
    assert enriched_time_index < enriched_room_index
    assert enriched_room_index < enriched_tuple_index
    assert enriched_tuple_index < enriched_shelves_index
    assert enriched_shelves_index < landing_index
    assert landing_index < stand_index
    assert stand_index < enriched_guidance_index

    assert has_element?(view, "#station-01-secret-cabinet:not([open])", "This One Secret Cabinet")

    assert has_element?(
             view,
             ~s|#parkinging-credentials button[aria-label="Copy Parkinging Stand Number"] .hero-document-duplicate|
           )

    assert has_element?(
             view,
             ~s|#parkinging-credentials button[aria-label="Copy Shackling Pin"] .hero-document-duplicate|
           )

    assert has_element?(
             view,
             "#parkinging-credentials-shelving-title",
             "THIS STEWARDLY CAPTAIN COB'S SHELVES"
           )

    assert has_element?(view, "#parkinging-credentials .field-page__shelf-column-headings", "XT")
    assert has_element?(view, "#parkinging-credentials .field-page__shelf-column-headings", "YT")

    assert has_element?(
             view,
             "#parkinging-credentials .field-page__instrument--stand[aria-label='XT']"
           )

    assert has_element?(
             view,
             "#parkinging-credentials .field-page__secret-cabinet[aria-label='YT']"
           )

    assert has_element?(
             view,
             "#parkinging-credentials .field-page__instrument--stand button[data-copy] + [data-copy-status]"
           )

    assert has_element?(
             view,
             "#parkinging-credentials .field-page__secret-cabinet button[data-copy] + [data-copy-status]"
           )

    refute has_element?(view, "#parkinging-credentials > [data-copy-status]")

    assert has_element?(
             view,
             "#parkinging-credentials-instrumentation > ol > li:first-child [aria-label='XT']",
             "This Stewardly Captain COB"
           )

    assert has_element?(
             view,
             "#parkinging-credentials-instrumentation > ol > li:first-child [aria-label='YT']",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__captain-shelves > ol > li:first-child [aria-label='XT']",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__captain-shelves > ol > li:first-child [aria-label='YT']",
             "This One Situationing"
           )

    for {ordinal, index} <- Enum.with_index(~w(First Second Third Fourth Fifth Sixth), 2) do
      for shelf <- [
            "#parkinging-credentials-instrumentation",
            "#parkinging-credentials > .field-page__captain-shelves"
          ],
          relation <- ["XT", "YT"] do
        assert has_element?(
                 view,
                 "#{shelf} > ol > li:nth-child(#{index}) [aria-label='#{relation}']",
                 "The #{ordinal} Appointmenting"
               )
      end
    end

    refute has_element?(view, "#parkinging-credentials .field-page__captain-shelves time")

    refute has_element?(
             view,
             "#parkinging-credentials .field-page__captain-shelves",
             "Awaiting Furnishingment"
           )

    refute has_element?(
             view,
             "#parkinging-credentials .field-page__captain-shelves",
             "Standing Furnished"
           )

    assert has_element?(
             view,
             "#leashing-naming-title",
             "Suiting and RE-Suiting This Stewardly Captain COB"
           )

    assert has_element?(
             view,
             "#leashing-naming",
             "This One Situationing name should describe the Relationing Field"
           )

    parkinging_stand = credential_value(view, "parkinging-stand")
    shackling_pin = credential_value(view, "shackling-pin")

    assert has_element?(
             view,
             ~s|#parkinging-credentials button[aria-label="Copy Parkinging Stand Number"][data-copy="#{parkinging_stand}"]|
           )

    assert has_element?(
             view,
             ~s|#parkinging-credentials button[aria-label="Copy Shackling Pin"][data-copy="#{shackling_pin}"]|
           )

    assert has_element?(
             view,
             "#leashing-name-form button",
             "Name This Stewardly Captain COB's One Situationing"
           )

    view
    |> form("#leashing-name-form", leashing: %{name: "The Harboring Leashing"})
    |> render_submit()

    assert has_element?(view, "#pet-name-continuity-line", "The Harboring Leashing")

    assert has_element?(
             view,
             "#situationing-participationing-guidance",
             "participationing alongside This Constitutioning Human Over Discrete Turns"
           )

    view |> element("#begin-refurbishing-pet-name") |> render_click()

    view
    |> form("#refurbish-pet-name-form", leashing: %{name: "The Lantern Leashing"})
    |> render_submit()

    assert has_element?(view, "#pet-name-continuity-line li:first-child", "The Lantern Leashing")
    refute has_element?(view, "#pet-name-continuity-line", "Pet Name Continuity Line")

    assert has_element?(
             view,
             "#pet-name-continuity-line li:nth-child(2)",
             "The Harboring Leashing"
           )

    assert has_element?(view, "#re-shackling-practice-station")
    assert has_element?(view, "#self-correspondencing-crew")

    view
    |> form("#re-shackling-form",
      re_shackling: %{parkinging_stand: parkinging_stand, shackling_pin: shackling_pin}
    )
    |> render_submit()

    assert_push_event(view, "return_to_constitutional_locality", %{id: "parkinging-credentials"})
    assert has_element?(view, "#re-shackling-returned", "reconstructioned along")
    refute has_element?(view, "#re-shackling-success")
    assert has_element?(view, "#parkinging-credentials", "The Lantern Leashing")

    assert has_element?(
             view,
             "#tuple-ship-lawful-beginning-proclamation",
             "THIS ONE TUPLE SHIP NOW STANDS IN LAWFUL BEGINNING CONTINUINGMENTING."
           )

    assert has_element?(
             view,
             "#leashing-constitutional-declaration",
             "This Stewardly Captain COB's Situationing now stands named The Lantern Leashing."
           )

    assert has_element?(view, "#station-01-secret-cabinet:not([open])")

    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#hail-this-one-leashing")
    assert has_element?(view, "#station-02-opening")
    assert has_element?(view, "#station-02-opening", "The Bearinging of Embodyingmenting")
    refute has_element?(view, "#earthly-localities-station")

    assert has_element?(
             view,
             ~s|#correspondence_destination[placeholder="ThisStewardlyCaptainCOB@ThisOneEmailAddress.com"]|
           )

    view
    |> form("#self-correspondencing-form",
      correspondence: %{channel: "text", destination: ""}
    )
    |> render_change()

    assert has_element?(
             view,
             ~s|#correspondence_destination[placeholder="(000) 000-0000"]|
           )

    view
    |> form("#self-correspondencing-form",
      correspondence: %{channel: "email", destination: "steward@example.test"}
    )
    |> render_submit()

    assert_push_event(view, "hail_leashing", %{href: href})
    correspondence = URI.decode_www_form(href)

    assert correspondence =~ "This Stewardly Captain COB's This One Situationing"
    assert correspondence =~ "now stands lawfully dispatched toward This One Some Place"

    assert correspondence =~ "This One Terrestrial Computer Free Parkinging Stand Number:"
    assert correspondence =~ "This One Shackling PIN:"
    assert correspondence =~ "This One Piece of Time"
    assert correspondence =~ "This Stewardly Captain COB's This One Situationing"

    assert correspondence =~
             "This One Leashing remains the constitutional pathway through which This One Situationing travels."

    assert correspondence =~
             "This Stewardly Captain COB's Situationing Name:\nThe Lantern Leashing"

    assert correspondence =~ "not kept through an account"
    assert String.ends_with?(correspondence, "situationmachine.systems")
  end

  test "requires naming while RE-Shackling remains optional", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    inquire_and_unfold_station_01(view)
    view |> element("#take-holdinging-of-leashing") |> render_click()
    parkinging_stand = credential_value(view, "parkinging-stand")
    refute has_element?(view, "#continue-without-leashing-name")
    refute has_element?(view, "#re-shackling-practice-station")
    furnish_situationing_name(view, "The Continuing Situationing")

    assert has_element?(
             view,
             "#tuple-ship-lawful-beginning-proclamation",
             "LAWFUL BEGINNING CONTINUINGMENTING"
           )

    assert has_element?(view, "#leashing-constitutional-declaration")
    assert has_element?(view, "#re-shackling-practice-station")
    assert has_element?(view, "#self-correspondencing-crew")

    assert has_element?(
             view,
             "#station-00-affordmentings-title",
             "Station Depot 00 Affordmentings"
           )

    assert has_element?(
             view,
             "#station-00-affordmentings .field-page__station-affordmentings-track > #re-shackling-practice-station",
             "Return Here Through This One Leashing"
           )

    assert has_element?(
             view,
             "#station-00-affordmentings .field-page__station-affordmentings-track > #self-correspondencing-crew",
             "Take This One Situationing With You"
           )

    assert has_element?(
             view,
             "#station-00-affordmentings .field-page__station-affordmentings-orientation",
             "Continue Along This Constitutional Furnishmenting Rail Line"
           )

    assert has_element?(
             view,
             "#re-shackling-practice-station",
             "At This Practicementing Locality, This Constitutioning Human may try returning to This Tuple Ship Field Free Public Parkinging Lot through This One Leashing."
           )

    assert has_element?(view, "#re-shackling-practice-station", "PRACTICEMENTING LOCALITY")

    assert has_element?(view, "#station-02-opening")
    assert has_element?(view, "#earthly-localities-station-title", "This One Some Place")
    refute has_element?(view, "#earthly-localities-station-title", "Lanterning")
    refute has_element?(view, "#station-02-opening", "Lanterning Appointmenting may now")
    refute has_element?(view, "#tuple-field-after-leashing-ceremony")

    unfold_station_02(view)
    refute has_element?(view, "#earthly-locality-form")

    assert has_element?(
             view,
             "#first-appointmenting-title.field-page__ceremony-title--station-01",
             "THE FIRST APPOINTMENTING CEREMONY OF ENCOUNTERINGMENTABLEMENT"
           )

    assert has_element?(
             view,
             "#this-one-place-crew",
             "This One Crew stands inhabitationing Their Interrelationing Laboringings through These Particular Stewarding Offices."
           )

    assert has_element?(
             view,
             "#this-one-place-crew",
             "The Readyingmenting Recital of The General Offices of This One Stewardshipmenting Appliance"
           )

    assert has_element?(
             view,
             "#station-01-institutional-standing",
             "This One Some Place Crew now stands in Readyingment for the lawful Placement"
           )

    assert has_element?(
             view,
             "#this-one-place-crew",
             "Together, these stand as This First Appointmenting."
           )

    refute has_element?(view, "#lanterning-appointmenting")

    furnish_proto_appointmentings(view)

    assert has_element?(
             view,
             "#first-appointmenting-standing",
             "This First Appointmenting now stands in lawful Beginning."
           )

    assert has_element?(view, "#lanterning-groundinging-layer")

    assert has_element?(
             view,
             "#place-library",
             "This Library stands furnishing lawful Interrelationings through which This Stewardly Captain COB's This One Situationing may become Visionizingmentable together with This One Some Place upon The Earth."
           )

    assert has_element?(view, "#turn-zero-staging")
    assert has_element?(view, "#turn-zero-xt")
    assert has_element?(view, "#turn-zero-yt")
    assert has_element?(view, "#turn-zero-surface", "Nothing has yet been furnished.")

    assert has_element?(
             view,
             "#continue-without-earthly-locality",
             "Continue by Leaving This One Some Place Undistinguishingmented"
           )

    refute has_element?(view, "#continue-without-earthly-locality", "Without Furnishing")
    view |> element("#continue-without-earthly-locality") |> render_click()

    assert has_element?(
             view,
             "#station-02-enriched-leashing",
             "Visionizingmentablement"
           )

    assert has_element?(
             view,
             "#station-02-enriched-leashing",
             "This One Some Place presently stands left Undistinguishingmented."
           )

    assert has_element?(
             view,
             "#turn-zero-surface",
             "This One Some Place presently stands left Undistinguishingmented."
           )

    assert has_element?(view, "#earthly-locality-form")
    assert has_element?(view, "#lawful-xt-yt-interrelationing")

    assert has_element?(
             view,
             "#earthly-locality-landings",
             "XT–YT INTERRELATIONING CONTINUITY LINE"
           )

    assert has_element?(view, "#tuple-field-after-leashing-ceremony")
    refute has_element?(view, "#rail-line-extension-readiness")

    assert has_element?(
             view,
             "#station-02-completion",
             "current lawful Place of Encounteringmentablement"
           )

    assert has_element?(
             view,
             "#tuple-field-terminus-harbor",
             "The Bearinging of Continuingmenting"
           )

    assert has_element?(
             view,
             "#tuple-field-terminus-harbor",
             "STATION DEPOT 02 — This Soundinging Bell Station"
           )

    assert has_element?(view, "#tuple-field-terminus-harbor", "Second Appointmenting")
    assert has_element?(view, "#public-field-discoveringmenting-harbor")

    assert has_element?(
             view,
             "#public-field-discoveringmenting-harbor",
             "within This Civilization Holding with No Center."
           )

    assert has_element?(view, "#station-02-enriched-leashing")
    assert has_element?(view, "#station-02-secret-cabinet:not([open])")

    assert has_element?(
             view,
             "#station-02-enriched-leashing-instrumentation > ol > li:first-child [aria-label='XT']",
             "This Stewardly Captain COB"
           )

    assert has_element?(
             view,
             "#station-02-enriched-leashing > .field-page__captain-shelves > ol > li:first-child [aria-label='YT']",
             "This One Situationing"
           )

    assert has_element?(view, ".field-page__refold-guidance", "Keep what is Holdinging.")
    assert has_element?(view, ".field-page__refold-guidance", "New Standing")

    view |> element("#re-fold-into-new-standing") |> render_click()

    assert has_element?(view, "#unfold-constitutional-rail-line")
    refute has_element?(view, "#earthly-localities-station")
    refute has_element?(view, "#public-field-discoveringmenting-harbor")

    submit_zeroeth_inquiry(view)
    assert credential_value(view, "parkinging-stand") == parkinging_stand
    assert has_element?(view, "#parkinging-credentials", "Visionizingmentablement")

    assert has_element?(
             view,
             "#parkinging-credentials",
             "This One Some Place upon The Earth"
           )
  end

  test "furnishes and persists This One Place", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    inquire_and_unfold_station_01(view)
    view |> element("#take-holdinging-of-leashing") |> render_click()

    parkinging_stand = credential_value(view, "parkinging-stand")
    shackling_pin = credential_value(view, "shackling-pin")

    furnish_situationing_name(view, "The Earthly Situationing")
    unfold_station_02(view)
    refute has_element?(view, "#earthly-locality-form")
    furnish_proto_appointmentings(view)
    assert has_element?(view, "#earthly-locality-form")

    view
    |> form("#earthly-locality-form", locality: %{country: "US"})
    |> render_change()

    assert has_element?(view, ~s|#locality_region option[value="CA"]|, "California")

    view
    |> form("#earthly-locality-form", locality: %{country: "US", region: "CA"})
    |> render_change()

    assert has_element?(view, ~s|#locality_city option[value="Los Angeles"]|, "Los Angeles")

    view
    |> form("#earthly-locality-form",
      locality: %{
        country: "US",
        region: "CA",
        city: "Los Angeles",
        visionizing_scope: "city"
      }
    )
    |> render_change()

    assert has_element?(view, "#turn-zero-xt-readout", "Los Angeles")
    assert has_element?(view, "#turn-zero-yt-readout", "Los Angeles")

    view
    |> form("#earthly-locality-form",
      locality: %{
        country: "US",
        region: "CA",
        city: "Los Angeles",
        visionizing_scope: "city"
      }
    )
    |> render_submit()

    assert has_element?(
             view,
             "#station-02-completion",
             "stands Visionizinging through Relationing"
           )

    assert has_element?(view, "#station-02-enriched-leashing", "Los Angeles")

    assert has_element?(
             view,
             "#station-02-enriched-leashing",
             "Visionizingmentablement"
           )

    assert has_element?(
             view,
             "#earthly-locality-landings",
             "THIS XT–YT INTERRELATIONING CONTINUITY LINE"
           )

    assert has_element?(view, "#earthly-locality-landings", "Los Angeles")

    assert has_element?(view, "#tuple-field-after-leashing-ceremony")

    assert {:ok, %{earthly_locality: locality}} =
             ParkingingStandRegistry.re_shackle(parkinging_stand, shackling_pin)

    assert locality == %{
             country: "United States",
             region: "California",
             city: "Los Angeles",
             visionizing_scope: "city"
           }

    view
    |> form("#earthly-locality-form",
      locality: %{
        country: "US",
        region: "CA",
        city: "San Francisco",
        visionizing_scope: "country"
      }
    )
    |> render_change()

    assert has_element?(view, "#turn-zero-xt-readout", "San Francisco")
    assert has_element?(view, "#lawful-xt-yt-interrelationing", "Los Angeles")
    refute has_element?(view, "#lawful-xt-yt-interrelationing", "San Francisco")

    view
    |> form("#earthly-locality-form",
      locality: %{
        country: "US",
        region: "CA",
        city: "San Francisco",
        visionizing_scope: "country"
      }
    )
    |> render_submit()

    assert has_element?(view, "#lawful-xt-yt-interrelationing", "San Francisco")
    assert has_element?(view, "#lawful-xt-yt-interrelationing", "United States")
    assert has_element?(view, "#earthly-locality-landings", "Los Angeles")
    assert has_element?(view, "#earthly-locality-landings", "San Francisco")

    view |> element("#re-fold-into-new-standing") |> render_click()
    submit_zeroeth_inquiry(view)

    assert has_element?(view, "#parkinging-credentials", "Visionizingmentablement")
    assert has_element?(view, "#parkinging-credentials", "San Francisco")
    refute has_element?(view, "#parkinging-credentials", "Los Angeles")
  end

  test "reconstructs a returning constitutional locality from the Parkinging Landinging", %{
    conn: conn
  } do
    pin = "ABCD EFGH IJKL MNOP QRST UVWX YZ12 3456"
    leashing = ParkingingStandRegistry.furnish_leashing(pin, ~U[2026-08-05 12:00:00Z])

    {:ok, named_leashing} =
      ParkingingStandRegistry.furnish_pet_name(
        leashing.parkinging_stand,
        pin,
        "The Returning Situationing",
        ~U[2026-08-05 12:01:00Z]
      )

    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    unfold_entrance(view)

    assert has_element?(view, "#returning-constitutioning-human-path")
    refute has_element?(view, "#constitutional-furnishmenting-rail")

    view
    |> form("#constitutional-reception-form",
      reception: %{
        parkinging_stand: named_leashing.parkinging_stand,
        shackling_pin: pin
      }
    )
    |> render_submit()

    assert has_element?(view, "#constitutional-reception-success")
    assert has_element?(view, "#constitutional-furnishmenting-rail")
    assert has_element?(view, "#terrestrial-computer-parkinging-station")
    assert has_element?(view, "#pet-name-continuity-line", "The Returning Situationing")

    assert has_element?(
             view,
             "#pet-name-continuity-line .field-page__naming-guidance",
             "This One Situationing name should describe the Relationing Field"
           )

    assert has_element?(view, "#station-02-opening")
  end

  defp credential_value(view, id) do
    [_, value] = Regex.run(~r/data-value="([^"]+)"/, render(element(view, "##{id}")))
    value
  end

  defp inquire_and_unfold_station_01(view) do
    unfold_entrance(view)
    view |> element("#inquire-within") |> render_click()
    submit_zeroeth_inquiry(view)
  end

  defp submit_zeroeth_inquiry(view) do
    view
    |> form("#zeroeth-mattering-form", zeroeth_inquiry: %{mattering: "What is the Mattering"})
    |> render_submit()
  end

  defp unfold_entrance(view) do
    view |> element("#enter-opening-passageway") |> render_click()
    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()
    view |> element("#unfold-existing-rail-line") |> render_click()
  end

  defp unfold_station_02(view) do
    assert has_element?(view, "#station-02-opening")
    refute has_element?(view, "#earthly-localities-station")

    assert has_element?(
             view,
             "#unfold-station-02",
             "UN-FOLD from Here toward The Zeroeth Appointmenting"
           )

    view |> element("#unfold-station-02") |> render_click()
    assert has_element?(view, "#earthly-localities-station")
  end

  defp furnish_proto_appointmentings(view) do
    refute has_element?(view, "#sounding-bell-appointmenting")

    view
    |> element(~s|#this-one-place-crew button[phx-value-appointmenting="lanterning"]|)
    |> render_click()

    refute has_element?(
             view,
             ~s|#this-one-place-crew button[phx-value-appointmenting="lanterning"]|
           )
  end

  defp furnish_situationing_name(view, name) do
    view
    |> form("#leashing-name-form", leashing: %{name: name})
    |> render_submit()
  end
end
