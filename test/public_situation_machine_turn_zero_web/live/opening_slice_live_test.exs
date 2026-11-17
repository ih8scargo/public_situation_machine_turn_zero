defmodule PublicSituationMachineTurnZeroWeb.OpeningSliceLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "reservation hides the expanded R, resolution restores the same identity, and actual standing stays unchanged",
       %{conn: conn} do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)
    assert has_element?(v, "#opening-slice-projection")
    v |> element("#slice-appoint") |> render_click()
    assert has_element?(v, "#rtb-source-projection-opening-slice")
    refute has_element?(v, "#rtb-source-doorway-letter-R")
    v |> element("#slice-resolve") |> render_click()
    assert has_element?(v, "#rtb-notice")
    v |> element("#slice-open") |> render_click()

    v
    |> element("#slice-settings")
    |> render_change(%{
      "_target" => ["toy", "slice_progress"],
      "toy" => %{"slice_progress" => "1"}
    })

    v |> element("#slice-resolve") |> render_click()
    assert has_element?(v, "#room-toy-box[data-slice-phase='review'][data-acquired-delta='0']")
    assert has_element?(v, "#rtb-source-doorway-letter-R[data-source-id='doorway:letter-R']")

    assert has_element?(
             v,
             "#resolved-letter-toe[data-source-id='specimen:R:1/leading-toe/end-cap']"
           )

    for id <- ~w(real-tc pretend-tc), do: assert(has_element?(v, "#rtb-source-doorway-#{id}"))
    v |> element("#slice-ports") |> render_click()
    refute has_element?(v, "#rtb-source-projection-compact-opening")
    v |> element("#slice-compact") |> render_click()
    assert has_element?(v, "#resolved-letter-toe")
    {:ok, after_read} = Store.fetch(record.id)
    assert before == after_read
  end
end
