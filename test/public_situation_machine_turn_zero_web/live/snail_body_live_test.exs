defmodule PublicSituationMachineTurnZeroWeb.SnailBodyLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop.SnailBody, as: B

  test "body Regarding is independent, Human Quilling persists, return and measured gathering ready without changing Gallery standing",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(v, "#sb-take:not([disabled])")
    v |> element("#wgr-export") |> render_click()
    assert_push_event(v, "wedging-export", %{json: gallery})
    v |> element("#sb-take") |> render_click()
    v |> element("#sb-withdraw") |> render_click()
    v |> element("#sb-withdraw") |> render_click()
    v |> form("#sb-quill-form", quill: %{text: "Bill's retained line"}) |> render_submit()
    assert has_element?(v, "#sb-flat-monitor p", "Bill's retained line")
    v |> element("#sb-export") |> render_click()
    assert_push_event(v, "snail-body-export", %{json: held})

    for mode <- ~w(section plan within reverse external),
        do: v |> element("#sb-view-#{mode}") |> render_click()

    v |> form("#sb-fold-form", body: %{fold: "0", quarter: "3"}) |> render_change()
    assert has_element?(v, "#sb-fold-status[data-degrees='0']")
    v |> element("#sb-instrument-visibility") |> render_click()
    v |> element("#sb-export") |> render_click()
    assert_push_event(v, "snail-body-export", %{json: ^held})
    v |> element("#sb-return") |> render_click()
    assert has_element?(v, "#sb-needle-status[data-condition='gathering']")
    assert has_element?(v, "#sb-take[disabled]")
    v |> element("#sb-gather") |> render_click()
    assert has_element?(v, "#sb-line-status[data-outstanding='500'][data-gathered='500']")
    v |> element("#sb-gather-all") |> render_click()
    assert has_element?(v, "#sb-ready[data-ready='true']")
    assert has_element?(v, "#sb-flat-monitor p", "Bill's retained line")
    v |> element("#sb-export") |> render_click()
    assert_push_event(v, "snail-body-export", %{json: saved})
    assert {:ok, s} = B.import(saved)
    assert s["outstanding"] == 0
    v |> form("#sb-restore-form", body_witness: %{json: held}) |> render_submit()
    assert has_element?(v, "#sb-needle-status[data-condition='held']")
    v |> element("#wgr-export") |> render_click()
    assert_push_event(v, "wedging-export", %{json: ^gallery})
  end
end
