defmodule PublicSituationMachineTurnZeroWeb.SurfacingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop, as: W

  defp submit(v, text, revision, intent),
    do:
      v
      |> element("#sf-quill-form")
      |> render_submit(%{
        "quill" => %{"text" => text, "revision" => to_string(revision)},
        "intent" => intent
      })

  test "ordinary offices, both authored routes, revisions and persistence remain separate from architecture",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop")
    v |> element("#sf-open") |> render_click()
    assert has_element?(v, "#sf-consoling-stand")
    refute has_element?(v, "#sf-display svg")
    submit(v, "A Human marking", 0, "staging")
    assert has_element?(v, "#sf-material-1[data-route=staging]")
    refute has_element?(v, "#sf-inquiry-1")
    v |> element("#sf-revise-1") |> render_click()
    submit(v, "A Human inquiry", 3, "inquiry")
    assert has_element?(v, "#sf-material-2[data-route=inquiry]")
    assert has_element?(v, "#sf-inquiry-2")
    assert has_element?(v, "#sf-material-1", "A Human marking")
    v |> element("#sf-relation-consoling") |> render_click()
    assert has_element?(v, "#sf-relation-detail", "FROM_OUT_OF")
    v |> element("#gw-export") |> render_click()
    assert_push_event(v, "workshop-export", %{json: json})
    assert {:ok, m, view} = W.import(json)
    assert m["revision"] == 0
    assert m["rehearsal"]["collected"] == []
    assert view["surfacing_v1"]["records"] |> length() == 2
    v |> element("#sf-new-draft") |> render_click()
    v |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(v, "#sf-inquiry-2")
    assert has_element?(v, "#sf-material-1")

    v
    |> element("#gw-import-form")
    |> render_submit(%{"witness" => %{"json" => W.export(m, "front")}})

    refute has_element?(v, "#sf-display")
  end
end
