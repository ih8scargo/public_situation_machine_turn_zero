defmodule PublicSituationMachineTurnZeroWeb.CommonMaterialLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  defp export(view) do
    view |> element("#sw-export") |> render_click()
    assert_push_event(view, "snail-weave-export", %{json: json})
    json
  end

  test "empty references and restored source stay separate from acquisition", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(view, "#common-material")
    assert has_element?(view, "#cm-source:not([data-material])")
    assert has_element?(view, "#cm-renderer[phx-update='ignore']")
    assert has_element?(view, "#cm-ledger")
    raw = File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json")
    view |> form("#sw-restore-form", weave_witness: %{json: raw}) |> render_submit()
    before = export(view)
    {:ok, source} = PublicSituationMachineTurnZero.Workshop.SnailWeave.import(before)
    id = List.last(source["turns"])["material"]
    assert has_element?(view, "#cm-source[data-material='#{id}']")

    for mode <- ~w(flat within section) do
      view |> element("#sw-view-#{mode}") |> render_click()
      assert has_element?(view, "#cm-source[data-material='#{id}']")
      assert export(view) == before
    end

    assert has_element?(view, "#cm-both[type='button']:not([phx-click])")
    assert has_element?(view, "#cm-tunneling[type='button']:not([phx-click])")
    assert has_element?(view, "#cm-flat[type='button']:not([phx-click])")
  end
end
