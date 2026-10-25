defmodule PublicSituationMachineTurnZeroWeb.MotorLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.{Motor, Motor.Store}

  test "primitive next is available directly and occupancy is furnished from within", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/motor?id=#{record.id}")
    assert has_element?(view, "#motor-re-step[disabled]")
    view |> element("#motor-puff") |> render_click()
    assert has_element?(view, "#motor-from", "A")
    assert has_element?(view, "#motor-next", "B")
    refute has_element?(view, "#motor-pivot-B")
    assert has_element?(view, "#motor-point[disabled]")
    assert has_element?(view, "#motor-select[disabled]")
    assert has_element?(view, "#motor-re-seat[disabled]")
    assert has_element?(view, "#motor-nav-step[disabled]")
    assert has_element?(view, "#motor-puff[disabled]")
    assert has_element?(view, "#motor-re-step:not([disabled])")
    {:ok, saved} = Store.fetch(record.id)
    assert saved.standing["next"]["toward"] == "B"
    assert saved.standing["extents"]["B"]["what_for"] == nil
    {:ok, view, _} = live(conn, ~p"/experiments/motor?id=#{record.id}")
    assert has_element?(view, "#motor-next", "B")
    refute has_element?(view, "#motor-pivot-B")
    view |> element("#motor-re-step") |> render_click()
    assert has_element?(view, "#motor-from", "B")
    assert has_element?(view, "#motor-re-step[disabled]")
    view |> form("#motor-inscription", labor: %{id: "B", text: "b"}) |> render_submit()
    assert has_element?(view, "#motor-pivot-B")

    for target <- ["C", "D"] do
      view |> element("#motor-puff") |> render_click()
      view |> element("#motor-re-step") |> render_click()
      assert has_element?(view, "#motor-from", target)
    end

    {:ok, record} = Store.fetch(record.id)
    assert record.standing["from"] == "D"
    assert record.standing["extents"]["B"]["parent"] == "A"
    assert length(record.standing["passages"]) == 3
    {:ok, resumed, _} = live(conn, ~p"/experiments/motor?id=#{record.id}")
    assert has_element?(resumed, "#motor-from", "D")
    assert has_element?(resumed, "#motor-pivot-B")
    assert Motor.restore(record.standing).selected == nil
  end

  test "separate differentiated fixture preserves optional approach without passage", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/motor?id=#{record.id}")
    view |> element("#motor-fixture") |> render_click()
    view |> element("#motor-pivot-LAB-Y") |> render_click()
    assert has_element?(view, "#motor-select[disabled]")
    view |> element("#motor-point") |> render_click()
    view |> element("#motor-select") |> render_click()
    view |> element("#motor-re-seat") |> render_click()

    for _ <- 1..3 do
      view |> element("#motor-nav-step") |> render_click()
      assert has_element?(view, "#motor-from", "A")
    end

    assert has_element?(view, "#motor-progress", "15.0")
    view |> element("#motor-pivot-A") |> render_click()
    assert has_element?(view, "#motor-re-step[disabled]")
    {:ok, saved} = Store.fetch(record.id)
    assert Map.has_key?(saved.standing["landings"], "A:LAB-Y")
    view |> element("#motor-pivot-LAB-Y") |> render_click()
    view |> element("#motor-point") |> render_click()
    view |> element("#motor-select") |> render_click()
    view |> element("#motor-re-step") |> render_click()
    assert has_element?(view, "#motor-from", "LAB-Y")
  end

  test "stale persisted Standing cannot overwrite another cockpit", %{conn: _conn} do
    record = Store.create()
    {:ok, m} = Motor.operate(Motor.restore(record.standing), :puff)
    assert {:ok, _} = Store.save(record, m.standing)
    assert {:error, _} = Store.save(record, m.standing)
  end
end
