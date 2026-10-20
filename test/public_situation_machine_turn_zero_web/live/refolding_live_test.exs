defmodule PublicSituationMachineTurnZeroWeb.RefoldingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "one apparatus, explicit consequence, material and return after remount", %{conn: conn} do
    key = Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)
    path = ~p"/experiments/refolding?by=#{key}"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
    assert has_element?(view, "#caterpillar[data-standing=ENZO]")
    view |> element("#furnish-huckleberry") |> render_click()
    assert has_element?(view, "#caterpillar[data-standing=HUCKLEBERRY]")

    for id <- ["regard", "approach", "traverse"] do
      view |> element("##{id}") |> render_click()
      assert has_element?(view, "#standing-from[data-standing=ENZO]")
    end

    view |> element("#zipper") |> render_click()
    view |> element("#furnish-material") |> render_click()
    assert has_element?(view, "#standing-from[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#standing-material")
    view |> element("#furnish-enzo") |> render_click()
    view |> element("#traverse") |> render_click()
    assert has_element?(view, "#apparatus-posture[data-regarding=ENZO][data-segment='1']")
    view |> element("#refold") |> render_click()
    assert has_element?(view, "#folded")
    refute has_element?(view, "#caterpillar")
    view |> element("#return") |> render_click()
    assert_returned(view)
    GenServer.stop(view.pid)
    {:ok, remounted, _} = live(conn, path)
    assert_returned(remounted)
  end

  test "entry furnishes a reusable return URL", %{conn: conn} do
    {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/experiments/refolding")
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
  end

  defp assert_returned(view) do
    assert has_element?(view, "#standing-from[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#caterpillar[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#regarded-material")
    assert has_element?(view, "#apparatus-posture[data-regarding=HUCKLEBERRY][data-segment='0']")
  end
end
