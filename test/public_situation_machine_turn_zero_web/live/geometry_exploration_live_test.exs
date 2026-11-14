defmodule PublicSituationMachineTurnZeroWeb.GeometryExplorationLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "current-turn measure and prospective overlay never furnish the next YT extent", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")

    assert has_element?(
             view,
             "#ge-diagonal-b-witness[data-status='current_turn_line_furnished'][data-next-status='not-furnished']"
           )

    refute has_element?(view, "#ge-scene-prospective-join")

    baseline =
      render(view)
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#ge-scene-current-turn-measure")
      |> LazyHTML.attribute("data-world")

    view |> element("#ge-continuation-overlay-toggle") |> render_click()

    assert has_element?(
             view,
             "#ge-scene-prospective-join[data-status='prospective-only'][data-material-points='[]'][data-acquired='false']"
           )

    assert has_element?(view, "#ge-prospective-join-note", "PROSPECTIVE ONLY")

    current =
      render(view)
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#ge-scene-current-turn-measure")
      |> LazyHTML.attribute("data-world")

    assert baseline == current
    assert has_element?(view, "#geometry-exploration[data-index='0'][data-coils='0']")
    view |> element("#ge-continuation-overlay-toggle") |> render_click()
    refute has_element?(view, "#ge-scene-prospective-join")
    assert has_element?(view, "#paired-motor-current-turn-qualification")
  end

  test "registration, blocked finite pair, shared views and real acquisition guards", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")
    assert has_element?(view, "#geometry-exploration[data-coils='0'][data-index='0']")
    assert has_element?(view, "#material-bench")
    assert has_element?(view, "#paired-motor")
    view |> element("#ge-furnish") |> render_click()

    assert has_element?(
             view,
             "#geometry-exploration[data-status='furnished_unacquired'][data-coils='0']"
           )

    view |> element("#ge-coil") |> render_click()
    original = world(view)
    assert length(original) == 1
    view |> element("#ge-coil") |> render_click()
    assert has_element?(view, "#ge-scene-coil-candidate-2")
    assert has_element?(view, "#geometry-exploration[data-coils='1']")
    assert has_element?(view, "#ge-notice", "BLOCKED pair")

    for v <- ~w(elevation plan transverse oblique half) do
      view |> element("#ge-view-#{v}") |> render_click()
      assert world(view) == original
    end

    assert has_element?(view, "#ge-half-scene-coil-candidate-1")
    view |> element("#ge-map-select-coil-candidate-1") |> render_click()
    assert world(view) == original
    view |> element("#ge-acquire") |> render_click()
    assert has_element?(view, "#ge-notice", "ground_connection")
    view |> element("#ge-traverse") |> render_click()
    assert has_element?(view, "#ge-notice", "unacquired_extent")
    view |> element("#ge-ceiling") |> render_click()
    assert has_element?(view, "#geometry-exploration[data-index='0']")

    for i <- 1..8 do
      view |> element("#ge-experiment-#{i}") |> render_click()
    end
  end

  test "condition fixture cannot grant actual acquired geometry", %{conn: conn} do
    {:ok, view, _} = live(conn, "/workshop/string-ribbon")
    view |> element("#ge-lab-button") |> render_click()
    assert has_element?(view, "#ge-eligibility[data-ready='false']")

    for action <- ~w(encounter receipt appoint presence exit restomp ready rezip next button) do
      view |> element("#ge-lab-#{action}") |> render_click()
    end

    assert has_element?(view, "#ge-eligibility[data-ready='true']")

    assert has_element?(
             view,
             "#geometry-exploration[data-status='unfurnished'][data-coils='0'][data-index='0']"
           )

    view |> element("#ge-traverse") |> render_click()
    assert has_element?(view, "#ge-notice", "unacquired_extent")
  end

  defp world(view),
    do:
      view
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#ge-scene-coil-candidate-1")
      |> LazyHTML.attribute("data-world")
end
