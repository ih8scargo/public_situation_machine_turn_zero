defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  test "unfolds horizontally paired stewardships into the Crew", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, ".field-page__station-header--opening", "STATION 01")
    assert has_element?(view, "#unfold-constitutional-rail-line", "Unfold")
    refute has_element?(view, "#terrestrial-computer-parkinging-station")

    view |> element("#unfold-constitutional-rail-line") |> render_click()

    assert has_element?(view, "#dual-stewardship-geometry")
    assert has_element?(view, "#stewardship-rail-split")
    assert has_element?(view, ".field-page__stewardship-pair:nth-child(5)")
    assert has_element?(view, "#dual-stewardship-geometry", "House of Shackling Pin Furnishings")
    assert has_element?(view, "#stewardship-crew-convergence")
    refute has_element?(view, ".field-page__stewardship-correspondence")

    assert has_element?(
             view,
             "#leashing-crew-conjunction",
             "This One Crew stands inhabitationing Their Combined Laboringings through These Interrelationing Officerly Stewardships."
           )

    assert has_element?(view, "#appliance-narration-voice", "Appliance Narration")
    assert has_element?(view, "#institutional-action-voice", "Institutional Action")
    assert has_element?(view, "#crew-voice", "Crew Voice")
  end

  test "persists a furnished Name and practices lawful return", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#unfold-constitutional-rail-line") |> render_click()
    view |> element("#take-holdinging-of-leashing") |> render_click()

    parkinging_stand = credential_value(view, "parkinging-stand")
    shackling_pin = credential_value(view, "shackling-pin")

    view |> element("#begin-furnishing-leashing-name") |> render_click()

    view
    |> form("#leashing-name-form", leashing: %{name: "The Harboring Leashing"})
    |> render_submit()

    assert has_element?(view, "#pet-name-continuity-line", "The Harboring Leashing")
    view |> element("#begin-refurbishing-pet-name") |> render_click()

    view
    |> form("#refurbish-pet-name-form", leashing: %{name: "The Lantern Leashing"})
    |> render_submit()

    assert has_element?(view, "#pet-name-continuity-line li:first-child", "The Lantern Leashing")

    assert has_element?(
             view,
             "#pet-name-continuity-line li:nth-child(2)",
             "The Harboring Leashing"
           )

    assert has_element?(view, "#re-shackling-practice-station")
    refute has_element?(view, "#self-correspondencing-crew")

    view
    |> form("#re-shackling-form",
      re_shackling: %{parkinging_stand: parkinging_stand, shackling_pin: shackling_pin}
    )
    |> render_submit()

    assert has_element?(view, "#re-shackling-success", "The Lantern Leashing")
    assert has_element?(view, "#re-shackling-success", "This One Leashing continues standing")
    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#hail-this-one-leashing")
    assert has_element?(view, "#station-02-opening")
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

    assert correspondence =~
             "Self-Correspondencingment Dispatched from\nThe PUBLIC-SITUATION-MACHINE-"

    assert correspondence =~ "This One Terrestrial Computer Parkinging Stand Number:"
    assert correspondence =~ "This One Shackling Pin:"
    assert correspondence =~ "This One Piece of Time"
    assert correspondence =~ "This One Pet Name:\nThe Lantern Leashing"
    assert correspondence =~ "not kept through an account"
  end

  test "continues without naming or RE-Shackling as equal choices", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#unfold-constitutional-rail-line") |> render_click()
    view |> element("#take-holdinging-of-leashing") |> render_click()
    view |> element("#continue-without-leashing-name") |> render_click()

    assert has_element?(view, "#re-shackling-practice-station")
    view |> element("#continue-beyond-re-shackling") |> render_click()

    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#station-02-opening")
    refute has_element?(view, "#tuple-field-after-leashing-ceremony")

    unfold_station_02(view)
    view |> element("#continue-without-earthly-locality") |> render_click()
    furnish_proto_appointmentings(view)

    assert has_element?(view, "#tuple-field-after-leashing-ceremony")
    assert has_element?(view, "#rail-line-extension-readiness", "Future Stations")
    assert has_element?(view, "#tuple-field-terminus-harbor")
  end

  test "furnishes and persists This One Place", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#unfold-constitutional-rail-line") |> render_click()
    view |> element("#take-holdinging-of-leashing") |> render_click()

    parkinging_stand = credential_value(view, "parkinging-stand")
    shackling_pin = credential_value(view, "shackling-pin")

    view |> element("#continue-without-leashing-name") |> render_click()
    view |> element("#continue-beyond-re-shackling") |> render_click()
    unfold_station_02(view)

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
      locality: %{country: "US", region: "CA", city: "Los Angeles"}
    )
    |> render_submit()

    furnish_proto_appointmentings(view)

    assert has_element?(view, "#station-02-completion", "lawful Placement upon The Earth")
    assert has_element?(view, "#tuple-field-after-leashing-ceremony")

    assert {:ok, %{earthly_locality: locality}} =
             ParkingingStandRegistry.re_shackle(parkinging_stand, shackling_pin)

    assert locality == %{country: "United States", region: "California", city: "Los Angeles"}
  end

  defp credential_value(view, id) do
    [_, value] = Regex.run(~r/data-value="([^"]+)"/, render(element(view, "##{id}")))
    value
  end

  defp unfold_station_02(view) do
    assert has_element?(view, "#station-02-opening")
    refute has_element?(view, "#earthly-localities-station")
    view |> element("#unfold-station-02") |> render_click()
    assert has_element?(view, "#earthly-localities-station")
  end

  defp furnish_proto_appointmentings(view) do
    view
    |> element(~s|#lanterning-appointmenting button[phx-value-appointmenting="lanterning"]|)
    |> render_click()

    refute has_element?(
             view,
             ~s|#lanterning-appointmenting button[phx-value-appointmenting="lanterning"]|
           )

    view
    |> element(~s|#sounding-bell-appointmenting button[phx-value-appointmenting="sounding_bell"]|)
    |> render_click()
  end
end
