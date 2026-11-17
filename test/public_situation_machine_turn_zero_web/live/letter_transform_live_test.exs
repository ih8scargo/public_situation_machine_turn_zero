defmodule PublicSituationMachineTurnZeroWeb.LetterTransformLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "both source-addressed inspections and toe stay separate from PUFFING acceptance", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{record.id}")
    {:ok, before} = Store.fetch(record.id)
    v |> element("#letter-inspect") |> render_click()

    for {key, value} <- [
          {"letter_door", "90"},
          {"letter_bearing", "90"},
          {"letter_curvature", "0.5"}
        ] do
      v
      |> element("#letter-transform-settings")
      |> render_change(%{"_target" => ["toy", key], "toy" => %{key => value}})
    end

    assert has_element?(
             v,
             "#letter-transform-inspection[data-source-id='doorway:letter-R'][data-active='true']"
           )

    assert has_element?(v, "#same-letter-toe[data-source-id='specimen:R:1/leading-toe/end-cap']")
    v |> element("#letter-puffing-gate") |> render_click()
    assert has_element?(v, "#rtb-notice", "PUFFING is not bound")
    assert has_element?(v, "#room-toy-box[data-acquired-delta='0']")
    v |> element("#letter-inspection-close") |> render_click()
    refute has_element?(v, "#same-letter-toe")
    {:ok, after_read} = Store.fetch(record.id)
    assert before == after_read
  end
end
