defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "reveals every placementing only through its preceding affordmenting", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#harbor-sign")
    refute has_element?(view, "#resonancing-snail-house-entrance")
    refute has_element?(view, "#sittinging-in-room")

    advance(view, "#enter-resonancing-snail-house")
    assert has_element?(view, "#resonancing-snail-house-entrance")
    refute has_element?(view, "#sittinging-in-room")

    advance(view, "#approach-sittinging-in-room")
    assert has_element?(view, "#sittinging-in-room")
    refute has_element?(view, "#division-of-constitutioning-humans")

    advance(view, "#un-fold-sittinging-in-room")
    assert has_element?(view, "#sittinging-in-room-unfolded")
    refute has_element?(view, "#division-of-constitutioning-humans")

    advance(view, "#continue-to-division")
    assert has_element?(view, "#division-of-constitutioning-humans")
    refute has_element?(view, "#stewardly-co-occupancyingship-investiturement")

    advance(view, "#continue-to-investiturement")
    assert has_element?(view, "#stewardly-co-occupancyingship-investiturement")
    refute has_element?(view, "#parkinging-standinging-landinging")

    advance(view, "#accept-stewardly-investiturement")
    assert has_element?(view, "#parkinging-standinging-landinging")
    refute has_element?(view, "#position-zero-traversaling-station")
  end

  test "RE-FOLD returns from the first constitutional locality to its entrance", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    advance(view, "#enter-resonancing-snail-house")
    advance(view, "#approach-sittinging-in-room")
    advance(view, "#un-fold-sittinging-in-room")
    advance(view, "#re-fold-sittinging-in-room")

    assert has_element?(view, "#resonancing-snail-house-entrance")
    assert has_element?(view, "#approach-sittinging-in-room")
    refute has_element?(view, "#sittinging-in-room")
  end

  test "furnishes Positions Zero through Two and stops at Across", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    advance_to_parking(view)
    advance(view, "#park-terrestrial-computer")

    assert has_element?(view, "#parkinging-furnishings")
    assert has_element?(view, "#parkinging-stand")
    assert has_element?(view, "#shackling-pin")

    assert has_element?(
             view,
             "#position-zero-traversaling-station",
             "Seat of Stewardly Co-Occupancyingship"
           )

    advance(view, "#complete-zeroeth-appointmenting")
    assert has_element?(view, "#position-one-traversaling-station", "Along")

    view
    |> form("#first-appointmenting-form",
      first_appointmenting: %{
        subject: "This One Watershed",
        situationing_kind: "Watershed Stewardship"
      }
    )
    |> render_submit()

    assert has_element?(view, "#first-appointmenting-inheritance", "This One Watershed")
    assert has_element?(view, "#first-appointmenting-inheritance", "Watershed Stewardship")
    assert has_element?(view, "#position-two-soundinging-bell-station", "Across")
    assert has_element?(view, "#projectioning-cross")
    assert has_element?(view, "#traversaling-shoe-before")
    assert has_element?(view, "#traversaling-shoe-here")
    assert has_element?(view, "#traversaling-shoe-next")
    refute has_element?(view, "#re-stepping-room")
    refute has_element?(view, "#observationing-mintinging-annex")
  end

  test "names later constitutional work only as explicit placeholders", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    advance_to_parking(view)
    advance(view, "#park-terrestrial-computer")
    advance(view, "#complete-zeroeth-appointmenting")

    view
    |> form("#first-appointmenting-form",
      first_appointmenting: %{subject: "This One Something", situationing_kind: "Learning"}
    )
    |> render_submit()

    for id <- [
          "re-stepping-room-placeholder",
          "observationing-mintinging-annex-placeholder",
          "refolding-localities-placeholder",
          "oscillationing-airiness-gauge-placeholder",
          "turn-index-navigation-placeholder",
          "correspondencing-placeholder",
          "later-appointmentings-placeholder"
        ] do
      assert has_element?(view, "##{id}", "subsequent build round")
    end
  end

  defp advance_to_parking(view) do
    advance(view, "#enter-resonancing-snail-house")
    advance(view, "#approach-sittinging-in-room")
    advance(view, "#un-fold-sittinging-in-room")
    advance(view, "#continue-to-division")
    advance(view, "#continue-to-investiturement")
    advance(view, "#accept-stewardly-investiturement")
  end

  defp advance(view, selector) do
    view |> element(selector) |> render_click()
  end
end
