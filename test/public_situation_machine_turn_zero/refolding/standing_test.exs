defmodule PublicSituationMachineTurnZero.Refolding.StandingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Refolding.{Proof, MemoryStore}

  setup do
    store = start_supervised!({MemoryStore, []})
    key = "human"
    %{store: store, key: key, session: Proof.return(store, key)}
  end

  test "Regard makes material Regardable FROM THERE without authority to change it", ctx do
    session = act(ctx, ctx.session, "regard")
    assert session.standing.from == "ENZO"
    assert Proof.material(session) == "THIS ONE LEASHING"
    assert session.apparatus.regarding == "HUCKLEBERRY"
    assert session.apparatus.approached == nil
    assert session.apparatus.seated == nil
    assert session.apparatus.stepped == nil
    assert session.apparatus.furnishing == nil
    refute Proof.allowed?(session, "furnish", "HUCKLEBERRY")
    assert MemoryStore.load(ctx.store, ctx.key) == ctx.session.standing
  end

  test "APPROACH requires Regard and does not consequentialize or seat", ctx do
    assert act(ctx, ctx.session, "approach") == ctx.session
    session = through(ctx, ["regard", "approach"])
    assert session.apparatus.approached == "HUCKLEBERRY"
    assert session.apparatus.seated == nil
    assert session.standing.from == "ENZO"
  end

  test "Traversal requires the same approached Landinging and is not passage", ctx do
    assert act(ctx, ctx.session, "traverse") == ctx.session
    regarded = through(ctx, ["regard"])
    assert act(ctx, regarded, "traverse") == regarded
    approached = act(ctx, regarded, "approach")
    traversed = act(ctx, approached, "traverse")
    assert traversed.apparatus.segment == 1
    assert traversed.standing == ctx.session.standing
    assert act(ctx, traversed, "traverse", "ENZO") == traversed
  end

  test "SEATING requires Regard and Approach and establishes an inspectable relation", ctx do
    assert act(ctx, ctx.session, "seat") == ctx.session
    regarded = through(ctx, ["regard"])
    assert act(ctx, regarded, "seat") == regarded
    approached = act(ctx, regarded, "approach")
    assert approached.apparatus.seated == nil
    seated = act(ctx, approached, "seat")
    assert seated.apparatus.seated == "HUCKLEBERRY"
    assert seated.apparatus.stepped == nil
    assert seated.standing == ctx.session.standing
    assert act(ctx, seated, "seat", "ENZO") == seated
  end

  test "STEP requires Seating and makes furnishing available without changing FROM", ctx do
    for actions <- [[], ["regard"], ["regard", "approach"]] do
      session = through(ctx, actions)
      assert act(ctx, session, "step") == session
    end

    seated = through(ctx, ["regard", "approach", "seat"])
    stepped = act(ctx, seated, "step")
    assert stepped.apparatus.stepped == "HUCKLEBERRY"
    assert stepped.standing == ctx.session.standing
    assert Proof.allowed?(stepped, "furnish", "HUCKLEBERRY")
    refute Proof.allowed?(stepped, "zipper", "HUCKLEBERRY")
  end

  test "furnishing cannot skip any bodily prerequisite", ctx do
    for actions <- [[], ["regard"], ["regard", "approach"], ["regard", "approach", "seat"]] do
      session = through(ctx, actions)
      assert act(ctx, session, "furnish") == session
      assert session.standing.material == %{}
    end
  end

  test "lawful furnishing is a worked relation until ZIPPERING, not persisted material", ctx do
    session = prepared(ctx)

    assert session.apparatus.furnishing == %{
             standing: "HUCKLEBERRY",
             material: "THIS ONE LEASHING"
           }

    assert session.standing == ctx.session.standing
    assert MemoryStore.load(ctx.store, ctx.key) == ctx.session.standing
    returned = Proof.return(ctx.store, Proof.refold(session).standing.by_way_of)
    assert returned.standing.material == %{}
    assert returned.apparatus.furnishing == nil
    assert returned.apparatus.regarding == "ENZO"
  end

  test "ZIPPERING rejects every incomplete prefix of lawful labor", ctx do
    actions = ["regard", "approach", "seat", "step", "furnish"]

    for count <- 0..4 do
      session = through(ctx, Enum.take(actions, count))
      assert act(ctx, session, "zipper") == session
      assert MemoryStore.load(ctx.store, ctx.key) == ctx.session.standing
    end
  end

  test "ZIPPERING immediately consequentializes FROM and the worked Leashing relation", ctx do
    session = zipper(ctx)
    assert session.standing.from == "HUCKLEBERRY"
    assert session.standing.consequence.operation == :zippering
    assert session.standing.consequence.from == "ENZO"
    assert session.standing.consequence.to == "HUCKLEBERRY"
    assert session.standing.consequence.prior == ctx.session.standing.consequence
    assert session.standing.material == %{"HUCKLEBERRY" => "THIS ONE LEASHING"}
    assert MemoryStore.load(ctx.store, ctx.key) == session.standing
    assert session.apparatus.approached == nil
    assert session.apparatus.seated == nil
    assert session.apparatus.stepped == nil
    assert session.apparatus.furnishing == nil
  end

  test "invalid targets cannot borrow another Landinging's labor", ctx do
    session = prepared(ctx)

    for action <- ["approach", "traverse", "seat", "step", "furnish", "zipper"] do
      assert act(ctx, session, action, "ENZO") == session
      assert act(ctx, session, action, "unknown") == session
      assert act(ctx, session, action, nil) == session
    end
  end

  test "pivoting Regard relinquishes downstream relations rather than retaining authority", ctx do
    prepared = prepared(ctx)
    pivoted = act(ctx, prepared, "regard", "ENZO")
    assert pivoted.apparatus.approached == nil
    assert pivoted.apparatus.seated == nil
    assert pivoted.apparatus.stepped == nil
    assert pivoted.apparatus.furnishing == nil
    again = act(ctx, pivoted, "regard")

    for action <- ["traverse", "seat", "step", "furnish", "zipper"] do
      assert act(ctx, again, action) == again
    end

    assert MemoryStore.load(ctx.store, ctx.key) == ctx.session.standing
  end

  test "repeated Regard at the same locality does not manufacture additional labor", ctx do
    session = through(ctx, ["regard"])
    assert act(ctx, session, "regard") == session
    refute Proof.allowed?(session, "step", "HUCKLEBERRY")
    prepared = prepared(ctx)
    assert act(ctx, prepared, "regard") == prepared
  end

  test "ephemeral activity after ZIPPERING cannot rewrite consequence or material", ctx do
    zipped = zipper(ctx)

    session =
      Enum.reduce(["regard", "approach", "traverse", "seat", "step"], zipped, fn action, s ->
        act(ctx, s, action, "ENZO")
      end)

    assert session.apparatus.regarding == "ENZO"
    assert session.apparatus.segment == 1
    assert session.apparatus.stepped == "ENZO"
    assert session.standing == zipped.standing
    assert MemoryStore.load(ctx.store, ctx.key) == zipped.standing
  end

  test "RE-FOLD preserves already consequential Standing and material while folded", ctx do
    zipped = zipper(ctx)
    altered = act(ctx, zipped, "regard", "ENZO")
    folded = Proof.refold(altered)
    assert folded.apparatus == nil
    assert folded.standing == zipped.standing
    assert folded.standing.from == "HUCKLEBERRY"
    assert folded.standing.material == %{"HUCKLEBERRY" => "THIS ONE LEASHING"}
    assert Proof.refold(folded) == folded
    assert MemoryStore.load(ctx.store, ctx.key) == zipped.standing

    for action <- ["regard", "approach", "traverse", "seat", "step", "furnish", "zipper"] do
      assert act(ctx, folded, action) == folded
    end
  end

  test "return re-furnishes apparatus BY-WAY-OF HUCKLEBERRY without resurrecting posture", ctx do
    zipped = zipper(ctx)

    altered =
      Enum.reduce(["regard", "approach", "seat", "step", "traverse"], zipped, fn action, s ->
        act(ctx, s, action, "ENZO")
      end)

    returned = Proof.return(ctx.store, Proof.refold(altered).standing.by_way_of)
    assert returned.standing == zipped.standing
    assert Proof.material(returned) == "THIS ONE LEASHING"
    assert returned.apparatus.from == "HUCKLEBERRY"
    assert returned.apparatus.regarding == "HUCKLEBERRY"
    assert returned.apparatus.segment == 0
    assert returned.apparatus.approached == nil
    assert returned.apparatus.seated == nil
    assert returned.apparatus.stepped == nil
    assert returned.apparatus.furnishing == nil
    refute Proof.allowed?(returned, "zipper", "HUCKLEBERRY")
  end

  test "the one data-driven apparatus can furnish either differentiated Standing", ctx do
    assert Proof.furnished(ctx.session) == Proof.catalogue()["ENZO"]
    regarded = act(ctx, ctx.session, "regard")
    assert Proof.furnished(regarded) == Proof.catalogue()["HUCKLEBERRY"]
    assert regarded.apparatus.seated == nil
    assert regarded.standing.from == "ENZO"
  end

  test "removed shortcut and RE-ZIPPERING operations have no authority", ctx do
    assert act(ctx, ctx.session, "furnish") == ctx.session

    for session <- [ctx.session, prepared(ctx)] do
      assert act(ctx, session, "rezipper") == session
      assert act(ctx, session, "material") == session
    end

    zipped = zipper(ctx)
    assert act(ctx, zipped, "rezipper") == zipped
    assert act(ctx, zipped, "material") == zipped
  end

  test "stale prepared apparatus cannot ZIPPER a second time or overwrite material", ctx do
    prepared = prepared(ctx)
    zipped = act(ctx, prepared, "zipper")
    stale = act(ctx, prepared, "zipper")
    assert stale.standing == zipped.standing
    assert MemoryStore.load(ctx.store, ctx.key) == zipped.standing
    assert stale.apparatus.approached == nil
    assert stale.apparatus.furnishing == nil
    fresh = act(ctx, prepared, "regard", "ENZO")
    assert fresh.standing == zipped.standing
    assert fresh.apparatus.approached == nil
    assert fresh.apparatus.regarding == "ENZO"
  end

  defp act(ctx, session, action, target \\ "HUCKLEBERRY"),
    do: Proof.gesture(ctx.store, ctx.key, session, action, target)

  defp through(ctx, actions),
    do: Enum.reduce(actions, ctx.session, &act(ctx, &2, &1))

  defp prepared(ctx), do: through(ctx, ["regard", "approach", "seat", "step", "furnish"])
  defp zipper(ctx), do: act(ctx, prepared(ctx), "zipper")
end
