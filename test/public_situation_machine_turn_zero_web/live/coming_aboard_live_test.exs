defmodule PublicSituationMachineTurnZeroWeb.ComingAboardLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "starts at ZERO and steps through separate Ground and YT witnesses, then backs up", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/workshop/engineering-quarry/coming-aboard-rehearsal")
    assert has_element?(view, "#ca-standing-zero", "ordinary Terrestrial Computer")
    assert has_element?(view, "#ca-back[disabled]")
    refute has_element?(view, "#ca-standing-pittoning")
    click(view, "#ca-provenance")
    refute has_element?(view, "#ca-provenance-reading[data-material]")

    # Skip requests and duplicate clicks cannot advance the rehearsal.
    render_click(view, "furnish", %{"from" => "4"})
    assert has_element?(view, "#coming-aboard[data-step='0']")
    click(view, "#ca-furnish")
    render_click(view, "furnish", %{"from" => "0"})
    assert has_element?(view, "#coming-aboard[data-step='1']")
    assert has_element?(view, "#ca-standing-pittoning", "fixed NEXT")
    refute has_element?(view, "#ca-standing-six")

    click(view, "#ca-furnish")
    assert has_element?(view, "#ca-standing-six", "COB progress")
    click(view, "#ca-furnish")
    assert has_element?(view, "#ca-provenance-reading[data-material='coming-aboard-sample']")
    refute has_element?(view, "#ca-ground-passage")

    click(view, "#ca-furnish")
    assert has_element?(view, "#ca-ground-passage[data-material='coming-aboard-sample']")
    refute has_element?(view, "#ca-yt-issuance")

    click(view, "#ca-furnish")
    assert has_element?(view, "#ca-yt-issuance", "from the post")
    assert has_element?(view, "#ca-ground-passage[data-material='coming-aboard-sample']")
    assert has_element?(view, "#ca-stop", "RE-STEP remain pending")
    assert has_element?(view, "#ca-furnish[disabled]")
    render_click(view, "furnish", %{"from" => "5"})
    assert has_element?(view, "#coming-aboard[data-step='5']")

    click(view, "#ca-back")
    refute has_element?(view, "#ca-yt-issuance")
    assert has_element?(view, "#ca-ground-passage[data-material='coming-aboard-sample']")
    click(view, "#ca-back")
    refute has_element?(view, "#ca-ground-passage")
    assert has_element?(view, "#ca-provenance-reading[data-material='coming-aboard-sample']")
  end

  test "both office views share one standing and each wall retains XT and YT", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(view, "#sw-flat-material")

    {:ok, view, _html} =
      view
      |> click("a[href='/workshop/coming-aboard']")
      |> follow_redirect(conn, ~p"/workshop/coming-aboard")

    {:ok, view, _html} =
      view
      |> click("a[href='/workshop/engineering-quarry']")
      |> follow_redirect(conn, ~p"/workshop/engineering-quarry")

    {:ok, view, _html} =
      view
      |> click("a[href='/workshop/engineering-quarry/coming-aboard-rehearsal']")
      |> follow_redirect(conn, ~p"/workshop/engineering-quarry/coming-aboard-rehearsal")

    assert has_element?(view, "#ca-screen-0[data-office='Furnishing Traversaling']")
    click(view, "#ca-office-1")
    assert has_element?(view, "#ca-screen-0[data-office='Traversaling Furnishing']")
    assert has_element?(view, "#ca-wall-0 [data-bearing='XT']", "THIS HERE")
    assert has_element?(view, "#ca-wall-0 [data-bearing='YT']", "THIS NEXT")

    click(view, "#ca-paired")
    assert has_element?(view, "#ca-screen-0[data-office='Furnishing Traversaling']")
    assert has_element?(view, "#ca-screen-1[data-office='Traversaling Furnishing']")
    click(view, "#ca-membrane-1")
    assert has_element?(view, "#ca-membrane-0[aria-pressed='true']")
    assert has_element?(view, "#ca-crossing-reading", "XT and YT")
    assert has_element?(view, "#coming-aboard[data-step='0']")

    click(view, "#ca-furnish")

    for screen <- 0..1 do
      assert has_element?(view, "#ca-screen-#{screen}[data-step='1']")
      assert has_element?(view, "#ca-wall-#{screen} [data-bearing='XT']", "THIS HERE")
      assert has_element?(view, "#ca-wall-#{screen} [data-bearing='YT']", "THIS NEXT")
    end

    assert has_element?(view, "#ca-crossing-reading", "XT TO XT")
    click(view, "#ca-registration")
    assert has_element?(view, "#ca-registration-reading", "UN-FOLDING transform")
    click(view, "#ca-single")

    assert has_element?(
             view,
             "#ca-screen-0[data-step='1'][data-office='Traversaling Furnishing']"
           )

    refute has_element?(view, "#ca-screen-1")
  end

  defp click(view, selector), do: view |> element(selector) |> render_click()
end
