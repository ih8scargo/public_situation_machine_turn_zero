defmodule PublicSituationMachineTurnZeroWeb.AlongsideStagingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "explicit staging/furnishing remains unacquired and camera preserves world identity", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")

    assert has_element?(
             view,
             "#alongside-staging[data-furnished='0'][data-frame-acquired='false']"
           )

    initial = world(view, "alongside:inherited-reference")
    view |> element("#as-pivot-30") |> render_click()
    assert world(view, "alongside:inherited-reference") == initial
    view |> element("#as-appoint") |> render_click()
    view |> element("#as-stage") |> render_click()

    assert has_element?(
             view,
             "#as-view-flat g[data-status='newly_staged'][data-from-down-under='false']"
           )

    staged = world(view, "alongside:material-1")
    view |> element("#as-pivot-60") |> render_click()
    assert world(view, "alongside:material-1") == staged
    view |> element("#as-retain") |> render_click()
    view |> element("#as-appoint") |> render_click()
    view |> element("#as-stage") |> render_click()
    view |> element("#as-retain") |> render_click()

    assert has_element?(
             view,
             "#alongside-staging[data-furnished='2'][data-from-down-under='false']"
           )

    assert has_element?(view, "#as-deflection", "30.0")
    view |> element("#as-acquire") |> render_click()
    assert has_element?(view, "#as-notice", "human_frame_unacquired")
    view |> element("#as-scan") |> render_click()
    assert has_element?(view, "#as-notice", "landinging_not_acquired")
    assert has_element?(view, "#geometry-exploration[data-index='0']")
    assert has_element?(view, "#ge-diagonal-b-witness[data-next-status='not-furnished']")
  end

  test "the same opening and material source serve all three Regardings", %{conn: conn} do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")
    document = render(view) |> LazyHTML.from_fragment()

    for kind <- ~w(flat transverse plan) do
      assert has_element?(view, "#as-view-#{kind}")

      assert LazyHTML.query(document, "[id='as-#{kind}-alongside:inherited-reference']")
             |> LazyHTML.attribute("data-world") == world(view, "alongside:inherited-reference")
    end

    view |> element("#as-stage") |> render_click()
    assert has_element?(view, "#as-notice", "wedging_not_appointed")
    refute has_element?(view, "#as-view-flat g[data-status='newly_staged']")
  end

  defp world(view, id),
    do:
      view
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("[id='as-flat-#{id}']")
      |> LazyHTML.attribute("data-world")
end
