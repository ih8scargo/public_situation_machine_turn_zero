defmodule PublicSituationMachineTurnZero.RuggingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Rugging

  test "Rugging inherits one circle and CUBICAL Floor without furnishing new events or moving FROM" do
    m = A.new()
    initial = Rugging.presentation(m)
    refute initial["field_available"]
    refute initial["seating_available"]
    {:ok, pulled} = A.operate(m, {:opening_pull, %{"dx" => 12, "dy" => 0}})
    p = Rugging.presentation(pulled)
    assert p["circle_identity"] == "opening-circle-available"
    assert p["radius"] == m.standing["opening_geometry"]["circle"]["radius"]
    assert p["field_available"]
    refute p["seating_available"]
    assert p["floor_y"] == Enum.at(pulled.standing["opening_geometry"]["wireframe"]["min"], 1)
    {:ok, puffed} = A.operate(pulled, :puff)
    assert Rugging.presentation(puffed)["seating_available"]
    assert Enum.at(puffed.standing["opening_geometry"]["aperture"]["center"], 1) > p["floor_y"]
    assert puffed.standing["from"] == m.standing["from"]
    assert length(puffed.standing["events"]) == 2
    assert Rugging.presentation(A.restore(puffed.standing)) == Rugging.presentation(puffed)
  end

  test "complete original and provisional editorial candidates remain distinct and exact" do
    original = File.read!("docs/machine-instructionings/richard-october-29-original.txt")
    archive = File.read!("docs/experimental-rugging-inscriptions.md")
    source = File.read!("docs/machine-instructionings/rugging-pass-source.txt")
    assert String.contains?(archive, original)
    assert String.contains?(original, "RUGGING RUGGING")
    assert String.contains?(original, "  DRAT, BILL-- THE MIDDLE GOT MUDDLED HERE .")
    assert String.contains?(original, "UPON  THIS .  Let's pick this apart")

    for letter <- ["A", "B", "C"],
        do: assert(String.contains?(archive, "PROVISIONAL — NOTICE #{letter}"))

    assert String.contains?(source, "FROM HERE NOW:")
    assert String.contains?(archive, "FROM HERE ON:")
    assert String.contains?(archive, "does not yet settle the full distinction")
  end
end
