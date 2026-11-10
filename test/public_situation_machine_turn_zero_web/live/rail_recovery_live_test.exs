defmodule PublicSituationMachineTurnZeroWeb.RailRecoveryLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "repeatable paired inspection retains all letters and exposes unappointed fit", %{
    conn: conn
  } do
    {:ok, v, _} = live(conn, ~p"/workshop/rail-recovery")
    assert has_element?(v, "#rr-registration-warning")
    for i <- 1..25, do: assert(has_element?(v, "#rr-letter-#{i}"))

    for stand <- ~w(N-M-before N-M-within N-M-after table-plan axle), hand <- ["1", "-1"] do
      v |> form("#rr-inspection", inspection: %{stand: stand, hand: hand}) |> render_change()
      assert has_element?(v, "#rr-plan")
      assert has_element?(v, "#rr-section")
      assert has_element?(v, "#rr-located")
      assert has_element?(v, "#rr-standing[data-index='unchanged']")
      assert has_element?(v, "#rr-letter-18[data-source='inscription-letter-18']")
      assert has_element?(v, "#rr-letter-19[data-source='inscription-letter-19']")
      assert has_element?(v, "#rr-clearance")
    end
  end
end
