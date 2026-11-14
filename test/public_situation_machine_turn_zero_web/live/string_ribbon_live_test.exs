defmodule PublicSituationMachineTurnZeroWeb.StringRibbonLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest

  test "two office squares provide and take one material with reversible inspection", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, ~p"/workshop/string-ribbon")
    assert has_element?(view, "#sr-square-0")
    assert has_element?(view, "#sr-square-1")
    assert has_element?(view, "#sr-take[disabled]")
    view |> element("#sr-register") |> render_click()
    view |> form("#sr-furnish-form", ribbon: %{text: "FROM HERE"}) |> render_submit()
    assert has_element?(view, "#sr-object-0-material[data-material]")
    refute has_element?(view, "#sr-object-1-material")
    view |> element("#sr-take") |> render_click()
    assert has_element?(view, "#sr-object-1-material[data-material]")

    for v <- ~w(top tunneling roundabout flat) do
      view
      |> form("#sr-inspection-form",
        inspection: %{view: v, course: "ribbon", progress: "100", fold: "0"}
      )
      |> render_change()

      assert has_element?(view, "#string-ribbon-workshop[data-view=#{v}][data-acquired=false]")
      assert has_element?(view, "#sr-material-ledger[data-footings='0']")
      assert has_element?(view, "#sr-object-1-material[data-material]")
    end

    view |> element("#sr-advance") |> render_click()
    view |> element("#sr-advance") |> render_click()
    assert has_element?(view, "#sr-advance[disabled]")
    render_click(view, "complete", %{})
    assert has_element?(view, "#sr-material-ledger[data-footings='0']")

    for course <- ~w(square-lock rising pocketing triangles) do
      view
      |> form("#sr-inspection-form",
        inspection: %{view: "top", course: course, progress: "100", fold: "100"}
      )
      |> render_change()

      assert has_element?(view, "#string-ribbon-workshop[data-course=#{course}]")
    end

    view |> element("#sr-inscription-table") |> render_click()
    assert has_element?(view, "#sr-inspected")
  end
end
