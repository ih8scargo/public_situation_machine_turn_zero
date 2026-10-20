defmodule PublicSituationMachineTurnZero.Refolding.StandingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Refolding.{Proof, MemoryStore}

  setup do
    store = start_supervised!({MemoryStore, []})
    %{store: store, key: "human"}
  end

  test "TOWARD is not FROM", ctx do
    session = Proof.return(ctx.store, ctx.key)

    session =
      Enum.reduce(["furnish", "regard", "approach"], session, fn action, s ->
        Proof.gesture(ctx.store, ctx.key, s, action, "HUCKLEBERRY")
      end)

    assert session.standing.from == "ENZO"
    assert session.apparatus.toward == "HUCKLEBERRY"
  end

  test "Segmentationing is not consequence", ctx do
    session = Proof.return(ctx.store, ctx.key)
    session = Proof.gesture(ctx.store, ctx.key, session, "traverse", "HUCKLEBERRY")
    assert session.apparatus.segment == 1
    assert session.standing.from == "ENZO"
  end

  test "ZIPPERING consequentializes and records its relation", ctx do
    session = zipper(ctx)
    assert session.standing.from == "HUCKLEBERRY"

    assert session.standing.consequence == %{
             operation: :zippering,
             from: "ENZO",
             to: "HUCKLEBERRY"
           }
  end

  test "ephemeral activity cannot silently consequentialize", ctx do
    session = zipper(ctx)
    standing = session.standing
    session = Proof.gesture(ctx.store, ctx.key, session, "traverse", "ENZO")
    assert session.standing == standing
    assert session.apparatus.toward == "ENZO"
  end

  test "RE-FOLD returns BY-WAY-OF consequence rather than later posture", ctx do
    session = zipper(ctx)
    session = Proof.gesture(ctx.store, ctx.key, session, "traverse", "ENZO")
    folded = Proof.refold(session)
    assert folded.apparatus == nil
    returned = Proof.return(ctx.store, folded.standing.by_way_of)
    assert returned.standing.from == "HUCKLEBERRY"
    assert returned.apparatus.regarding == "HUCKLEBERRY"
    assert returned.apparatus.segment == 0
    assert returned.apparatus != session.apparatus
  end

  test "material survives without viewport resurrection and may again be Regarded", ctx do
    session = zipper(ctx)
    session = Proof.gesture(ctx.store, ctx.key, session, "material", nil)
    session = Proof.gesture(ctx.store, ctx.key, session, "traverse", "ENZO")
    returned = Proof.return(ctx.store, Proof.refold(session).standing.by_way_of)
    assert returned.standing.material == %{"HUCKLEBERRY" => "A small leaf."}
    assert returned.standing.from == "HUCKLEBERRY"
    assert returned.apparatus.regarding == "HUCKLEBERRY"
    assert Proof.material(returned) == "A small leaf."
    assert returned.apparatus.segment == 0
  end

  test "the same Caterpillar data apparatus furnishes both standings", ctx do
    session = Proof.return(ctx.store, ctx.key)

    for name <- ["ENZO", "HUCKLEBERRY"] do
      furnished = Proof.gesture(ctx.store, ctx.key, session, "furnish", name)
      assert Proof.furnished(furnished) == Proof.catalogue()[name]
      assert furnished.standing.from == "ENZO"
    end
  end

  test "invalid and folded gestures cannot consequentialize", ctx do
    session = Proof.return(ctx.store, ctx.key)
    assert Proof.gesture(ctx.store, ctx.key, session, "zipper", "unknown") == session
    folded = Proof.refold(session)
    assert Proof.gesture(ctx.store, ctx.key, folded, "zipper", "HUCKLEBERRY") == folded
    assert Proof.gesture(ctx.store, ctx.key, session, "material", nil).standing.material == %{}
  end

  test "RE-ZIPPERING is explicit and retains material at its Standing", ctx do
    session = zipper(ctx)
    session = Proof.gesture(ctx.store, ctx.key, session, "material", nil)
    session = Proof.gesture(ctx.store, ctx.key, session, "rez ipper", "ENZO")
    assert session.standing.from == "HUCKLEBERRY"
    session = Proof.gesture(ctx.store, ctx.key, session, "rezipper", "ENZO")
    assert session.standing.from == "ENZO"
    assert session.standing.consequence.operation == :rezippering
    assert session.standing.material["HUCKLEBERRY"] == "A small leaf."
  end

  test "a stale apparatus cannot overwrite newer consequence or material", ctx do
    stale = Proof.return(ctx.store, ctx.key)
    session = zipper(ctx)
    Proof.gesture(ctx.store, ctx.key, session, "material", nil)
    fresh = Proof.gesture(ctx.store, ctx.key, stale, "regard", "ENZO")
    assert fresh.standing.from == "HUCKLEBERRY"
    assert fresh.standing.material["HUCKLEBERRY"] == "A small leaf."
    assert MemoryStore.load(ctx.store, ctx.key).from == "HUCKLEBERRY"
  end

  defp zipper(ctx) do
    Proof.gesture(ctx.store, ctx.key, Proof.return(ctx.store, ctx.key), "zipper", "HUCKLEBERRY")
  end
end
