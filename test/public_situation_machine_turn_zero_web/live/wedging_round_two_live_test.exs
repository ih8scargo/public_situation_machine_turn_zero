defmodule PublicSituationMachineTurnZeroWeb.WedgingRoundTwoLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop.WedgingRehearsal, as: R

  test "bounded two-office sequence, independent inspection, two Footings and persistent PITTONING",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(v, "#wgr-appoint-traversaling[disabled]")
    v |> element("#wgr-appoint-furnishing") |> render_click()
    v |> element("#wg-bay-0") |> render_click()

    v
    |> element("#wgr-proposal-form")
    |> render_submit(%{
      "candidate" => %{
        "layout" => "same",
        "radius" => "0.04",
        "lift" => "0.9",
        "purpose" => "Author-held material"
      },
      "intent" => "propose"
    })

    assert has_element?(v, "#wgr-candidate-review")
    v |> element("#wgr-confirm") |> render_click()
    v |> element("#wgr-appoint-traversaling") |> render_click()
    v |> element("#wgr-export") |> render_click()
    assert_push_event(v, "wedging-export", %{json: json})
    assert {:ok, s} = R.import(json)
    id = hd(s["confirmed"])["id"]

    for course <- ~w(up_over ordinary) do
      v |> element("#wgr-enter-#{id}-#{course}") |> render_click()
      for _ <- 1..4, do: v |> element("#wgr-travel-step") |> render_click()
    end

    assert has_element?(v, "#wgr-footing-1")
    assert has_element?(v, "#wgr-footing-2")
    v |> element("#wgr-export") |> render_click()
    assert_push_event(v, "wedging-export", %{json: before})

    for mode <- ~w(within plan section external),
        do: v |> element("#wgr-view-#{mode}") |> render_click()

    v |> element("#wgr-show-founding") |> render_click()
    v |> element("#wgr-export") |> render_click()
    assert_push_event(v, "wedging-export", %{json: after_json})
    assert before == after_json
    v |> element("#wgr-import-form") |> render_submit(%{"witness" => %{"json" => before}})
    assert has_element?(v, "#wgr-footing-1")

    assert has_element?(
             v,
             "#wg-pillar-caption",
             "JANUSITE RIBBONATING SUBSTRATIONING INFRASTRUCTIONING"
           )
  end
end
