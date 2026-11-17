defmodule PublicSituationMachineTurnZeroWeb.CubicalConstructionLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "principal frame rotates and inscriptions retain exact sources and zero acquisition", %{
    conn: conn
  } do
    {:ok, v, _} = live(conn, "/workshop/string-ribbon")
    assert has_element?(v, "#cubical-construction[data-facet='flat']")
    initial = attribute(v, "#cubical-construction", "data-source-hash")

    for facet <- ~w(tunneling reciprocal return flat) do
      v |> element("#cc-facet-#{facet}") |> render_click()
      assert has_element?(v, "#cubical-construction[data-facet='#{facet}'][data-index='0']")
      assert attribute(v, "#cubical-construction", "data-source-hash") == initial
    end

    v |> element("#cc-object-ground-approach") |> render_click()
    assert has_element?(v, "#cc-inscription[data-component='ground-approach']")

    v
    |> element("#cc-selection-form")
    |> render_change(%{"cubical" => %{"component" => "staging-window"}})

    assert has_element?(v, "#cc-inscription[data-component='staging-window']")
    v |> element("#cc-compare-FOUR") |> render_click()
    assert has_element?(v, "#cc-gauge-reading[data-candidate='gauge-4-x']")
    assert attribute(v, "#cubical-construction", "data-source-hash") == initial
    assert has_element?(v, "#janusite-inheritance")
    assert has_element?(v, "#here-wedging-study")
    assert has_element?(v, "#paired-motor")
  end

  test "stale and unsupported inspection cannot acquire or change frame", %{conn: conn} do
    {:ok, v, _} = live(conn, "/workshop/string-ribbon")
    v |> element("#cc-orbit-forward") |> render_click()
    initial = attribute(v, "#cubical-construction", "data-source-hash")

    render_click(v, "cubical-inspect", %{
      "kind" => "facet",
      "choice" => "return",
      "revision" => "0"
    })

    assert has_element?(v, "#cubical-construction[data-yaw='15'][data-facet='flat']")
    assert has_element?(v, "#cc-notice")
    render_click(v, "cubical-inspect", %{"kind" => "re_step", "revision" => "1"})
    assert attribute(v, "#cubical-construction", "data-source-hash") == initial
    assert has_element?(v, "#cc-landing-status", "next cursor: nil")
    assert has_element?(v, "#cubical-construction[data-index='0']")
  end

  defp attribute(v, selector, key),
    do:
      v
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(selector)
      |> LazyHTML.attribute(key)
end
