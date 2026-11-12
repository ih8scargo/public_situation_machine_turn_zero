defmodule PublicSituationMachineTurnZeroWeb.ComingAboardReconstructionLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase

  import Phoenix.LiveViewTest

  test "opens through a performed pull, composes, and returns with the same FROM and stock", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, ~p"/workshop/coming-aboard")
    assert has_element?(view, "#ca-pull-witness[data-opening=held]")
    assert has_element?(view, "#ca-invitation", "PULL TO STAND OPEN THE TOY BOX FROM HERE.")
    assert has_element?(view, "#ca-office-0", "Furnishing Traversaling COB")
    assert has_element?(view, "#ca-office-1", "Traversaling Furnishing COB")

    for event <- ~w(curve fold regard puff rail re-step nav-step) do
      render_click(view, event, %{})
    end

    assert has_element?(view, "#coming-aboard[data-pose=held][data-regarding=flat]")
    refute has_element?(view, "#ca-cob")
    refute has_element?(view, "#ca-tunnel")

    assert %{token: cancelled} = purchase(view)
    render_hook(view, "pull", %{token: cancelled})
    render_hook(view, "release-pull", %{token: cancelled, measurements: %{dx: 0, dy: 0}})
    assert has_element?(view, "#ca-invitation")
    assert has_element?(view, "#ca-pull-witness[data-opening=held]")

    assert %{token: token} = purchase(view)
    render_hook(view, "pull", %{token: cancelled})
    render_hook(view, "release-pull", %{token: token, measurements: %{dx: 42, dy: 0}})
    assert has_element?(view, "#ca-invitation")
    assert has_element?(view, "#ca-pull-witness[data-opening=held]")

    assert %{token: token} = purchase(view)
    render_hook(view, "pull", %{token: token})
    render_hook(view, "release-pull", %{token: token, measurements: %{dx: 42, dy: 0}})
    assert has_element?(view, "#coming-aboard[data-pose=loosened]")
    assert has_element?(view, "#ca-cob[data-appointed=true][data-confirmed=false]")
    assert has_element?(view, "#ca-pull-witness[data-opening=accepted]")
    refute has_element?(view, "#ca-fold")

    click(view, "#ca-puff")
    click(view, "#ca-curve")
    click(view, "#ca-fold")
    assert has_element?(view, "#ca-tunnel[data-stock=bearing-archway-here-square]")
    assert has_element?(view, "#ca-cob[data-appointed=true][data-confirmed=true]")

    click(view, "#ca-flat")

    assert has_element?(
             view,
             "#coming-aboard[data-from='HOME FROM HERE'][data-pose=folded][data-regarding=flat]"
           )

    assert has_element?(view, "#ca-ancestry[data-stock=bearing-archway-here-square]")
    assert has_element?(view, "#ca-cob[data-appointed=true][data-confirmed=true]")
    assert has_element?(view, "#ca-office-0")
    assert has_element?(view, "#ca-office-1")

    click(view, "#ca-regard")
    assert has_element?(view, "#ca-tunnel")
    click(view, "#ca-flat")
    click(view, "#ca-unfold")
    click(view, "#ca-uncurve")
    assert has_element?(view, "#coming-aboard[data-pose=loosened][data-regarding=flat]")
    assert has_element?(view, "#ca-cob[data-appointed=true][data-confirmed=true]")
    refute has_element?(view, "#ca-regard")
  end

  defp purchase(view) do
    render_hook(view, "take-purchase", %{})
    assert_reply(view, %{accepted: true, token: token})
    %{token: token}
  end

  defp click(view, id), do: view |> element(id) |> render_click()
end
