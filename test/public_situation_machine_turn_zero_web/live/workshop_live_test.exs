defmodule PublicSituationMachineTurnZeroWeb.WorkshopLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop

  test "workshop selection, movement, view independence, revision LOCK and release", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")
    assert has_element?(view, "#gw-scene")
    assert has_element?(view, "#gw-select-ch[aria-pressed=true]")
    assert has_element?(view, "#gw-coordinates")

    view
    |> element("#gw-carriage-form")
    |> render_submit(%{"carriage" => %{"id" => "ch", "position" => "7", "revision" => "0"}})

    assert has_element?(view, "#geometric-workshop[data-revision='1']")
    view |> element("#gw-view-reverse") |> render_click()
    assert has_element?(view, "#geometric-workshop[data-revision='1']")
    view |> element("#gw-lock") |> render_click()
    assert has_element?(view, "#gw-lock[disabled]")
    assert has_element?(view, "#gw-move[disabled]")
    render_click(view, "construct", %{"action" => "lock", "revision" => "1"})
    assert has_element?(view, "#gw-message", "Stale")
    view |> element("#gw-release") |> render_click()
    assert has_element?(view, "#gw-archive-count", "1 retained")
    view |> element("#gw-reset") |> render_click()
    assert has_element?(view, "#geometric-workshop[data-revision='4']")
    view |> element("#gw-select-lower") |> render_click()
    refute has_element?(view, "#gw-carriage-form")
  end

  test "export acknowledgement, import validation and upload round trip", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json, revision: 0})
    assert {:ok, model, %{"regarding" => "front", "yaw" => 0}} = Workshop.import(json)
    render_hook(view, "export-complete", %{"revision" => 0})
    assert has_element?(view, "#gw-dirty", "No unexported")
    {:ok, locked} = Workshop.operate(model, 0, :lock)
    json = Workshop.export(locked, "reverse")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#gw-lock[disabled]")
    assert has_element?(view, "#gw-view-reverse[aria-pressed=true]")
    assert has_element?(view, "#gw-witness-status", "Loaded")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => "{}"}})
    assert has_element?(view, "#gw-message", "Invalid witness")
    assert has_element?(view, "#gw-lock[disabled]")

    upload =
      file_input(view, "#gw-file-form", :witness, [
        %{name: "construction.json", content: json, type: "application/json"}
      ])

    render_upload(upload, "construction.json")
    view |> element("#gw-file-form") |> render_submit()
    assert has_element?(view, "#gw-dirty", "No unexported")
    assert has_element?(view, "#gw-view-reverse[aria-pressed=true]")
  end

  test "station inspection and yaw do not revise geometry; editable course and LOCK round trip",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")
    assert has_element?(view, "#gw-station-13", "13 U")
    assert has_element?(view, "#gw-station-18", "18 N")
    view |> element("#gw-station-18") |> render_click()
    assert has_element?(view, "#gw-station-18[aria-pressed=true]")
    view |> element("#gw-pivot-form") |> render_change(%{"inspection" => %{"yaw" => "57"}})
    view |> element("#gw-view-transverse") |> render_click()
    assert has_element?(view, "#geometric-workshop[data-revision='0']")

    view
    |> element("#gw-steeling-form")
    |> render_submit(%{
      "steeling" => %{
        "approach_bend" => "4.5",
        "n_heading" => "121",
        "machine_reach" => "7",
        "revision" => "0"
      }
    })

    assert has_element?(view, "#geometric-workshop[data-revision='1']")
    view |> element("#gw-lock") |> render_click()
    assert has_element?(view, "#gw-apply-steeling[disabled]")
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json})
    assert {:ok, model, %{"regarding" => "transverse", "yaw" => 57.0}} = Workshop.import(json)
    assert model["steeling"]["parameters"]["n_heading"] == 121
    assert model["steeling"]["u_return"]["point"] == [15, 3, 0]
    view |> element("#gw-release") |> render_click()
    view |> element("#gw-reset-steeling") |> render_click()
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: reset_json})
    assert {:ok, reset, _} = Workshop.import(reset_json)
    assert reset["steeling"]["parameters"] == Workshop.Steeling.defaults()
    assert reset["positions"] == model["positions"]
  end

  test "legacy import is read-only until explicit migration retaining the original witness", %{
    conn: conn
  } do
    old =
      File.read!(Path.expand("../../fixtures/workshop_milestone_one.json", __DIR__))
      |> Jason.decode!()

    {:ok, old} = Workshop.LegacyV1.operate(old, 0, :lock)
    json = Workshop.LegacyV1.export(old, "front")
    {:ok, view, _} = live(conn, ~p"/workshop")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#gw-legacy")
    assert has_element?(view, "#gw-move[disabled]")
    refute has_element?(view, "#gw-steeling-form")
    view |> element("#gw-migrate") |> render_click()
    refute has_element?(view, "#gw-legacy")
    assert has_element?(view, "#gw-steeling-form")
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: new_json})
    assert {:ok, migrated, _} = Workshop.import(new_json)
    assert migrated["legacy_source"]["construction"] == old
    assert migrated["positions"] == %{"tc" => 0, "ch" => 6}
  end

  test "existing public and experiment routes still render", %{conn: conn} do
    for route <- [
          "/",
          "/our-canonical-tuple",
          "/the-appliance",
          "/this-tuple-ship-field",
          "/constitutioning-bearingings",
          "/correspondencingments",
          "/experiments/architecture",
          "/experiments/motor",
          "/experiments/instrumentation",
          "/experiments/refolding"
        ] do
      response = get(conn, route)

      if route == "/experiments/refolding" do
        assert response.status == 302
        assert redirected_to(response) =~ "/experiments/refolding?by="
        assert conn |> get(redirected_to(response)) |> html_response(200)
      else
        assert html_response(response, 200)
      end
    end
  end
end
