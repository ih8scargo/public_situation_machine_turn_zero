defmodule PublicSituationMachineTurnZeroWeb.ProjectionRehearsalLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop, as: W

  test "five-letter rehearsal, duplicate suppression, views, Footing inspection and explicit reset",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")
    assert has_element?(view, "#gw-readiness[data-ready=false]")
    assert has_element?(view, "#gw-companion", "Shall we collect")

    view
    |> element("#gw-progress-form")
    |> render_submit(%{"traversal" => %{"progress" => "0.4", "revision" => "0"}})

    for {index, sequence} <- Enum.with_index([13, 18, 1, 25, 4], 1) do
      view
      |> element("#gw-pick-form")
      |> render_change(%{"pick" => %{"index" => to_string(index)}})

      view |> element("#gw-quick-collect") |> render_click()
      assert has_element?(view, "#gw-footing-#{sequence}")
      assert has_element?(view, "#gw-readiness[data-ready=#{sequence == 5}]")

      if sequence == 1 do
        view |> element("#gw-quick-collect") |> render_click()
        refute has_element?(view, "#gw-footing-2")
      end
    end

    assert has_element?(view, "#gw-acquisition-order", "13 → 18 → 1 → 25 → 4")
    assert has_element?(view, "#gw-readiness", "READY TO STAND TOWARD RE-STEPPING")
    view |> element("#gw-station-2") |> render_click()
    assert has_element?(view, "#gw-collect[disabled]")
    view |> element("#gw-footing-3") |> render_click()
    view |> element("#gw-bearing-oblique") |> render_click()
    view |> element("#gw-view-reciprocal") |> render_click()
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json})
    assert {:ok, model, %{"bearing" => "oblique", "regarding" => "reciprocal"}} = W.import(json)
    assert model["rehearsal"]["progress"] == 0.4
    assert model["rehearsal"]["collected"] == [13, 18, 1, 25, 4]
    assert model["revision"] == 0
    assert model["turn"]["anchored_index"] == 0
    view |> element("#gw-reset-rehearsal") |> render_click()
    assert has_element?(view, "#gw-count", "0 / 5")
    refute has_element?(view, "#gw-footing-1")
    assert has_element?(view, "#geometric-workshop[data-revision='0']")
  end

  test "registered oblique candidate changes only its geometry and LOCK permits rehearsal without rewriting snapshots",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")

    view
    |> element("#gw-projection-form")
    |> render_submit(%{
      "projection" => %{"revision" => "0", "oblique_x" => "-0.5", "oblique_z" => "2"}
    })

    assert has_element?(view, "#geometric-workshop[data-revision='1']")
    view |> element("#gw-lock") |> render_click()
    assert has_element?(view, "#gw-apply-projection[disabled]")
    view |> element("#gw-quick-collect") |> render_click()
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json})
    assert {:ok, model, _} = W.import(json)
    assert model["rehearsal"]["collected"] == [13]
    assert model["projection"]["parameters"] == %{"oblique_x" => -0.5, "oblique_z" => 2.0}

    assert List.last(model["witnesses"])["snapshot"] ==
             Map.drop(model, ~w(lock witnesses legacy_source rehearsal))

    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#gw-lock[disabled]")
    assert has_element?(view, "#gw-footing-1", "U13")
  end

  test "schema-2 import replaces an active five-Footing rehearsal", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")

    for index <- [13, 18, 1, 25, 4] do
      view
      |> element("#gw-pick-form")
      |> render_change(%{"pick" => %{"index" => to_string(index)}})

      view |> element("#gw-quick-collect") |> render_click()
    end

    old =
      File.read!("test/fixtures/workshop_assignment_two.json")
      |> String.replace(~r/(\d+)\.0(?=[,\s])/, "\\1")
      |> Jason.decode!()

    json =
      Jason.encode!(%{
        schema_version: 2,
        construction: old,
        view: %{regarding: "transverse", yaw: 27}
      })

    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#gw-legacy")
    refute has_element?(view, "#gw-rehearsal")
    view |> element("#gw-migrate") |> render_click()
    assert has_element?(view, "#gw-rehearsal")
  end
end
