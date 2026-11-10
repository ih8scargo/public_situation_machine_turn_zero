defmodule PublicSituationMachineTurnZeroWeb.GroundsideLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop, as: W

  test "original, preserved first experiment and lower-only corrected views are reversible presentation choices",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop")
    v |> element("#gw-export") |> render_click()
    assert_push_event(v, "workshop-export", %{json: before})

    for mode <- ~w(side tunnel groundside groundside-tunnel) do
      v |> element("#gw-draw-out-#{mode}") |> render_click()

      if mode in ~w(groundside groundside-tunnel) do
        assert has_element?(v, "#gw-groundside-scene[data-mode='#{mode}']")
        assert has_element?(v, "#gw-groundside-provisional", "unappointed")
        assert has_element?(v, "#gw-groundside-empty")
      else
        assert has_element?(v, "#gw-draw-out-scene")
      end
    end

    v |> element("#gw-draw-out-original") |> render_click()
    refute has_element?(v, "#gw-groundside-scene")
    refute has_element?(v, "#gw-draw-out-scene")
    v |> element("#gw-export") |> render_click()
    assert_push_event(v, "workshop-export", %{json: after_json})
    assert W.import(after_json) == W.import(before)
    assert has_element?(v, "#gw-view-diorama")
    assert has_element?(v, "#gw-seat-axis-diagram")
  end
end
