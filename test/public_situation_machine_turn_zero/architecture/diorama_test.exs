defmodule PublicSituationMachineTurnZero.DioramaTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Diorama

  test "presentation is inherited and read-only, gated by existing appointment" do
    m = A.new()
    assert Diorama.presentation(m) == nil
    {:ok, pulled} = A.operate(m, {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, puffed} = A.operate(pulled, :puff)
    assert Diorama.presentation(puffed) == nil

    {:ok, staged} =
      A.operate(
        puffed,
        {:opening_feed, %{"yaw" => 22, "pitch" => -10, "length" => 2, "extension" => 1}}
      )

    {:ok, appointed} = A.operate(staged, :opening_appoint)
    standing = appointed.standing
    presentation = Diorama.presentation(appointed)
    assert presentation["reference"] == standing["opening_geometry"]["wireframe"]
    assert presentation["status"] == "provisional mechanical rehearsal"
    assert Enum.all?(presentation["ancestry"], &Map.has_key?(standing["relations"], &1))
    assert appointed.standing == standing
    assert appointed.standing["from"] == m.standing["from"]

    assert Enum.map(standing["events"], & &1["id"]) == [
             "first-pull",
             "first-puffing",
             "appoint-pointingable"
           ]

    assert Diorama.presentation(A.restore(standing)) == presentation
  end

  test "reserve excerpts remain exact source language with differentiated responsibilities" do
    source = File.read!("docs/machine-instructionings/round-three-source.txt")
    marks = Diorama.markings()

    assert Enum.sort(Enum.uniq(Enum.map(marks, & &1["family"]))) == [
             "in-stringing-mentings",
             "road",
             "zippering-line"
           ]

    for mark <- marks do
      assert String.contains?(source, mark["inscription"])
      for field <- ["responsibility", "source", "status", "affordances"], do: assert(mark[field])
    end

    manual =
      File.read!("docs/machine-instructionings/appliance-manual.txt")
      |> String.trim_trailing("\n")

    assert String.contains?(source, manual)
    inscription = File.read!("docs/machine-instructionings/xt-yt-xt-inscription.txt")
    assert String.contains?(inscription, "TOWARD HREE")
    assert String.contains?(inscription, "HERE from HERE ON NOW")
  end
end
