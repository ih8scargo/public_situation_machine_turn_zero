defmodule PublicSituationMachineTurnZeroWeb.CalibrationLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.Calibration, as: C

  defp submit(view, values) do
    view |> element("#gw-calibration-form") |> render_submit(%{"calibration" => values})
  end

  test "furnishing is explicit, calibrated views do not change records, LOCK freezes parameters, extension restores",
       %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/workshop")
    assert has_element?(view, "#gw-furnish-calibration")
    view |> element("#gw-furnish-calibration") |> render_click()
    assert has_element?(view, "#gw-calibration-controls[data-revision='0']")

    submit(
      view,
      Map.merge(C.defaults(), %{
        "revision" => "0",
        "quarter_turn" => "90",
        "opening" => "45",
        "wishbone" => "-20",
        "radius" => "1.5",
        "u_width" => "2.4",
        "u_height" => "2.4"
      })
    )

    assert has_element?(view, "#gw-calibration-controls[data-revision='1']")

    for id <-
          ~w(u-aperture bobbining-enclosure flat-monitor camera-one camera-two projection-thing SIX-upstage) do
      view |> element("#gw-inspect-#{id}") |> render_click()
      assert has_element?(view, "#gw-inspect-#{id}[aria-pressed=true]")
    end

    for id <- ~w(tunneling diorama reciprocal) do
      view |> element("#gw-view-#{id}") |> render_click()
      assert has_element?(view, "#gw-renderer[data-regard=#{id}]")
    end

    view |> element("#gw-quick-collect") |> render_click()
    view |> element("#gw-lock") |> render_click()
    assert has_element?(view, "#gw-apply-calibration[disabled]")
    view |> element("#gw-export") |> render_click()
    assert_push_event(view, "workshop-export", %{json: json})
    assert {:ok, m, spec} = W.import(json)
    assert m["rehearsal"]["collected"] == [13]
    assert spec["calibration_v1"]["parameters"]["quarter_turn"] == 90
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => json}})
    assert has_element?(view, "#gw-calibration-controls[data-revision='1']")
    assert has_element?(view, "#gw-footing-1")
    old = W.export(m, "front")
    view |> element("#gw-import-form") |> render_submit(%{"witness" => %{"json" => old}})
    refute has_element?(view, "#gw-calibration-controls")
    assert has_element?(view, "#gw-furnish-calibration[disabled]")
  end
end
