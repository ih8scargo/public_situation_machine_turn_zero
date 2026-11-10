defmodule PublicSituationMachineTurnZeroWeb.SnailWeaveLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Workshop.SnailWeave, as: W

  defp export(v) do
    v |> element("#sw-export") |> render_click()
    assert_push_event(v, "snail-weave-export", %{json: json})
    json
  end

  defp click(v, id), do: v |> element(id) |> render_click()

  test "ordinary labor, placement-limited folds, two woven actual turns and independent Regarding retain ancestry",
       %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/workshop/wedging-geometry")
    assert has_element?(v, "#sw-yt-standing[data-available='false']")
    initial = export(v)
    for mode <- ~w(ceiling plan flat within section), do: click(v, "#sw-view-#{mode}")
    refute has_element?(v, "#sw-view-external")
    click(v, "#sw-alongside")
    assert export(v) == initial
    assert has_element?(v, "#sw-human-cob-table")

    for angle <- [0, 90] do
      v
      |> form("#sw-emergence-form",
        emergence: %{extent: "0", quarter_turn: to_string(angle), candidate: "through"}
      )
      |> render_change()

      assert has_element?(v, "#sw-regarding-correspondence[data-angle='#{angle}']")
      assert has_element?(v, "#sw-yt-centerline")
      assert export(v) == initial
    end

    for id <- ~w(sw-pull sw-puff sw-brace sw-seat sw-appoint-xt sw-appoint-yt),
        do: click(v, "#" <> id)

    v
    |> form("#sw-quill-form", weave_quill: %{text: "Human authored, one material"})
    |> render_submit()

    assert has_element?(v, "#sw-yt-standing[data-available='true']")

    for i <- 1..2 do
      click(v, "#sw-provide")
      assert has_element?(v, "#sw-current-turn[data-status='furnishing']")
      click(v, "#sw-register")
      assert has_element?(v, "#sw-current-turn[data-status='emplacing']")
      before = export(v)
      click(v, "#sw-across")
      assert export(v) == before

      v
      |> form("#sw-inspection-form",
        weave_inspect: %{pose: "45", quarter: Integer.to_string(i - 1), look: "30", scrub: "1.0"}
      )
      |> render_change()

      assert export(v) == before
      click(v, "#sw-settle")
      click(v, "#sw-across")
      assert export(v) != initial
      assert {:ok, s} = W.import(export(v))
      t = List.last(s["turns"])

      v
      |> form("#sw-take-form",
        weave_take: %{
          turn: t["id"],
          mode: "actual",
          human: "This One Visiting Constitutioning Human"
        }
      )
      |> render_submit()

      assert has_element?(v, "#sw-transverse[data-held='true']")
      assert has_element?(v, "#sw-complete[disabled]")
      for _ <- 1..2, do: click(v, "#sw-advance")
      click(v, "#sw-complete")
      assert has_element?(v, "#sw-acquisitions[data-count='#{i}']")
      assert has_element?(v, "#sw-transverse[data-held='false']")
      held = export(v)
      click(v, "#sw-view-ceiling")
      click(v, "#sw-alongside")
      assert export(v) == held
    end

    click(v, "#sw-point")
    saved = export(v)
    assert {:ok, state} = W.import(saved)
    assert length(state["footings"]) == 2
    v |> form("#sw-restore-form", weave_witness: %{json: saved}) |> render_submit()
    assert export(v) == saved
    v |> form("#sw-restore-form", weave_witness: %{json: "{}"}) |> render_submit()
    assert export(v) == saved
  end
end
