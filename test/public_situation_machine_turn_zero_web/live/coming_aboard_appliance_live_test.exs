defmodule PublicSituationMachineTurnZeroWeb.ComingAboardApplianceLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "accepted pull exposes the Groundward return and unlocks only the WITHIN-CAB inspection",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop/coming-aboard")

    assert has_element?(view, "#ca-quilling-order li:first-child[data-role=human-quilling]")
    assert has_element?(view, "#ca-quilling-order li:last-child[data-role=doll-stitching]")
    refute has_element?(view, "#ca-groundward-trace")
    refute has_element?(view, "#ca-cab-puff")

    view |> element("#ca-view-within-cab") |> render_click()
    assert has_element?(view, "#ca-cab-puff[disabled]")

    render_hook(view, "take-purchase", %{})
    assert_reply(view, %{accepted: true, token: cancelled})
    render_hook(view, "pull", %{token: cancelled})
    render_hook(view, "cancel-pull", %{token: cancelled})
    refute has_element?(view, "#ca-groundward-trace")
    render_click(view, "appliance:cab-puff", %{})
    refute has_element?(view, "#ca-cab-inspection")

    render_hook(view, "take-purchase", %{})
    assert_reply(view, %{accepted: true, token: token})
    render_hook(view, "pull", %{token: token})
    render_hook(view, "release-pull", %{token: token, measurements: %{dx: 20, dy: -15}})
    assert has_element?(view, "#ca-groundward-trace[data-attachment=registered][data-return]")
    assert has_element?(view, "#ca-groundward-trace .ca-groundward-return")
    assert has_element?(view, "#ca-groundward-qualification", "Standing String")

    render_click(view, "appliance:cab-select", %{})
    refute has_element?(view, "#ca-cab-inspection")
    view |> element("#ca-cab-puff") |> render_click()
    assert has_element?(view, "#ca-cab-inspection[data-inspection=regarding][data-wedge]")
    view |> element("#ca-cab-select") |> render_click()
    assert has_element?(view, "#ca-cab-inspection[data-inspection=selected]")
    assert has_element?(view, "#ca-inherited-standing[data-acquired=false]")
    assert has_element?(view, "#coming-aboard[data-pose=loosened][data-regarding=flat]")
    assert has_element?(view, "#ca-cob[data-confirmed=false]")
    refute has_element?(view, "[id^=ca-material-]")
  end

  test "playable appliance separates inquiry, staging and inherited approach across Regardings",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop/coming-aboard")
    assert has_element?(view, "#ca-square-0")
    assert has_element?(view, "#ca-square-1")
    assert has_element?(view, "#ca-cup-hook[disabled]")
    render_click(view, "appliance:hook", %{})
    assert has_element?(view, "#ca-telephone[data-line=hooked]")
    render_hook(view, "take-purchase", %{})
    assert_reply(view, %{token: token})
    render_hook(view, "pull", %{token: token})
    render_hook(view, "release-pull", %{token: token, measurements: %{dx: 50, dy: 1}})
    view |> element("#ca-cup-hook") |> render_click()
    view |> form("#ca-inquiry-form", inquiry: %{text: "Which material?"}) |> render_submit()
    assert has_element?(view, "#ca-console[data-speaking=true]")
    refute has_element?(view, "#ca-material-0")
    view |> element("#ca-door-3") |> render_click()
    view |> form("#ca-draft-form", draft: %{text: "Placeholder inscription"}) |> render_submit()
    assert has_element?(view, "#ca-material-3[data-pinned=false][data-acquired=false]")
    refute has_element?(view, "#ca-inherited-standing[data-material]")
    view |> element("#ca-approach") |> render_click()

    for id <-
          ~w(ca-view-dollside ca-gallery-roundabout ca-view-tunnel ca-view-flat ca-gallery-longhouse ca-door-7) do
      view |> element("##{id}") |> render_click()
      assert has_element?(view, "#ca-inherited-standing[data-material][data-acquired=false]")
      assert has_element?(view, "#ca-material-3[data-acquired=false]", "Placeholder inscription")
      assert has_element?(view, "#ca-appliance[data-illuminations='0']")
    end

    view |> element("#ca-cup-hook") |> render_click()
    assert has_element?(view, "#ca-console[data-speaking=false]")
    assert has_element?(view, "#ca-send-inquiry[disabled]")
  end
end
