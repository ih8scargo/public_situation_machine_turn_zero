defmodule PublicSituationMachineTurnZeroWeb.ComingAboardMachineLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "Human-first inscription, face correspondence and Needle relinquishment", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop/coming-aboard")
    assert has_element?(view, "#ca-common-machine[data-open=false]")
    refute has_element?(view, "#ca-registered-standing-string")
    render_hook(view, "take-purchase", %{})
    assert_reply(view, %{token: token})
    render_hook(view, "pull", %{token: token})
    render_hook(view, "release-pull", %{token: token, measurements: %{dx: 30, dy: -20}})
    assert has_element?(view, "#ca-registered-standing-string")
    view |> element("#ca-needle-take") |> render_click()
    view |> form("#ca-quill-form", quill: %{text: "HERE"}) |> render_submit()
    assert has_element?(view, "#ca-inscription-face[data-stitched=false] text")
    view |> element("#ca-machine-dollside") |> render_click()
    refute has_element?(view, "#ca-inscription-face text")
    view |> element("#ca-stitch") |> render_click()
    assert has_element?(view, "#ca-inscription-face[data-stitched=true] text")
    view |> element("#ca-machine-back") |> render_click()
    refute has_element?(view, "#ca-inscription-face text")
    view |> element("#ca-machine-flat") |> render_click()
    assert has_element?(view, "#ca-inscription-face text")
    view |> element("#ca-needle-return") |> render_click()
    assert has_element?(view, "#ca-inkwell[data-needle=inkwell]:not([data-held])")
    assert has_element?(view, "#ca-common-machine[data-material]")
    assert has_element?(view, "#ca-telephone[data-line=hooked]")
  end
end
