defmodule PublicSituationMachineTurnZeroWeb.RefoldingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "bodily labor precedes immediate consequence, folding and fresh return", %{conn: conn} do
    {view, path} = open(conn)
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
    assert has_element?(view, "#caterpillar[data-standing=ENZO]")
    assert has_element?(view, "#continuity-line [data-kind=from][data-standing=ENZO]")
    refute has_element?(view, "#furnish-huckleberry")
    refute has_element?(view, "#rezipper")

    view |> element("#regard-huckleberry") |> render_click()
    assert has_element?(view, "#regarding[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#regarded-material", "THIS ONE LEASHING")
    refute has_element?(view, "#seated-relation")
    refute has_element?(view, "#standing-material")
    assert has_element?(view, "#continuity-line [data-kind=regarding][data-standing=HUCKLEBERRY]")
    refute has_element?(view, "#continuity-line [data-kind=from][data-standing=HUCKLEBERRY]")

    for {id, kind} <- [
          {"approach", "approach"},
          {"seat", "seating"},
          {"step", "step"},
          {"furnish-material", "furnishing"}
        ] do
      refute has_element?(view, "##{id}[disabled]")
      view |> element("##{id}") |> render_click()
      assert has_element?(view, "#standing-from[data-standing=ENZO]")
      assert has_element?(view, "#continuity-line [data-kind=#{kind}][data-standing=HUCKLEBERRY]")
      refute has_element?(view, "#standing-material")
    end

    assert has_element?(view, "#seated-relation[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#step-relation[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#worked-material", "THIS ONE LEASHING")
    view |> element("#zipper") |> render_click()
    assert_consequence(view)

    view |> element("#regard-enzo") |> render_click()
    view |> element("#approach") |> render_click()
    view |> element("#traverse") |> render_click()
    assert has_element?(view, "#apparatus-posture[data-regarding=ENZO][data-segment='1']")
    assert has_element?(view, "#continuity-line [data-kind=approach][data-standing=ENZO]")

    view |> element("#refold") |> render_click()
    assert has_element?(view, "#folded")
    refute has_element?(view, "#caterpillar")
    refute has_element?(view, "#continuity-line [data-scope=ephemeral]")
    assert_consequence(view)

    view |> element("#return") |> render_click()
    assert_returned(view)
    view |> element("#regard-enzo") |> render_click()
    assert has_element?(view, "#regarding[data-standing=ENZO]")
    assert_consequence(view)
    view |> element("#refold") |> render_click()
    view |> element("#return") |> render_click()
    assert_returned(view)
    GenServer.stop(view.pid)
    {:ok, remounted, _} = live(conn, path)
    assert_returned(remounted)
  end

  test "guards disable controls and reject direct gestures that skip bodily labor", %{conn: conn} do
    {view, _} = open(conn)

    for id <- ["approach", "traverse", "seat", "step", "furnish-material", "zipper"] do
      assert has_element?(view, "##{id}[disabled]")
    end

    for action <- ["furnish", "approach", "traverse", "seat", "step", "zipper", "rezipper"] do
      render_click(view, action, %{"target" => "HUCKLEBERRY"})
    end

    refute has_element?(view, "#worked-material")
    refute has_element?(view, "#continuity-line [data-kind=approach]")
    assert has_element?(view, "#standing-from[data-standing=ENZO]")

    view |> element("#regard-huckleberry") |> render_click()
    assert has_element?(view, "#furnish-material[disabled]")
    assert has_element?(view, "#traverse[disabled]")
    assert has_element?(view, "#seat[disabled]")
    assert has_element?(view, "#step[disabled]")
    assert has_element?(view, "#zipper[disabled]")
    render_click(view, "furnish", %{"target" => "HUCKLEBERRY"})
    render_click(view, "zipper", %{"target" => "HUCKLEBERRY"})
    refute has_element?(view, "#worked-material")

    view |> element("#approach") |> render_click()
    refute has_element?(view, "#traverse[disabled]")
    view |> element("#traverse") |> render_click()
    assert has_element?(view, "#apparatus-posture[data-segment='1']")
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
    assert has_element?(view, "#step[disabled]")
    assert has_element?(view, "#furnish-material[disabled]")
    view |> element("#seat") |> render_click()
    assert has_element?(view, "#furnish-material[disabled]")
    view |> element("#step") |> render_click()
    refute has_element?(view, "#furnish-material[disabled]")
    assert has_element?(view, "#zipper[disabled]")
  end

  test "pivoting Regard replaces the outreading and relinquishes downstream relations", %{
    conn: conn
  } do
    {view, _} = open(conn)
    view |> element("#regard-huckleberry") |> render_click()

    for id <- ["approach", "seat", "step", "furnish-material"] do
      view |> element("##{id}") |> render_click()
    end

    view |> element("#regard-enzo") |> render_click()
    assert has_element?(view, "#caterpillar[data-standing=ENZO]")
    refute has_element?(view, "#seated-relation")
    refute has_element?(view, "#step-relation")
    refute has_element?(view, "#worked-material")
    refute has_element?(view, "#continuity-line [data-kind=approach]")
    view |> element("#regard-huckleberry") |> render_click()
    assert has_element?(view, "#caterpillar[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#zipper[disabled]")
    assert has_element?(view, "#furnish-material[disabled]")
    refute has_element?(view, "#continuity-line [data-kind=regarding][data-standing=ENZO]")
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
  end

  test "folding before ZIPPERING does not commit the worked Leashing", %{conn: conn} do
    {view, _} = open(conn)
    view |> element("#regard-huckleberry") |> render_click()

    for id <- ["approach", "seat", "step", "furnish-material", "refold", "return"] do
      view |> element("##{id}") |> render_click()
    end

    assert has_element?(view, "#standing-from[data-standing=ENZO]")
    refute has_element?(view, "#standing-material")
    refute has_element?(view, "#worked-material")
    refute has_element?(view, "#continuity-line [data-kind=zippering]")
  end

  test "entry furnishes a reusable return URL", %{conn: conn} do
    {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/experiments/refolding")
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#standing-from[data-standing=ENZO]")
  end

  defp open(conn) do
    key = Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)
    path = ~p"/experiments/refolding?by=#{key}"
    {:ok, view, _} = live(conn, path)
    {view, path}
  end

  defp assert_consequence(view) do
    assert has_element?(view, "#standing-from[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#standing-material", "THIS ONE LEASHING")

    assert has_element?(
             view,
             "#continuity-line [data-scope=consequential][data-kind=from][data-standing=ENZO]"
           )

    assert has_element?(view, "#continuity-line [data-kind=zippering]")

    assert has_element?(
             view,
             "#continuity-line [data-scope=consequential][data-kind=from][data-standing=HUCKLEBERRY]"
           )

    refute has_element?(view, "#continuity-line [data-kind=zippering] ~ [data-kind=zippering]")
  end

  defp assert_returned(view) do
    assert_consequence(view)
    assert has_element?(view, "#caterpillar[data-standing=HUCKLEBERRY]")
    assert has_element?(view, "#regard-enzo")
    assert has_element?(view, "#regard-huckleberry")
    assert has_element?(view, "#regarded-material", "THIS ONE LEASHING")
    assert has_element?(view, "#apparatus-posture[data-regarding=HUCKLEBERRY][data-segment='0']")
    assert has_element?(view, "#continuity-line [data-kind=apparatus][data-standing=HUCKLEBERRY]")
    refute has_element?(view, "#continuity-line [data-kind=approach]")
    refute has_element?(view, "#continuity-line [data-kind=seating]")
    refute has_element?(view, "#continuity-line [data-kind=step]")
    refute has_element?(view, "#continuity-line [data-kind=furnishing]")
  end
end
