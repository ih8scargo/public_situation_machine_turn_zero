defmodule PublicSituationMachineTurnZeroWeb.ArrivalExtentLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "arrival precedes the retained entrance without placing the carried TC", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, "#arrival-extent ~ #station-tz-region")
    assert has_element?(view, "#arrival-aperture #arrival-human-with-tc")
    assert has_element?(view, "#arrival-aperture circle#arrival-ground-point")

    assert has_element?(
             view,
             ~s|#arrival-aperture textPath[href="#arrival-inscription-circle"]|,
             "THIS ONE FOR HERE FROM OUT OF THE GROUND POINT"
           )

    assert has_element?(view, "#arrival-distance-prospect", "how far away would you place it?")
    refute has_element?(view, "#arrival-extent input")

    assert has_element?(
             view,
             ~s|#arrival-continue-to-existing-entrance[href="#station-tz-region"]|
           )

    view |> element("#enter-opening-passageway") |> render_click()
    assert has_element?(view, "#unfold-turn-zero-sittinging-in-room")
    assert has_element?(view, "#arrival-human-with-tc")
  end
end
