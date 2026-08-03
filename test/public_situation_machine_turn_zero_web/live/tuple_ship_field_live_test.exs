defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "assigns visit credentials without login credentials", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    assert has_element?(view, ~s|#parkinging-stand[data-value^="TCP-"]|)
    assert has_element?(view, ~s|#shackling-pin[data-digits="16"]|)
    refute has_element?(view, ~s|input[type="password"]|)
    refute has_element?(view, ~s|input[name="username"]|)
  end

  test "accepts optional recovery methods for the visit", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view
    |> form("#recovery-methods-form", recovery: %{email: "steward@example.test", phone: ""})
    |> render_submit()

    assert has_element?(view, "#recovery-methods-confirmation")
  end

  test "uses Place data for cascading optional locality controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/this-tuple-ship-field")

    view
    |> form("#embodied-locality-form", locality: %{country: "US"})
    |> render_change()

    assert has_element?(view, ~s|#locality_region option[value="CA"]|, "California")

    view
    |> form("#embodied-locality-form", locality: %{country: "US", region: "CA"})
    |> render_change()

    assert has_element?(view, ~s|#locality_city option[value="Los Angeles"]|, "Los Angeles")

    view
    |> form("#embodied-locality-form",
      locality: %{country: "US", region: "CA", city: "Los Angeles"}
    )
    |> render_submit()

    assert has_element?(view, "#embodied-locality-confirmation")
  end
end
