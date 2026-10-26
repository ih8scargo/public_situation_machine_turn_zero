defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.{Store, Record}
  alias PublicSituationMachineTurnZero.Repo

  @appointments [
    "approach",
    "appoint-cob",
    "furnish-pretend",
    "appoint-pointing",
    "stand-tc",
    "stand-place"
  ]

  defp labor(view, actions) do
    for action <- actions do
      view |> element("#spindle-labor[phx-value-action='#{action}']") |> render_click()
    end
  end

  test "open approach has no future locality or premature Place", %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}")
    assert has_element?(view, "#empty-trace")
    assert has_element?(view, "#projectioning-crossing #approach-field")
    refute has_element?(view, "#station-trace li")
    refute has_element?(view, "#cob")
    refute has_element?(view, "#this-one-place")
    refute has_element?(view, "#approaching-landinging")
    refute has_element?(view, "#current-local-moment")
    render_click(view, "labor", %{"action" => "step"})
    {:ok, unchanged} = Store.fetch(record.id)
    assert unchanged.standing == record.standing
  end

  test "earned bodies and local chains grow with the four Appointmentings", %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}")
    labor(view, ["approach", "appoint-cob"])
    assert has_element?(view, "#cob[data-appointed=true]")
    assert has_element?(view, "#stations-zeroeth")
    refute has_element?(view, "#stations-first")
    assert has_element?(view, "#pretend-pointing-surface")
    assert has_element?(view, "#events-appoint-cob [data-relation=cob-appointed]")
    labor(view, ["furnish-pretend"])
    refute has_element?(view, "#stations-first")
    labor(view, ["appoint-pointing", "stand-tc"])
    assert has_element?(view, "#stations-first")
    assert has_element?(view, "#stations-second")
    assert has_element?(view, "#tc-down-under")
    refute has_element?(view, "#this-one-place")

    assert has_element?(
             view,
             "#staging-for-standing .rail-chain-prospect [data-relation=place-standing]"
           )

    labor(view, ["stand-place"])
    assert has_element?(view, "#this-one-place[data-inhabited=false] #rugging")
    assert has_element?(view, "#approaching-landinging")
    refute has_element?(view, "#human-within")
    refute has_element?(view, "#current-local-moment")
    assert has_element?(view, "#stations-third")
    {:ok, third} = Store.fetch(record.id)
    assert third.standing["from"] == record.standing["from"]

    assert Enum.map(third.standing["stations"], & &1["id"]) == [
             "zeroeth",
             "first",
             "second",
             "third"
           ]
  end

  test "seat, passage and arrival resume without collapsing THERE into FROM", %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/architecture?id=#{record.id}"
    {:ok, view, _} = live(conn, path)
    labor(view, @appointments)
    {:ok, third} = Store.fetch(record.id)
    {:ok, resumed, _} = live(conn, path)
    assert has_element?(resumed, "#this-one-place[data-inhabited=false]")
    assert has_element?(resumed, "#spindle-labor[phx-value-action=seat]")
    labor(resumed, ["seat"])
    assert has_element?(resumed, "#present-standing #human-seated")
    refute has_element?(resumed, "#this-one-place #human-seated")
    assert has_element?(resumed, "#moment-passageway #current-local-moment")
    assert has_element?(resumed, "#spindle-labor[phx-value-action=step]")
    {:ok, seated} = Store.fetch(record.id)
    assert seated.standing["from"] == third.standing["from"]
    assert seated.standing["passages"] == []
    {:ok, at_passage, _} = live(conn, path)
    assert has_element?(at_passage, "#current-local-moment")
    labor(at_passage, ["step"])
    assert has_element?(at_passage, "#rail-pass-complete")
    assert has_element?(at_passage, "#this-one-place[data-inhabited=true] #human-within")
    refute has_element?(at_passage, "#spindle-labor")
    refute has_element?(at_passage, "#moment-passageway")
    {:ok, saved} = Store.fetch(record.id)
    assert length(saved.standing["passages"]) == 1
    assert saved.standing["from"]["within"] == "place"
    {:ok, within, _} = live(conn, path)
    assert has_element?(within, "#human-within")
    assert has_element?(within, "#events-step [data-relation=human-through-moment]")
    refute has_element?(within, "#inner-aperture")
  end

  test "regarding accumulated localities is ephemeral and leaves active labor intact", %{
    conn: conn
  } do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{record.id}")
    labor(view, @appointments)
    {:ok, before} = Store.fetch(record.id)
    view |> element("#regard-first") |> render_click()
    assert has_element?(view, "#stations-first[data-regarded=true]")
    assert has_element?(view, "#events-furnish-pretend[data-regarded=true]")
    assert has_element?(view, "#events-appoint-pointing[data-regarded=true]")
    assert has_element?(view, "#spindle-labor[phx-value-action=seat]")
    {:ok, after_regard} = Store.fetch(record.id)
    assert after_regard.lock_version == before.lock_version
    assert after_regard.standing == before.standing
  end

  test "stale windows cannot overwrite passage or other consequential standing", %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/architecture?id=#{record.id}"
    {:ok, one, _} = live(conn, path)
    labor(one, @appointments ++ ["seat"])
    {:ok, two, _} = live(conn, path)
    labor(one, ["step"])
    labor(two, ["step"])
    assert has_element?(two, "#spindle-labor[disabled]")
    assert has_element?(two, "#spindle-status")
    refute has_element?(two, "#human-within")
    {:ok, saved} = Store.fetch(record.id)
    assert length(saved.standing["passages"]) == 1
    assert length(saved.standing["events"]) == 8
  end

  test "Round One keeps its original ancestry as a read-only witness", %{conn: conn} do
    original = %{
      "version" => "spindle-round-one",
      "from" => %{"up_on" => "standinging-landinging"},
      "relations" => %{"place-standing" => %{}},
      "events" => []
    }

    old = Repo.insert!(%Record{standing: original})
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=#{old.id}")
    assert has_element?(view, "#round-one-witness")
    refute has_element?(view, "#rail-appliance")
    render_click(view, "labor", %{"action" => "stand-tc"})
    {:ok, retained} = Store.fetch(old.id)
    assert retained.standing == original
  end

  test "unknown records disable labor and offer a fresh approach", %{conn: conn} do
    assert {:error, :not_found} = Store.fetch("missing")
    {:ok, view, _} = live(conn, ~p"/experiments/architecture?id=missing")
    assert has_element?(view, "#spindle-labor[disabled]")
    assert has_element?(view, "#fresh-round")
  end

  test "fresh public route creates a resumable composition", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/experiments/architecture")
    assert has_element?(view, "#spindle-labor:not([disabled])[phx-value-action=approach]")
  end
end
