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
             "Welcominging Constitutioning Humans."
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

    assert has_element?(
             view,
             "#resonancing-snail-station-house + #constitutional-furnishmenting-rail-entrance.psm-oag",
             "The Constitutional Furnishmenting Rail"
           )

    assert has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance + #opening-passageway"
           )

    assert has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance",
             "Here stands The Constitutional Furnishmenting Rail."
           )

    assert has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance",
             "From Here, Stewardly Passagingway becomes lawfully available over Discrete Turns."
           )

    assert has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance",
             "Stewardly Constitutional Localities stand furnished in Readyingment for Regard, Appointmenting, and Continuing Constitutioning."
           )

    refute has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance",
             "ordered approach"
           )

    refute has_element?(
             view,
             "#constitutional-furnishmenting-rail-entrance",
             "Station Depot TZ stands as the first depot encountered"
           )

    assert has_element?(view, "#opening-passageway.constitutional-rail__station")
    assert has_element?(view, "#opening-passageway-title", "The Threshold of Ceremonying")
    assert has_element?(view, "#opening-passageway", "The Opening Rite of Passagingway")

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
             "The Amicable Grottoes Districtinging"
           )

    for description <- [
          "The Amicable Grottoes Districtinging stands furnishing This Constitutional Convenience in Regard to the Continuing Minting of Stewardly Constitutional Localities through Stewardly Regard over Discrete Turns.",
          "The Snail House stands in Readyingment for lawful Gatheringing and Soundinging.",
          "Every Constitutioning Human's Traversaling through The Snail House begins within The Amicable Grottoes Districtinging.",
          "Here, Constitutioning Humans find places of Restfullyinginglyment within quiet shell alcoves, just beyond the bustling Great Hall of Globularly Bobbininging Globular Bobbining looking over into Observationing Harbor.",
          "Within one such alcove stands The Sittinging-In Room, furnished as the Turn-Zeroeth Constitutional Locality of This One Tuple Ship."
        ] do
      assert has_element?(view, "#amicable-grottoes-district-introduction", description)
    end

    assert has_element?(view, "#restfullyinglyment-harbor-sign", "Standinging in Regard")

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "Bearinging toward Restfullyinginglyment"
           )

    assert has_element?(view, "#opening-passageway", "Rite of Passagingway")

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "The Sittinging-In Room stands furnished as The Constitutional Locality of This One Tuple Ship."
           )

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "Constitutioning Humans may come Here to sit in Restfullyinginglyment within their Situationings upon This One Piece of Time."
           )

    assert has_element?(
             view,
             "#restfullyinglyment-harbor-sign",
             "Here, Constitutioning Humans may find places of Restfullyinginglyment from which Stewardly Regard may continue over Discrete Turns."
           )

    assert has_element?(view, "#opening-passageway > #restfullyinglyment-harbor-sign")

    assert has_element?(view, "#turn-zero-station-depot-header", "STATION DEPOT TZ")

    assert has_element?(
             view,
             "#turn-zero-constitutional-locality-title",
             "Within One Such Alcove"
           )

    assert has_element?(
             view,
             "#turn-zero-constitutional-locality .field-page__locality-subtitle",
             "The Turn-Zeroeth Constitutional Locality of This One Tuple Ship"
           )

    assert has_element?(view, "#turn-zero-locality-harbor-sign", "The General Stewarding Offices")
    assert has_element?(view, "#turn-zero-locality-harbor-sign-title", "Within One Such Alcove")
    refute has_element?(view, "#turn-zero-locality-harbor-sign-title", "Welcome")
    assert has_element?(view, "#turn-zero-locality-harbor-sign .psm-oag__description", "Welcome.")

    assert has_element?(
             view,
             "#turn-zero-locality-harbor-sign .psm-oag__description",
             "The Sittinging-In Room stands furnished as The Constitutional Locality of This One Tuple Ship."
           )

    refute has_element?(
             view,
             "#turn-zero-locality-harbor-sign .psm-oag__description",
             "Turn-Zeroeth Constitutional Locality"
           )

    assert has_element?(
             view,
             "#turn-zero-locality-harbor-sign .psm-oag__description",
             "The Constitutional Furnishmenting Rail gives lawful approach"
           )

    assert has_element?(view, "#turn-zero-locality-appliance-narration")

    for description <- [
          "This Constitutioning Human has come inquiringmenting regarding the Appointmenting of This Stewardly Captain COB.",
          "This Stewardly Captain COB likewise now stands in Readyingment for its Appointmenting.",
          "Together, This Constitutioning Human and This Stewardly Captain COB now stand prepared to begin Co-Constituting This One Stewardly Co-Occupancyingship."
        ] do
      assert has_element?(view, "#turn-zero-ceremonying-preparation", description)
    end

    assert has_element?(
             view,
             "#turn-zero-stewardly-guidance",
             "does not stand as a testing of knowledge"
           )

    assert has_element?(
             view,
             "#turn-zero-stewardly-guidance",
             "the constitutional establishment of the Stewardly Relationing"
           )

    refute has_element?(
             view,
             "#turn-zero-stewardly-guidance",
             "Enter with what is Present, what is Absent within that Presence"
           )

    assert has_element?(
             view,
             "#turn-zero-stewardly-guidance",
             "enter The Sittinging-In Room in Readyingment to begin the Appointmenting with This Stewardly Captain COB"
           )

    refute has_element?(view, "#turn-zero-sittinging-in-room")

    assert has_element?(
             view,
             "#sittinging-in-room-upper-unfold #unfold-turn-zero-sittinging-in-room",
             "UN-FOLD to Enter The Sittinging-In Room at Turn Zero"
           )

    assert has_element?(
             view,
             "#sittinging-in-room-upper-unfold",
             "This UN-FOLD begins the Appointmenting."
           )

    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()

    assert has_element?(view, "#turn-zero-station-depot-header", "TURN ZERO")
    assert has_element?(view, "#turn-zero-station-depot-header", "STATION DEPOT TZ")
    refute has_element?(view, "#turn-zero-station-depot-header", "The Sittinging-In Room")
    assert has_element?(view, "#turn-zero-sittinging-in-room", "THIS ONE PIECE OF TIME")
    assert has_element?(view, "#turn-zero-sittinging-in-room.constitutional-rail__station")
    assert has_element?(view, "#turn-zero-sittinging-in-room-title", "The Sittinging-In Room")
    refute has_element?(view, "#sittinging-in-room-upper-unfold")

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room-title + #turn-zero-tuple-ship-heading",
             "THIS ONE TUPLE SHIP"
           )

    assert has_element?(
             view,
             "#turn-zero-tuple-ship-heading + .field-page__sittinging-subtitle",
             "The Constitutional Locality of Stewardly Availability"
           )

    refute has_element?(view, "#turn-zero-sittinging-in-room", "This One Would-Be Tuple Ship")
    refute has_element?(view, "#turn-zero-sittinging-in-room", "This One Would-Be")

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
    assert has_element?(view, "#constitutioning-human-instrumentation > ol > li:nth-child(8)")

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation-title",
             "INSTRUMENTATIONINGMENTINGS"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation-title > span:first-child",
             "STEWARDLY"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation-title > span:last-child",
             "INSTRUMENTATIONINGMENTINGS"
           )

    assert has_element?(
             view,
             ~s|#constitutioning-human-instrumentation header .field-page__shelving-arrows[aria-hidden="true"] span:first-child|,
             "↓"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation .field-page__shelf-column-headings > section:first-child",
             "YT"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation .field-page__shelf-column-headings > section:nth-child(2)",
             "Constitutioning Human Affordmentings"
           )

    for {{position, affordmenting, purpose}, index} <-
          Enum.with_index(
            [
              {"06", "The Sixth Affordmenting", "The Ability to Embroiderize"},
              {"05", "The Fifth Affordmenting", "The Ability to Excursion"},
              {"04", "The Fourth Affordmenting", "The Ability to Gain Purchase"},
              {"03", "The Third Affordmenting", "The Ability to Make Room"},
              {"02", "The Second Affordmenting", "The Ability to Distinguish"},
              {"01", "The First Affordmenting", "The Ability to Encounter"},
              {"00", "The Zeroeth Affordmenting", "The Ability to Regard"},
              {"TZ", "The Turn-Zeroeth Affordmenting", "WHAT THIS COB MAY BE CALLING ME"}
            ],
            1
          ) do
      selector =
        "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) [aria-label=XT]"

      assert has_element?(view, selector, affordmenting)
      assert has_element?(view, selector, purpose)

      assert has_element?(
               view,
               "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) .field-page__tuple-position",
               position
             )

      assert has_element?(
               view,
               "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) .field-page__tuple-position > span:first-child",
               position
             )

      assert has_element?(
               view,
               "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) .field-page__tuple-position > span:last-child",
               position
             )

      refute has_element?(
               view,
               "#constitutioning-human-instrumentation > ol > li:nth-child(#{index}) .field-page__tuple-position button"
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

    assert has_element?(view, "#turn-zero-surfacing-title", "TURN ZERO SURFACING")

    assert has_element?(
             view,
             "#turn-zero-surfacing > header",
             "This Constitutioning Work Surface"
           )

    assert has_element?(view, "#turn-zero-active-interrelationing", "What Is Being Worked With")
    refute has_element?(view, "#turn-zero-coordinate-readout")
    refute has_element?(view, "#turn-zero-staging-regions")
    assert has_element?(view, "#turn-zero-staging-result", "THIS XT–YT RELATIONING")

    assert has_element?(
             view,
             "#turn-zero-staging-result",
             "No XT–YT Relationing presently stands staged upon This Work Surface."
           )

    assert has_element?(view, "#turn-zero-holdinging-in-standinging")
    refute has_element?(view, "#turn-zero-surfacing #turn-zero-holdinging-in-standinging")

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room > #stewarding-instrumentationing-menting-haus"
           )

    assert has_element?(
             view,
             "#stewarding-instrumentationing-menting-haus > #turn-zero-surfacing"
           )

    assert has_element?(
             view,
             "#stewarding-instrumentationing-menting-haus > #turn-zero-holdinging-in-standinging"
           )

    assert has_element?(
             view,
             "#stewarding-instrumentationing-menting-haus > #stewardly-captain-cob-wardrobe > #proto-stewardly-captain-cob-shelving"
           )

    assert has_element?(view, "#turn-zero-stitching-needle-title", "THE STITCHING NEEDLE")

    assert has_element?(
             view,
             "#turn-zero-stitching-needle-furnishment",
             "may be used for Appointmenting"
           )

    assert has_element?(
             view,
             ~s|#turn-zero-stitching-needle-furnishment[data-full-strength="true"]|
           )

    assert has_element?(
             view,
             "#stewarding-instrumentationing-menting-haus > #turn-zero-stitching-needle-furnishment + #constitutioning-human-instrumentation"
           )

    assert has_element?(
             view,
             "#stewardly-captain-cob-wardrobe-title",
             "This Stewardly Captain COB's Wardrobe within This STEWARDING INSTRUMENTATIONING MENTING HAUS"
           )

    refute has_element?(view, "#stewardly-captain-cob-wardrobe-title", "Shelvinging")

    assert has_element?(
             view,
             "#cob-shelvinging-title",
             "This Stewardly Captain COB's Shelvinging"
           )

    refute has_element?(view, "#unfold-existing-rail-line")

    establish_turn_zero_for(view)

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
    {departure_ceremony_index, _} = :binary.match(room_html, "turn-zero-departure-ceremonying")
    {tuple_ship_heading_index, _} = :binary.match(room_html, "turn-zero-tuple-ship-heading")
    {turn_zero_surfacing_index, _} = :binary.match(room_html, "turn-zero-surfacing-title")
    {captain_shelves_index, _} = :binary.match(room_html, "proto-stewardly-captain-cob-shelving")
    {wayfinding_index, _} = :binary.match(room_html, "turn-zero-departure-wayfinding")
    {primary_cta_index, _} = :binary.match(room_html, "unfold-existing-rail-line")
    assert room_title_index < tuple_ship_heading_index
    assert tuple_ship_heading_index < inquiry_index
    assert room_title_index < inquiry_index
    assert inquiry_index < human_affordmentings_index
    assert human_affordmentings_index < cabinets_index
    assert cabinets_index < human_shelves_index
    assert human_shelves_index < turn_zero_surfacing_index
    assert turn_zero_surfacing_index < captain_shelves_index
    assert captain_shelves_index < piece_of_time_index
    assert piece_of_time_index < wayfinding_index
    assert wayfinding_index < primary_cta_index
    assert departure_ceremony_index < primary_cta_index

    assert has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving",
             "This Stewardly Captain COB's Shelvinging"
           )

    assert has_element?(
             view,
             ~s|#stewardly-captain-cob-wardrobe > footer .field-page__shelving-arrows[aria-hidden="true"] span:first-child|,
             "↑"
           )

    assert has_element?(view, "#proto-xt-shelves-title", "Stewardly Captain COB Appointmentings")
    assert has_element?(view, "#proto-yt-shelves-title", "YT")
    refute has_element?(view, "#proto-yt-shelves-title span")

    assert has_element?(
             view,
             "#proto-paired-shelves > li:nth-child(8) [aria-label=XT]",
             "The Sixth Appointmenting"
           )

    for {{position, appointmenting, purpose}, index} <-
          Enum.with_index(
            [
              {"TZ", "The Turn-Zeroeth Appointmenting", "WHAT I MAY BE CALLING THIS COB"},
              {"00", "The Zeroeth Appointmenting", "This One Situationing"},
              {"01", "The First Appointmenting", "Encounteringmentablement"},
              {"02", "The Second Appointmenting", "Distinguishingmenting"},
              {"03", "The Third Appointmenting", "Roomingmentingableroomingablement"},
              {"04", "The Fourth Appointmenting", "This One Purchase Surface"},
              {"05", "The Fifth Appointmenting", "Excursioningmenting"},
              {"06", "The Sixth Appointmenting", "Embroideringmentingenablementingedably"}
            ],
            1
          ) do
      shelf_selector = "#proto-paired-shelves > li:nth-child(#{index}) [aria-label=XT]"
      assert has_element?(view, shelf_selector, appointmenting)
      assert has_element?(view, shelf_selector, purpose)

      assert has_element?(
               view,
               "#proto-paired-shelves > li:nth-child(#{index}) .field-page__tuple-position",
               position
             )

      assert has_element?(
               view,
               "#proto-paired-shelves > li:nth-child(#{index}) .field-page__tuple-position > span:first-child",
               position
             )

      assert has_element?(
               view,
               "#proto-paired-shelves > li:nth-child(#{index}) .field-page__tuple-position > span:last-child",
               position
             )

      refute has_element?(
               view,
               "#proto-paired-shelves > li:nth-child(#{index}) .field-page__tuple-position button"
             )
    end

    refute has_element?(view, "#proto-paired-shelves > li:nth-child(9)")

    assert has_element?(
             view,
             "#proto-paired-shelves > li:nth-child(8) [aria-label=YT][aria-hidden=true]"
           )

    refute has_element?(view, "#proto-stewardly-captain-cob-shelving", "Intentionally empty")

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room .field-page__sittinging-departure #unfold-existing-rail-line"
           )

    assert has_element?(
             view,
             "#turn-zero-sittinging-in-room #turn-zero-departure-wayfinding #turn-zero-rail-wayfinding"
           )

    assert has_element?(
             view,
             "#unfold-existing-rail-line",
             "RE-FOLD from Here over This One Piece of Time through BEFORE toward The Zeroeth Appointmenting."
           )

    assert has_element?(
             view,
             "#turn-zero-departure-ceremonying",
             "I will be standing in waiting There when you Return Here."
           )

    view |> element("#unfold-existing-rail-line") |> render_click()
    refute has_element?(view, "#turn-zero-sittinging-in-room")
    assert has_element?(view, "#tuple-ship-field-page[data-turn-zero-established=true]")

    assert has_element?(
             view,
             "#division-readyingmenting-harbor-sign",
             "Bearinging toward Stewardly Co-Occupancyingship"
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

  test "preserves the constitutional seam from Turn-Zeroeth preparation toward Station Depot 00",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#enter-opening-passageway") |> render_click()

    assert has_element?(
             view,
             "#turn-zero-constitutional-locality",
             "The Turn-Zeroeth Constitutional Locality of This One Tuple Ship"
           )

    assert has_element?(view, "#unfold-turn-zero-sittinging-in-room")
    refute has_element?(view, "#turn-zero-sittinging-in-room")

    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()

    assert has_element?(view, "#turn-zero-sittinging-in-room-title", "The Sittinging-In Room")
    assert has_element?(view, "#turn-zero-tuple-ship-heading", "THIS ONE TUPLE SHIP")
    assert has_element?(view, "#turn-zero-surfacing-title", "TURN ZERO SURFACING")
    refute has_element?(view, "#unfold-turn-zero-sittinging-in-room")

    refute has_element?(view, "#unfold-existing-rail-line")
    establish_turn_zero_for(view)
    view |> element("#unfold-existing-rail-line") |> render_click()

    refute has_element?(view, "#turn-zero-sittinging-in-room")
    assert has_element?(view, "#terrestrial-computer-standinging-landing")
    assert has_element?(view, "#inquire-within", "Inquire into The Zeroeth Appointmenting")
    refute has_element?(view, "#station-depot-00-marker")
  end

  test "places little naming stitches on their originating shelves and the FOR across the seam",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#enter-opening-passageway") |> render_click()
    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation > ol > li:first-child [aria-label=XT]",
             "The Sixth Affordmenting"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation > ol > li:last-child [aria-label=XT]",
             "The Turn-Zeroeth Affordmenting"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation > ol > li:last-child > section:nth-child(2)[aria-label=YT]"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation > ol > li:last-child > section:nth-child(3)[aria-label=XT]"
           )

    assert has_element?(
             view,
             "#constitutioning-human-instrumentation > ol > li:last-child > header:first-child",
             "TZ"
           )

    refute has_element?(view, ".field-page__shelf-column-headings", "Tuple Position")

    assert has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving .field-page__shelf-column-headings > section:last-child",
             "YT"
           )

    refute has_element?(view, "#turn-zero-inquiring-humaning")
    refute has_element?(view, "#turn-zero-human-name-staging-form-second")

    assert has_element?(
             view,
             "#stewardly-captain-furnished-name",
             "This Stewardly Captain COB already stands named This Stewardly Captain COB"
           )

    assert has_element?(view, "#constitutioning-human-constitutional-xt", "My Stewarding Officer")
    refute has_element?(view, "#turn-zero-holdinging-in-standinging article")

    assert has_element?(view, ~s|#turn-zero-surfacing[data-initial-naming-guidance="true"]|)

    refute has_element?(
             view,
             "#constitutioning-human-instrumentation .field-page__shelving-arrows button"
           )

    refute has_element?(
             view,
             "#proto-stewardly-captain-cob-shelving .field-page__shelving-arrows button"
           )

    view |> element("#unfold-cob-calls-human-interrelationing") |> render_click()

    assert has_element?(
             view,
             "#turn-zero-active-interrelationing",
             "WHAT THIS COB MAY BE CALLING ME"
           )

    assert has_element?(
             view,
             "#turn-zero-inquiring-humaning",
             "What may I be calling you as we are Traversaling alongside each other over Discrete Turns?"
           )

    assert has_element?(view, ~s|#turn-zero-staging-region-first[data-coordinate="XT"]|)
    assert has_element?(view, ~s|#turn-zero-staging-region-second[data-coordinate="YT"]|)
    assert has_element?(view, "#turn-zero-coordinate-readout", "XT → YT")

    assert has_element?(
             view,
             "#turn-zero-conversational-projection",
             "My Stewarding Officer"
           )

    view
    |> form("#turn-zero-human-name-staging-form-second",
      turn_zero_human_name: %{name: "Richard"}
    )
    |> render_change()

    assert has_element?(
             view,
             "#turn-zero-conversational-projection",
             "Richard, My Stewarding Officer"
           )

    assert has_element?(
             view,
             "#turn-zero-staging-result dl > div:first-child",
             "XT My Stewarding Officer"
           )

    assert has_element?(view, "#turn-zero-staging-result dl > div:last-child", "YT Richard")
    refute has_element?(view, "#cob-calls-human-standing")

    view
    |> form("#turn-zero-human-name-staging-form-second",
      turn_zero_human_name: %{name: "Richard Songbird"}
    )
    |> render_change()

    assert has_element?(
             view,
             "#turn-zero-conversational-projection",
             "Richard Songbird, My Stewarding Officer"
           )

    refute has_element?(view, "#cob-calls-human-standing")

    view
    |> form("#turn-zero-human-name-staging-form-second",
      turn_zero_human_name: %{name: "Magical Cement Fairy"}
    )
    |> render_change()

    view |> element("#refold-turn-zero-relationing-into-standinging") |> render_click()

    assert has_element?(
             view,
             ~s|#cob-calls-human-shelved-standing[data-coordinate="YT"][data-constitutional-xt="My Stewarding Officer"]|,
             "WHAT THIS COB MAY BE CALLING ME Magical Cement Fairy"
           )

    assert has_element?(view, "#constitutioning-human-constitutional-xt", "My Stewarding Officer")
    refute has_element?(view, "#human-calls-cob-shelved-standing")
    refute has_element?(view, "#turn-zero-holdinging-in-standinging", "Magical Cement Fairy")
    refute has_element?(view, "#turn-zero-coordinate-readout")
    refute has_element?(view, "#turn-zero-human-name-staging-form-second")

    assert has_element?(
             view,
             "#turn-zero-active-interrelationing",
             "No Interrelationing Presently Stands under Active Regard"
           )

    view |> element("#unfold-human-calls-cob-interrelationing") |> render_click()

    assert has_element?(view, ~s|#turn-zero-coordinate-readout[data-projection="xt_second"]|)
    assert has_element?(view, "#turn-zero-coordinate-readout", "YT ← XT")

    assert has_element?(
             view,
             "#turn-zero-cob-naming-guidance",
             "My name is This Stewardly Captain COB. You are free to begin calling me a name of your choice as we are Traversaling alongside each other over Discrete Turns."
           )

    assert has_element?(view, "#choose-alternate-cob-name", "CALL ME SOMETHING ELSE")
    assert has_element?(view, "#choose-furnished-cob-name", "CALL ME THIS STEWARDLY CAPTAIN COB")

    view |> element("#choose-alternate-cob-name") |> render_click()

    view
    |> form("#turn-zero-cob-name-staging-form-first",
      turn_zero_cob_name: %{name: "Bob the COB"}
    )
    |> render_change()

    assert has_element?(
             view,
             "#turn-zero-conversational-projection",
             "You may be calling me Bob the COB."
           )

    assert has_element?(
             view,
             "#turn-zero-staging-result dl > div:first-child",
             "XT This Stewardly Captain COB"
           )

    assert has_element?(
             view,
             "#turn-zero-staging-result dl > div:last-child",
             "YT Bob the COB"
           )

    view |> element("#refold-turn-zero-relationing-into-standinging") |> render_click()

    assert has_element?(
             view,
             ~s|#human-calls-cob-shelved-standing[data-coordinate="YT"][data-constitutional-xt="This Stewardly Captain COB"]|,
             "WHAT I MAY BE CALLING THIS COB Bob the COB"
           )

    assert has_element?(view, "#stewardly-captain-furnished-name", "This Stewardly Captain COB")
    assert has_element?(view, "#cob-calls-human-shelved-standing", "Magical Cement Fairy")
    refute has_element?(view, "#turn-zero-holdinging-in-standinging", "Bob the COB")
    refute has_element?(view, "#turn-zero-coordinate-readout")

    view |> element("#unfold-cob-calls-human-interrelationing") |> render_click()

    assert has_element?(
             view,
             ~s|#turn-zero-surfacing[data-active-interrelationing="cob_calls_human"]|
           )

    assert has_element?(view, "#turn-zero-human-name-staging-form-second")

    view
    |> form("#turn-zero-human-name-staging-form-second",
      turn_zero_human_name: %{name: "Richard"}
    )
    |> render_change()

    assert has_element?(view, "#cob-calls-human-shelved-standing", "Magical Cement Fairy")
    view |> element("#refold-turn-zero-relationing-into-standinging") |> render_click()
    assert has_element?(view, "#cob-calls-human-shelved-standing", "Richard")
    assert has_element?(view, "#human-calls-cob-shelved-standing", "Bob the COB")

    assert has_element?(
             view,
             ~s|#turn-zero-surfacing[data-initial-naming-guidance="false"]|
           )

    refute has_element?(view, "#unfold-existing-rail-line")

    assert has_element?(
             view,
             "#turn-zero-encounteringmenting-capability",
             "Through our Stewardly Co-Occupancyingship, I may be suited to become Encounteringmenting as our Traversaling together unfolds over Discrete Turns."
           )

    assert has_element?(
             view,
             "#turn-zero-cob-standing-in-waiting",
             "stands in waiting to be appointed"
           )

    view |> element("#unfold-turn-zero-for-appointmenting") |> render_click()

    assert has_element?(
             view,
             "#turn-zero-for-inquiry",
             "I am This Stewardly Captain COB. What may I now begin looking for, starting Here, upon This One Piece of Time?"
           )

    assert has_element?(view, "#turn-zero-for-human-origin", "My Stewarding Officer")
    assert has_element?(view, "#turn-zero-for-cob-origin", "This Stewardly Captain COB")

    view
    |> form("#turn-zero-mattering-staging-form",
      turn_zero_mattering: %{mattering: "The river becoming safely crossable"}
    )
    |> render_change()

    refute has_element?(view, "#turn-zero-for-standing")
    view |> element("#refold-turn-zero-for-into-standinging") |> render_click()

    assert has_element?(
             view,
             ~s|#turn-zero-for-standing[data-crosses-middle-seam="true"]|,
             "The river becoming safely crossable"
           )

    assert has_element?(
             view,
             "#turn-zero-for-human-provenance",
             "My Stewarding Officer furnished"
           )

    assert has_element?(
             view,
             "#turn-zero-for-cob-provenance",
             "This Stewardly Captain COB stands appointed toward looking for it"
           )

    refute has_element?(view, "#turn-zero-coordinate-readout")

    assert has_element?(
             view,
             "#turn-zero-active-interrelationing",
             "No Interrelationing Presently Stands under Active Regard"
           )

    assert has_element?(
             view,
             "#turn-zero-departure-ceremonying",
             "My Stewarding Officer, I am noticing something about The Stitching Needle."
           )

    assert has_element?(
             view,
             "#turn-zero-departure-ceremonying > p:last-child",
             "I will be standing in waiting There when you Return Here."
           )

    refute has_element?(view, "#turn-zero-departure-ceremonying", "upgrade")
    refute has_element?(view, "#turn-zero-departure-ceremonying", "Christeninging")

    assert has_element?(
             view,
             ~s|#turn-zero-stitching-needle-furnishment[data-full-strength="true"]|
           )

    assert has_element?(view, "#unfold-existing-rail-line")
    assert has_element?(view, "#turn-zero-sittinging-in-room")
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

    assert has_element?(view, "#for-prepositioning-marker", "FOR ALONG")
    assert has_element?(view, "#rail-opening-piece-of-time", "THIS ONE PIECE OF TIME")
    refute has_element?(view, "#rail-opening-piece-of-time time")

    assert has_element?(
             view,
             ~s|#station-depot-00-marker.field-page__station-depot-marker[aria-labelledby="station-depot-00-title"]|,
             "STATION DEPOT 00"
           )

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
             "Here, Stewardly Appointmenting stands awaiting Ceremonying."
           )

    assert has_element?(view, "#unfold-station-00", "UN-FOLD Station Depot 00 Interior")
    refute has_element?(view, "#rail-line-opening-ceremony")
    refute has_element?(view, "#zeroeth-constitutional-inquiry")

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
    assert rail_introduction_index < depot_index
    assert depot_index < chapel_index

    assert has_element?(
             view,
             "#before-prepositioning-stitch > #before-prepositioning-marker + #rail-opening-piece-of-time"
           )

    view |> element("#unfold-station-00") |> render_click()

    assert has_element?(view, "#station-depot-00-marker")
    assert has_element?(view, "#chapel-by-the-sea")
    refute has_element?(view, "#unfold-station-00")

    assert has_element?(
             view,
             "#rail-line-opening-ceremony.field-page__station-interior--newly-unfolded",
             "The Taking Holdinging of This One Leashing"
           )

    assert has_element?(
             view,
             ~s|#rail-line-opening-ceremony.field-page__ceremonying-declaration[data-constitutional-furnishing="ceremonying-declaration"]|
           )

    for paragraph <- [
          "This Constitutioning Human now stands prepared to appoint This One Stewardly Captain COB through This Ceremonying of This One Leashing.",
          "Through This Ceremonying, This One Stewardly Captain COB may lawfully traverse alongside This Constitutioning Human through This One Situationing in Stewardly Regard."
        ] do
      assert has_element?(view, "#rail-line-opening-ceremony", paragraph)
    end

    assert has_element?(
             view,
             "#zeroeth-constitutional-inquiry-title",
             "THIS STEWARDLY CAPTAIN COB"
           )

    assert has_element?(
             view,
             "#zeroeth-constitutional-inquiry",
             "This Stewardly Captain COB"
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
             ~s("My dog Enzo" now stands received as This One Stewardly Captain COB)
           )

    refute has_element?(view, "#zeroeth-appliance-commitment")
    assert has_element?(view, ".field-page__appointmenting-ceremony-title-card", "CEREMONYING")

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
             "The General Stewarding Offices hereby stand in Readyingment for This Zeroeth Appointmenting through This Ceremonying of This One Leashing."
           )

    assert has_element?(
             view,
             "#leashing-investituringment-ceremony",
             "Through This Appointmenting, This Constitutioning Human and This Stewardly Captain COB shall thereafter stand in lawful Stewardly Relationing through This One Situationing over Discrete Turns."
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
             "now stands choosing to appoint This One Stewardly Captain COB through This One Leashing"
           )

    assert has_element?(view, "#institutional-standing-voice", "Institutional Standing")
    assert has_element?(view, "#stewardly-guidance-voice", "Stewardly Guidance")

    assert has_element?(
             view,
             "#leashing-crew-conjunction",
             "This One Terrestrial Computer Leashinging Crew"
           )

    assert has_element?(
             view,
             ".constitutional-voice--stewardly_guidance",
             "This Constitutioning Human now stands lawfully accompanied by This One Stewardly Captain COB through This One Situationing."
           )

    assert has_element?(
             view,
             ".constitutional-voice--stewardly_guidance",
             "This One Terrestrial Computer Free Parkinging Stand Number together with This One Shackling Pin now stand furnished in Regard to Their continuing Stewardly Relationing upon future One Pieces of Time."
           )

    unfolded_html = render(view)

    ceremony_index =
      :binary.match(unfolded_html, ~s(id="leashing-investituringment-ceremony")) |> elem(0)

    reception_index =
      :binary.match(unfolded_html, ~s(id="zeroeth-mattering-reception")) |> elem(0)

    recital_index = :binary.match(unfolded_html, "The Readyingmenting Recital") |> elem(0)
    narration_index = :binary.match(unfolded_html, ~s(id="appliance-narration-voice")) |> elem(0)

    standing_index =
      :binary.match(unfolded_html, ~s(id="institutional-standing-voice")) |> elem(0)

    guidance_index = :binary.match(unfolded_html, ~s(id="stewardly-guidance-voice")) |> elem(0)
    crew_index = :binary.match(unfolded_html, ~s(id="leashing-crew-conjunction")) |> elem(0)
    ladder_index = :binary.match(unfolded_html, ~s(id="dual-stewardship-geometry")) |> elem(0)

    assert ceremony_index < reception_index
    assert reception_index < recital_index
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

    assert has_element?(view, "#parkinging-credentials-utility:not([open]) > summary", "Utility")

    assert has_element?(
             view,
             "#parkinging-credentials-utility",
             "This One Terrestrial Computer Free Parkinging Stand Number need not be kept secret."
           )

    assert has_element?(
             view,
             "#parkinging-credentials-utility",
             "This One Shackling Pin should be preserved in a Secret Some Place."
           )

    refute has_element?(
             view,
             ".field-page__completion-statement",
             "need not be kept secret"
           )

    assert has_element?(
             view,
             ~s|#parkinging-credentials[phx-hook="PublicSituationMachineTurnZeroWeb.CoreComponents.CopyFurnishing"]|
           )

    assert has_element?(
             view,
             "#completed-turn-zero-sittinging-in-room[data-constitutional-standing=enriched]"
           )

    assert has_element?(
             view,
             "#completed-turn-zero-sittinging-in-room-title",
             "The Sittinging-In Room"
           )

    assert has_element?(view, "#completed-turn-zero-sittinging-in-room #leashing-naming")

    refute has_element?(
             view,
             "#completed-turn-zero-sittinging-in-room #station-00-stewardly-guidance"
           )

    assert has_element?(
             view,
             "#completed-turn-zero-sittinging-in-room",
             "The Zeroeth Constitutional Locality of This One Tuple Ship"
           )

    refute has_element?(
             view,
             "#completed-turn-zero-sittinging-in-room",
             "The Turn-Zeroeth Constitutional Locality of This One Tuple Ship"
           )

    assert has_element?(view, ".field-page__completion-statement.field-page__standinging-marker")

    assert has_element?(view, "#station-00-rail-wayfinding", "Encounteringmentablement")
    assert has_element?(view, "#station-00-rail-wayfinding", "Distinguishingmenting")
    assert has_element?(view, "#station-00-rail-wayfinding dt:first-of-type", "Continuing From")
    assert has_element?(view, "#station-00-rail-wayfinding dt:last-of-type", "Continuing Toward")

    assert has_element?(
             view,
             "#station-00-stewardly-guidance",
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
      :binary.match(enriched_room_html, "station-00-stewardly-guidance")

    {landing_index, _} = :binary.match(enriched_room_html, "field-page__leashing-landing-heading")
    {stand_index, _} = :binary.match(enriched_room_html, ~s|id="parkinging-stand"|)
    assert enriched_room_index < enriched_tuple_index
    assert enriched_tuple_index < enriched_shelves_index
    assert enriched_shelves_index < enriched_time_index
    assert enriched_time_index < landing_index
    assert landing_index < stand_index
    assert stand_index < enriched_guidance_index

    assert has_element?(view, "#station-00-secret-cabinet:not([open])", "This One Secret Cabinet")

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
             "The Zeroeth Affordmenting"
           )

    assert has_element?(
             view,
             "#parkinging-credentials-instrumentation > ol > li:first-child [aria-label='YT']",
             "The Zeroeth Stewardly Furnishingment"
           )

    assert has_element?(
             view,
             "#parkinging-credentials-instrumentation > ol > li:first-child [aria-label='YT']",
             "This Stewardly Captain COB"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__captain-shelves > ol > li:first-child [aria-label='XT']",
             "The Zeroeth Appointmenting"
           )

    assert has_element?(
             view,
             "#parkinging-credentials > .field-page__captain-shelves > ol > li:first-child [aria-label='YT']",
             "This One Spoolinging Ratchetingable Unicycle with a Single Pedal Revolvinging about its Central Axis"
           )

    for {ordinal, index} <- Enum.with_index(~w(First Second Third Fourth Fifth Sixth), 2) do
      assert has_element?(
               view,
               "#parkinging-credentials-instrumentation > ol > li:nth-child(#{index}) [aria-label='XT']",
               "The #{ordinal} Affordmenting"
             )

      assert has_element?(
               view,
               "#parkinging-credentials > .field-page__captain-shelves > ol > li:nth-child(#{index}) [aria-label='XT']",
               "The #{ordinal} Appointmenting"
             )

      refute has_element?(
               view,
               "#parkinging-credentials-instrumentation > ol > li:nth-child(#{index}) [aria-label='YT'] strong"
             )

      refute has_element?(
               view,
               "#parkinging-credentials > .field-page__captain-shelves > ol > li:nth-child(#{index}) [aria-label='YT'] strong"
             )
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
             "#leashing-stewardly-standing.field-page__standinging-marker #tuple-ship-lawful-beginning-proclamation",
             "THIS ONE TUPLE SHIP NOW STANDS IN LAWFUL BEGINNING CONTINUINGMENTING."
           )

    assert has_element?(
             view,
             "#leashing-constitutional-declaration",
             "This Stewardly Captain COB's Situationing now stands named The Lantern Leashing."
           )

    assert has_element?(view, "#station-00-secret-cabinet:not([open])")

    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#hail-this-one-leashing")
    assert has_element?(view, "#station-01-opening")
    assert has_element?(view, "#station-01-opening", "Bearinging toward Embodyingmenting")
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

    assert has_element?(view, "#station-01-opening")
    assert has_element?(view, "#station-depot-01-marker", "This One Some Place")
    assert has_element?(view, "#station-depot-01-title", "STATION DEPOT 01")
    refute has_element?(view, "#station-depot-01-marker", "Lanterning")
    refute has_element?(view, "#station-01-opening", "Lanterning Appointmenting may now")
    refute has_element?(view, "#tuple-field-after-leashing-ceremony")

    unfold_station_01(view)
    refute has_element?(view, "#earthly-locality-form")

    assert has_element?(
             view,
             "#first-appointmenting-title.field-page__ceremony-title--station-01",
             "THE FIRST APPOINTMENTING CEREMONYING OF ENCOUNTERINGMENTABLEMENT"
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
             "#first-appointmenting-standing.field-page__standinging-marker",
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

    assert has_element?(
             view,
             "#station-01-turn-zero-surfacing",
             "TURN ZERO SURFACING"
           )

    assert has_element?(
             view,
             "#station-01-turn-zero-surfacing",
             "Nothing has yet been furnished."
           )

    assert has_element?(
             view,
             "#continue-without-earthly-locality",
             "Continue by Leaving This One Some Place Undistinguishingmented"
           )

    refute has_element?(view, "#continue-without-earthly-locality", "Without Furnishing")
    view |> element("#continue-without-earthly-locality") |> render_click()

    assert has_element?(
             view,
             "#station-01-enriched-leashing",
             "Visionizingmentablement"
           )

    assert has_element?(
             view,
             "#station-01-enriched-leashing",
             "This One Some Place presently stands left Undistinguishingmented."
           )

    assert has_element?(
             view,
             "#station-01-turn-zero-surfacing",
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
             "#station-01-completion",
             "current lawful Place of Encounteringmentablement"
           )

    assert has_element?(
             view,
             "#tuple-field-terminus-harbor",
             "Bearinging toward Continuingmenting"
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

    assert has_element?(view, "#station-01-enriched-leashing")
    assert has_element?(view, "#station-01-secret-cabinet:not([open])")

    assert has_element?(
             view,
             "#station-01-enriched-leashing-instrumentation > ol > li:first-child [aria-label='XT']",
             "The Zeroeth Affordmenting"
           )

    assert has_element?(
             view,
             "#station-01-enriched-leashing > .field-page__captain-shelves > ol > li:first-child [aria-label='YT']",
             "The Zeroeth Stewardly Furnishingment"
           )

    assert has_element?(view, ".field-page__refold-guidance", "Keep what is Holdinging.")
    assert has_element?(view, ".field-page__refold-guidance", "New Standing")

    view |> element("#re-fold-into-new-standing") |> render_click()

    assert has_element?(view, "#unfold-station-00")
    refute has_element?(view, "#unfold-constitutional-rail-line")
    refute has_element?(view, "#earthly-localities-station")
    refute has_element?(view, "#public-field-discoveringmenting-harbor")

    view |> element("#unfold-station-00") |> render_click()
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
    unfold_station_01(view)
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
             "#station-01-completion",
             "stands Visionizinging through Relationing"
           )

    assert has_element?(view, "#station-01-enriched-leashing", "Los Angeles")

    assert has_element?(
             view,
             "#station-01-enriched-leashing",
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
    view |> element("#unfold-station-00") |> render_click()
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

    assert has_element?(view, "#station-01-opening")
  end

  defp credential_value(view, id) do
    [_, value] = Regex.run(~r/data-value="([^"]+)"/, render(element(view, "##{id}")))
    value
  end

  defp inquire_and_unfold_station_01(view) do
    unfold_entrance(view)
    view |> element("#inquire-within") |> render_click()
    view |> element("#unfold-station-00") |> render_click()
    submit_zeroeth_inquiry(view)
  end

  defp submit_zeroeth_inquiry(view) do
    view
    |> form("#zeroeth-mattering-form",
      zeroeth_inquiry: %{mattering: "This Stewardly Captain COB"}
    )
    |> render_submit()
  end

  defp unfold_entrance(view) do
    view |> element("#enter-opening-passageway") |> render_click()
    view |> element("#unfold-turn-zero-sittinging-in-room") |> render_click()
    establish_turn_zero_for(view)
    view |> element("#unfold-existing-rail-line") |> render_click()
  end

  defp establish_turn_zero_for(view) do
    view |> element("#unfold-turn-zero-for-appointmenting") |> render_click()

    view
    |> form("#turn-zero-mattering-staging-form",
      turn_zero_mattering: %{mattering: "A lawful One Thing"}
    )
    |> render_change()

    view |> element("#refold-turn-zero-for-into-standinging") |> render_click()
  end

  defp unfold_station_01(view) do
    assert has_element?(view, "#station-01-opening")
    refute has_element?(view, "#earthly-localities-station")

    assert has_element?(
             view,
             "#unfold-station-01",
             "UN-FOLD from Here toward The Zeroeth Appointmenting"
           )

    view |> element("#unfold-station-01") |> render_click()

    assert has_element?(
             view,
             "#earthly-localities-station.field-page__station-interior--newly-unfolded"
           )
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
