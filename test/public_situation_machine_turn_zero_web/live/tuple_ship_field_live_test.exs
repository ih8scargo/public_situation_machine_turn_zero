defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "unfolds horizontally paired stewardships into the Crew", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#unfold-constitutional-rail-line", "Unfold")
    refute has_element?(view, "#terrestrial-computer-parkinging-station")

    view |> element("#unfold-constitutional-rail-line") |> render_click()

    assert has_element?(view, "#dual-stewardship-geometry")
    assert has_element?(view, ".field-page__stewardship-pair:nth-child(5)")
    assert has_element?(view, "#dual-stewardship-geometry", "House of Shackling Pin Furnishings")
    assert has_element?(view, "#stewardship-crew-convergence")
    refute has_element?(view, ".field-page__stewardship-correspondence")

    assert has_element?(
             view,
             "#leashing-crew-conjunction",
             "Terrestrial Computer Leashinging Crew"
           )
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

    assert has_element?(view, "#re-shackling-practice-station")
    refute has_element?(view, "#self-correspondencing-crew")

    view
    |> form("#re-shackling-form",
      re_shackling: %{parkinging_stand: parkinging_stand, shackling_pin: shackling_pin}
    )
    |> render_submit()

    assert has_element?(view, "#re-shackling-success", "The Harboring Leashing")
    assert has_element?(view, "#re-shackling-success", "This One Leashing continues standing")
    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#hail-this-one-leashing")
  end

  test "continues without naming or RE-Shackling as equal choices", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view |> element("#unfold-constitutional-rail-line") |> render_click()
    view |> element("#take-holdinging-of-leashing") |> render_click()
    view |> element("#continue-without-leashing-name") |> render_click()

    assert has_element?(view, "#re-shackling-practice-station")
    view |> element("#continue-beyond-re-shackling") |> render_click()

    assert has_element?(view, "#self-correspondencing-crew")
    assert has_element?(view, "#tuple-field-after-leashing-ceremony")
  end

  defp credential_value(view, id) do
    [_, value] = Regex.run(~r/data-value="([^"]+)"/, render(element(view, "##{id}")))
    value
  end
end
