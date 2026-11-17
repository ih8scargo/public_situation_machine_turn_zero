defmodule PublicSituationMachineTurnZeroWeb.CoBuildingLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  test "new workbench keeps old architecture standing unchanged through rehearsals", %{conn: conn} do
    r = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{r.id}")
    {:ok, before} = Store.fetch(r.id)
    assert has_element?(v, "#co-building")
    assert has_element?(v, "#crossing-rehearsal")
    digest = attr(v, "#co-building", "data-standing-digest")
    source = attr(v, "#cb-letter-R", "data-source-hash")
    setting(v, "door", "45")
    v |> element("#cb-park_door") |> render_click()
    setting(v, "door", "90")
    v |> element("#cb-restore_door") |> render_click()
    assert has_element?(v, "#co-building[data-door='45.0']")
    v |> element("#cb-view-flat") |> render_click()
    assert attr(v, "#cb-letter-R", "data-source-hash") == source
    v |> element("#cb-trace-form") |> render_submit(%{"trace" => %{"text" => "R"}})
    v |> element("#cb-R-road") |> render_click()
    v |> element("#cb-stitch") |> render_click()
    assert has_element?(v, "#cb-letter-status", "actual stitching false")

    for n <- 1..7 do
      v |> element("#cb-course-stage-#{n}") |> render_click()
    end

    assert has_element?(v, "#cb-selected-name", "FLAT")
    assert attr(v, "#co-building", "data-standing-digest") == digest
    {:ok, after_read} = Store.fetch(r.id)
    assert after_read == before
  end

  test "selection survives hiding, view changes and return to earlier layers", %{conn: conn} do
    r = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{r.id}")
    v |> element("#cb-inspect-cb-wedge-A") |> render_click()
    assert has_element?(v, "#cb-selected-name", "Wedge A")
    v |> element("#cb-toggle-wedges") |> render_click()
    v |> element("#cb-view-tunneling") |> render_click()
    setting(v, "layer", "0")
    assert has_element?(v, "#cb-selected-name", "Wedge A")
    assert has_element?(v, "#co-building[data-acquired-delta='0']")
    v |> element("#cb-reveal") |> render_click()
    assert has_element?(v, "#cb-listing")
    assert has_element?(v, "#cb-acquisition", "false")
  end

  test "stale and unsupported commands leave protected state alone", %{conn: conn} do
    r = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{r.id}")
    {:ok, before} = Store.fetch(r.id)
    v |> element("#cb-view-flat") |> render_click()
    render_click(v, "co-building-action", %{"action" => "stitch", "revision" => "0"})
    assert has_element?(v, "#cb-notice")
    render_click(v, "co-building-action", %{"action" => "re_step", "revision" => "1"})
    {:ok, after_read} = Store.fetch(r.id)
    assert before == after_read
    assert has_element?(v, "#co-building[data-acquired-delta='0']")
  end

  test "THREE–FOUR material, appointment and Projectioning controls preserve saved standing", %{
    conn: conn
  } do
    r = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{r.id}")
    {:ok, before} = Store.fetch(r.id)
    v |> element("#cb-three_four") |> render_click()
    setting(v, "interpolation", "0.5")
    v |> element("#cb-passage_appointment") |> render_click()
    v |> element("#cb-interpolation_projection") |> render_click()
    setting(v, "circuit", "180")
    assert has_element?(v, "#cb-encounter-prospective-ceiling[data-reached='true']")
    assert has_element?(v, "#cb-encounter-current-tunnel[data-reached='false']")
    setting(v, "circuit", "300")
    assert has_element?(v, "#cb-encounter-current-tunnel[data-reached='true']")
    assert has_element?(v, "#cb-interpolation-status", "proposed")
    assert has_element?(v, "#co-building[data-acquired-delta='0']")
    {:ok, after_read} = Store.fetch(r.id)
    assert before == after_read
  end

  test "double Gallery passage exposes measured incidence without changing standing", %{
    conn: conn
  } do
    r = Store.create()
    {:ok, v, _} = live(conn, "/experiments/architecture?id=#{r.id}")
    {:ok, before} = Store.fetch(r.id)
    v |> element("#cb-double_passage") |> render_click()
    assert has_element?(v, "#cb-selected-name", "four-point")
    assert has_element?(v, "#cb-double-incidence", "8")
    assert has_element?(v, "#cb-double-sightline", "false")
    assert has_element?(v, "#co-building[data-acquired-delta='0']")
    v |> element("#cb-view-side") |> render_click()
    {:ok, after_read} = Store.fetch(r.id)
    assert before == after_read
  end

  defp setting(v, key, value),
    do:
      v
      |> element("#cb-settings")
      |> render_change(%{"_target" => ["settings", key], "settings" => %{key => value}})

  defp attr(v, selector, key),
    do:
      v
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(selector)
      |> LazyHTML.attribute(key)
end
