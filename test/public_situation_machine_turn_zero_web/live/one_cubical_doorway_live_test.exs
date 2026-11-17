defmodule PublicSituationMachineTurnZeroWeb.OneCubicalDoorwayLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "Human can furnish four ordered unit-letter passage rehearsals with zero acquired standing",
       %{conn: conn} do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)

    assert has_element?(
             v,
             "#room-toy-box[data-doorway-contract='one-cubical-doorway-2026-11-17.v13']"
           )

    for id <- ~w(cob real-tc pretend-tc receiving-side-port r-head-clamp),
        do: assert(has_element?(v, "#unit-ledger-doorway-" <> id))

    for n <- 1..4 do
      for action <- ~w(trace select place open),
          do: v |> element("#unit-" <> action) |> render_click()

      assert has_element?(v, "#room-toy-box[data-doorway-phase='open']")

      v
      |> element("#unit-passage-settings")
      |> render_change(%{
        "_target" => ["toy", "doorway_progress"],
        "toy" => %{"doorway_progress" => "1"}
      })

      assert has_element?(v, "#room-toy-box[data-doorway-phase='passed']")
      v |> element("#unit-needle") |> render_click()

      v
      |> element("#unit-passage-settings")
      |> render_change(%{
        "_target" => ["toy", "doorway_progress"],
        "toy" => %{"doorway_progress" => "1"}
      })

      assert has_element?(v, "#room-toy-box[data-doorway-index='#{n}']")
    end

    assert has_element?(v, "#unit-passage-status", "succession complete")
    assert has_element?(v, "#room-toy-box[data-acquired-delta='0']")
    {:ok, after_read} = Store.fetch(record.id)
    assert before == after_read
  end
end
