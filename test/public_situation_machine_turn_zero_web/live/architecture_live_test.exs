defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.{Store, Record}
  alias PublicSituationMachineTurnZero.Repo

  defp pull(v) do
    render_hook(v, "take-purchase", %{})
    assert_reply v, %{accepted: true, token: token}
    render_hook(v, "pull", %{"token" => token})
    assert_reply v, %{accepted: true}

    render_hook(v, "release-pull", %{
      "token" => token,
      "measurements" => %{"dx" => 20, "dy" => -10, "duration_ms" => 250}
    })
  end

  test "initial page is pivotable before pull and exposes no later apparatus", %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/experiments/architecture")
    assert has_element?(v, "#opening-geometry[data-ready=true]")
    assert has_element?(v, "#opening-geometry[phx-hook=ElementaryOpening]")
    assert has_element?(v, "#pull-invitation")

    for id <- [
          "puffing-squeeze",
          "stick-furnishing",
          "road-reservation",
          "regarding-square",
          "step",
          "landinging",
          "toy-box"
        ],
        do: refute(has_element?(v, "##{id}"))
  end

  test "completed pull then puff persist separate consequences; partial purchase cannot accomplish",
       %{conn: conn} do
    r = Store.create()
    path = ~p"/experiments/architecture?id=#{r.id}"
    {:ok, v, _} = live(conn, path)
    render_hook(v, "puff", %{})
    assert_reply v, %{accepted: false}
    {:ok, unchanged} = Store.fetch(r.id)
    assert unchanged == r

    render_hook(v, "release-pull", %{"token" => "fake", "measurements" => %{"dx" => 3, "dy" => 2}})

    assert_reply v, %{accepted: false}
    pull(v)
    assert_reply v, %{accepted: true}
    assert has_element?(v, "#puffing-squeeze")
    refute has_element?(v, "#opening-pull")
    {:ok, pulled} = Store.fetch(r.id)
    assert Enum.map(pulled.standing["events"], & &1["id"]) == ["first-pull"]
    v |> element("#puffing-squeeze") |> render_click()
    assert has_element?(v, "#stick-furnishing")
    {:ok, puffed} = Store.fetch(r.id)
    assert A.puffed?(A.restore(puffed.standing))
    render_hook(v, "puff", %{})
    assert_reply v, %{accepted: false}
    {:ok, repeated} = Store.fetch(r.id)
    assert repeated == puffed
    {:ok, resumed, _} = live(conn, path)
    assert has_element?(resumed, "#stick-furnishing")
    refute has_element?(resumed, "#puffing-squeeze")
  end

  test "lock is temporary staging; only COB UP OVER appoints and saves the chosen orientation", %{
    conn: conn
  } do
    r = Store.create()
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}")
    pull(v)
    render_hook(v, "puff", %{})
    {:ok, before_lock} = Store.fetch(r.id)
    render_hook(v, "cob-up-over", %{})
    assert_reply v, %{accepted: false}

    render_hook(v, "stage-feed", %{"yaw" => 38, "pitch" => -17, "length" => 2.6, "extension" => 1})

    assert_reply v, %{accepted: true}
    assert has_element?(v, "#stick-locked")
    {:ok, staged} = Store.fetch(r.id)
    assert staged == before_lock
    v |> element("#cob-up-over") |> render_click()
    assert has_element?(v, "#appointment-noticing")
    assert has_element?(v, "#diorama-instructionings")
    assert has_element?(v, "#material-human-push[data-material-family=in-stringing-mentings]")
    assert has_element?(v, "#material-zippering-line[data-material-family=zippering-line]")
    assert has_element?(v, "#material-road-material[data-material-family=road]")
    refute has_element?(v, "#stick-furnishing")
    {:ok, saved} = Store.fetch(r.id)
    assert saved.standing["opening_geometry"]["stick"]["yaw"] == 38
    assert saved.standing["opening_geometry"]["stick"]["pitch"] == -17

    assert Enum.map(saved.standing["events"], & &1["id"]) == [
             "first-pull",
             "first-puffing",
             "appoint-pointingable"
           ]

    v |> element("#inspect-appointed") |> render_click()
    assert has_element?(v, "#held-reading[data-held-relation=pointingable-standing]")
    v |> element("#follow-predecessor") |> render_click()
    assert has_element?(v, "#held-reading[data-held-relation=cob-up-over-stick]")
    {:ok, regarded} = Store.fetch(r.id)
    assert regarded == saved
    {:ok, resumed, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}")
    assert has_element?(resumed, "#appointment-noticing")
  end

  test "concurrent pull cannot duplicate constitutional events and stale view adopts held geometry",
       %{conn: conn} do
    r = Store.create()
    path = ~p"/experiments/architecture?id=#{r.id}"
    {:ok, one, _} = live(conn, path)
    {:ok, two, _} = live(conn, path)
    pull(one)
    assert_reply one, %{accepted: true}
    pull(two)
    assert_reply two, %{accepted: false}
    assert has_element?(two, "#puffing-squeeze")
    {:ok, saved} = Store.fetch(r.id)
    assert saved.lock_version == 2
    assert length(saved.standing["events"]) == 1
  end

  test "historical witnesses stay read-only and later operations cannot be invoked", %{conn: conn} do
    r = Store.create()
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=#{r.id}")

    for event <- ["step", "re-step", "appoint-pointingable", "feed"] do
      render_hook(v, event, %{})
      assert_reply v, %{accepted: false}
    end

    for version <- A.versions() -- [A.version()] do
      s = %{"version" => version, "relations" => %{}, "events" => []}
      old = Repo.insert!(%Record{standing: s})
      {:ok, witness, _} = live(conn, ~p"/experiments/architecture?id=#{old.id}")
      assert has_element?(witness, "#earlier-witness")
      assert {:error, :read_only_witness} = Store.save(old, s)
      assert A.restore(s).standing == s
    end
  end

  test "invalid UUID gives a fresh opening link without an operative pull", %{conn: conn} do
    {:ok, v, _} = live(conn, ~p"/experiments/architecture?id=missing")
    assert has_element?(v, "#rehearsal-status")
    assert has_element?(v, "#fresh-composition")
    assert has_element?(v, "#opening-geometry[data-ready=false]")
  end
end
