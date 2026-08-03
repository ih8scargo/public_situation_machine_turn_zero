defmodule PublicSituationMachineTurnZeroWeb.TurnZeroLiveTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "presents the three public Bearingings sections", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/constitutioning-bearingings")

    assert has_element?(view, "#constitutioning-bearingings-page")
    assert has_element?(view, "#observationing-harbors")
    assert has_element?(view, "#embroidery-stitching")
    assert has_element?(view, "#what-becomes-possible")
  end

  test "furnishes all eleven Observationing Harbors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/constitutioning-bearingings")

    assert has_element?(view, "#observationing-harbors-projectioning")

    for harbor <- [
          "RESPIRATORY RECOVERY",
          "LEARNING PROGRESSION",
          "WATERSHED STEWARDSHIP",
          "NEW ROMANCE",
          "SCRAMBLED EGGS",
          "HUMAN–CANINE CO-INHABITATION",
          "COMMUNITY GATHERING",
          "PHYSICAL CONDITIONING",
          "ENSEMBLE REHEARSAL",
          "VOLUNTEER ACTIVATION",
          "NOVEL WRITING"
        ] do
      assert has_element?(view, "#observationing-harbors-projectioning tbody tr", harbor)
    end
  end

  test "does not expose the legacy Turn Zero controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/constitutioning-bearingings")

    refute has_element?(view, "#tuple-position-0")
    refute has_element?(view, "#unfold-position-1")
    refute has_element?(view, "#turn-zero-knotting-rail")
  end
end
