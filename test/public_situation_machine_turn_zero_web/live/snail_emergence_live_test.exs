defmodule PublicSituationMachineTurnZeroWeb.SnailEmergenceLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop.SnailWeave

  defp export(v) do
    v |> element("#sw-export") |> render_click()
    assert_push_event(v, "snail-weave-export", %{json: json})
    json
  end

  test "inspection controls preserve inherited acquisition and material; fresh reset is not RE-STEP",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    raw = File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json")
    v |> form("#sw-restore-form", weave_witness: %{json: raw}) |> render_submit()
    saved = export(v)
    assert {:ok, s} = SnailWeave.import(saved)
    assert length(s["footings"]) == 2
    assert has_element?(v, "#sw-emergence-form input[name='emergence[extent]']:not([max])")

    for mode <- ~w(contraption volume groundward),
        do: v |> element("#sw-view-#{mode}") |> render_click()

    v
    |> form("#sw-emergence-form",
      emergence: %{extent: "10000", quarter_turn: "0", candidate: "arrival"}
    )
    |> render_change()

    assert export(v) == saved
    v |> element("#sw-fresh") |> render_click()
    assert has_element?(v, "#sw-fresh-state[data-inherited='1'][data-extent='0.0']")
    assert export(v) == saved

    v
    |> form("#sw-emergence-form",
      emergence: %{extent: "-1", quarter_turn: "90", candidate: "through"}
    )
    |> render_change()

    assert export(v) == saved
  end

  test "ordinary monitor is initially empty and seated quarter turn remains inspection-only", %{
    conn: conn
  } do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(v, "#sw-renderer[data-view='flat']")
    assert has_element?(v, "#sw-flat-material:not([data-material])")
    assert has_element?(v, "#sw-cubical-comparison")
    before = export(v)
    v |> element("#sw-view-within") |> render_click()

    for angle <- [0, 45, 90] do
      v
      |> form("#sw-emergence-form",
        emergence: %{extent: "0", quarter_turn: to_string(angle), candidate: "through"}
      )
      |> render_change()

      assert has_element?(v, "#sw-renderer[data-view='within']")
      assert has_element?(v, "#sw-view-within[aria-pressed='true']")
      assert has_element?(v, "#emergence_quarter_turn[value='#{angle}']")
      assert export(v) == before
    end
  end
end
