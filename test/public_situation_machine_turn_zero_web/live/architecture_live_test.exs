defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PublicSituationMachineTurnZero.Architecture.Store

  defp click(view, selector), do: view |> element(selector) |> render_click()

  defp complete_zeroeth(view) do
    for selector <- ["#zeroeth-calibrate", "#zeroeth-position", "#zeroeth-appoint"],
        do: click(view, selector)
  end

  test "bodily acceptance drive from half ZEROETH through STEP into curved Tunnel and receiving approach",
       %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/architecture/engineering?id=#{record.id}"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, "#architecture-cabinet")
    assert has_element?(view, "#zeroeth-geometry[data-enclosure=half]")
    assert has_element?(view, "#first-step[disabled]")
    refute has_element?(view, "#tunnel-nav")
    refute has_element?(view, "#tunnel-geometry")
    view |> form("#wheel-input-form", wheel: %{angle: "180"}) |> render_change()
    assert has_element?(view, "#inherited-human-ground")
    assert has_element?(view, "#inherited-tc-ground")
    {:ok, regarded} = Store.fetch(record.id)
    assert regarded.standing == record.standing
    view |> form("#wheel-input-form", wheel: %{angle: "270"}) |> render_change()
    assert has_element?(view, "#toy-box-ledger")
    complete_zeroeth(view)
    assert has_element?(view, "#zeroeth-geometry[data-enclosure=full]")
    assert has_element?(view, "#projected-tc[data-appointed=true]")
    assert has_element?(view, "#first-landing")
    assert has_element?(view, "#first-step:not([disabled])")
    {:ok, completed} = Store.fetch(record.id)
    assert completed.standing["from"] == "ZEROETH"
    assert completed.standing["passages"] == []
    click(view, "#first-step")
    assert has_element?(view, "#tunnel-geometry")
    assert has_element?(view, "#tunnel-nav")
    assert has_element?(view, "#rail-left")
    assert has_element?(view, "#rail-right")
    assert has_element?(view, "#zeroeth-appoint[disabled]")
    {:ok, stepped} = Store.fetch(record.id)
    for _ <- 1..6, do: click(view, "#nav-forward")
    assert has_element?(view, "#architecture-projection[data-nav='6']")
    assert has_element?(view, "#nav-forward[disabled]")
    assert has_element?(view, "#quiet-approach[data-enclosure=half]")
    assert has_element?(view, "#continuing-toward")
    view |> form("#wheel-input-form", wheel: %{angle: "180"}) |> render_change()
    assert has_element?(view, "#inherited-tc-appointed")
    click(view, "#flat-toggle")
    assert has_element?(view, "#architecture-projection[data-mode=flat]")
    assert has_element?(view, "#architecture-materials [data-material=quiet-aim]")
    click(view, "#flat-toggle")
    assert has_element?(view, "#architecture-projection[data-mode=diorama]")
    {:ok, navigated} = Store.fetch(record.id)
    assert navigated.standing == stepped.standing
    click(view, "#projection-toggle")
    refute has_element?(view, "#architecture-projection")
    assert has_element?(view, "#projection-extinguished")
    assert has_element?(view, "#architecture-cabinet")
    assert has_element?(view, "#flat-toggle[disabled]")
    {:ok, off} = Store.fetch(record.id)
    assert off.standing == stepped.standing
    click(view, "#projection-toggle")
    assert has_element?(view, "#architecture-projection[data-nav='0'][data-bearing=approach]")
    assert has_element?(view, "#tunnel-geometry")
    click(view, "#nav-forward")
    click(view, "#nav-backward")
    assert has_element?(view, "#architecture-projection[data-nav='0']")
    {:ok, resumed, _} = live(conn, path)
    assert has_element?(resumed, "#tunnel-geometry")
    assert has_element?(resumed, "#architecture-passage", "1")
  end

  test "development enclosure fixture records its own origin without erasing inherited standing",
       %{conn: conn} do
    record = Store.create()
    {:ok, view, _} = live(conn, ~p"/experiments/architecture/engineering?id=#{record.id}")
    complete_zeroeth(view)
    click(view, "#first-step")
    for _ <- 1..6, do: click(view, "#nav-forward")
    click(view, "#quiet-enclosure-fixture")
    assert has_element?(view, "#quiet-approach[data-enclosure=full]")
    {:ok, full} = Store.fetch(record.id)
    assert full.standing["relations"]["quiet-enclosure"]["origin"] == "ONE"
    click(view, "#quiet-enclosure-fixture")
    assert has_element?(view, "#quiet-approach[data-enclosure=half]")
    {:ok, half} = Store.fetch(record.id)

    assert half.standing["relations"]["tc-appointed"] ==
             full.standing["relations"]["tc-appointed"]

    assert half.standing["passages"] == full.standing["passages"]
  end

  test "material and apparatus language can be revised and placed without template changes", %{
    conn: conn
  } do
    record = Store.create()
    path = ~p"/experiments/architecture/engineering?id=#{record.id}"
    {:ok, view, _} = live(conn, path)

    view
    |> form("#material-editor",
      material: %{title: "Recovered WHAT-FOR", text: "Revised language from the hallway"}
    )
    |> render_submit()

    assert has_element?(
             view,
             "#architecture-materials [data-material=this-place] h2",
             "Recovered WHAT-FOR"
           )

    view |> form("#material-selection", selection: %{id: "tunnel-notice"}) |> render_change()

    view
    |> form("#material-editor",
      material: %{
        text: "Recovered Tunnel inscription",
        origin: "ZEROETH",
        location: "ZEROETH-ONE",
        course: "1",
        categories: ["Approach Noticingments", "Relationing + Provenance"]
      }
    )
    |> render_submit()

    click(view, "#material-new")

    view
    |> form("#material-editor",
      material: %{
        title: "New groundward notice",
        text: "Registered from ZEROETH",
        origin: "ZEROETH",
        location: "ZEROETH",
        region: "groundward",
        bearing: "groundward",
        course: "0",
        categories: ["Human-Brought Enablingmentings"]
      }
    )
    |> render_submit()

    view
    |> form("#toy-editor",
      toy: %{aim: "RUGGING / revised composition", notes: "Unresolved furnishing"}
    )
    |> render_submit()

    assert has_element?(view, "#toy-editor input[value='RUGGING / revised composition']")
    complete_zeroeth(view)
    click(view, "#first-step")

    assert has_element?(
             view,
             "#architecture-materials [data-material=tunnel-notice]",
             "Recovered Tunnel inscription"
           )

    {:ok, saved} = Store.fetch(record.id)
    assert map_size(saved.standing["materials"]) == map_size(record.standing["materials"]) + 1
    assert map_size(saved.standing["toys"]) == 17
    assert saved.standing["materials"]["this-place"]["revision"] == 2
    {:ok, reloaded, _} = live(conn, path)

    assert has_element?(
             reloaded,
             "#architecture-materials [data-material=tunnel-notice]",
             "Recovered Tunnel inscription"
           )
  end

  test "invalid authorship and stale writers cannot overwrite the ledger", %{conn: conn} do
    record = Store.create()
    path = ~p"/experiments/architecture/engineering?id=#{record.id}"
    {:ok, one, _} = live(conn, path)
    {:ok, two, _} = live(conn, path)
    one |> form("#material-selection", selection: %{id: "tunnel-notice"}) |> render_change()
    one |> form("#material-editor", material: %{origin: "ONE"}) |> render_submit()
    assert has_element?(one, "#material-editor", "furnishing locality ZEROETH")
    {:ok, unchanged} = Store.fetch(record.id)
    assert unchanged.standing == record.standing
    click(one, "#zeroeth-calibrate")
    click(two, "#zeroeth-calibrate")
    assert has_element?(two, "#architecture-status", "Reload")
    {:ok, invalid, _} = live(conn, ~p"/experiments/architecture/engineering?id=missing")
    assert has_element?(invalid, "#projection-toggle[disabled]")
  end
end
