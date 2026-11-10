defmodule PublicSituationMachineTurnZeroWeb.SnailGalleryRegistrationLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  defp export(view) do
    view |> element("#sw-export") |> render_click()
    assert_push_event(view, "snail-weave-export", %{json: json})
    json
  end

  test "bounded registration controls preserve main view, acquired material and exact export", %{
    conn: conn
  } do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(v, "#sw-renderer[data-view='flat']")
    assert has_element?(v, "#sgr-material-empty")
    assert has_element?(v, "#sgr-unfolding")
    assert has_element?(v, "#sgr-cylinder-conflict")
    assert has_element?(v, "#sgr-footing-constraints")
    assert has_element?(v, "#sgr-proposed-table[data-diameter='3']")
    raw = File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json")
    v |> form("#sw-restore-form", weave_witness: %{json: raw}) |> render_submit()
    before = export(v)
    assert has_element?(v, "#sgr-material[data-material]")

    for mode <- ~w(independent co counter) do
      v
      |> form("#sgr-form",
        registration: %{radius: "1.2", orbit: "45", spin: "15", coupling: mode}
      )
      |> render_change()

      assert has_element?(v, "#sgr-pose[data-orbit='45.0']")
      assert has_element?(v, "#sw-acquisitions[data-count='2']")
      assert export(v) == before
    end

    v
    |> form("#sgr-form", registration: %{radius: "999", orbit: "0", spin: "0", coupling: "co"})
    |> render_change()

    assert has_element?(v, "#sgr-error")
    assert export(v) == before
    v |> element("#sgr-reset") |> render_click()
    assert has_element?(v, "#sgr-pose[data-orbit='0.0'][data-yaw='0.0']")
    assert has_element?(v, "#sw-renderer[data-view='flat']")
    assert export(v) == before
  end
end
