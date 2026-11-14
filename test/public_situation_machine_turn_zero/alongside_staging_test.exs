defmodule PublicSituationMachineTurnZero.AlongsideStagingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{AlongsideStaging, GeometryExploration}
  alias AlongsideStaging, as: A
  alias GeometryExploration, as: G

  defp step(s, command) do
    {:ok, next, _, _} = A.command(s, command)
    next
  end

  defp furnish(s, angle),
    do:
      s
      |> step({:pivot, angle})
      |> step(:appoint_wedging)
      |> step(:stage)
      |> step(:retain_furnishing)

  test "inherited fixture and new stage share opening, not acquisition or source identity" do
    s = A.new() |> step({:pivot, 30}) |> step(:appoint_wedging) |> step(:stage)
    model = A.model(s)
    assert s.inherited.status == :already_standing_reference
    assert s.staged.status == :newly_staged
    assert s.inherited.acquisition == :not_attested
    assert s.staged.acquisition == :not_acquired
    refute s.inherited.id == s.staged.id
    assert s.staged.alongside == s.inherited.id
    assert model.projection.material_ids == [s.inherited.id, s.staged.id]
    assert model.projection.opening == model.aperture.id

    assert Enum.all?(
             model.materials,
             &(&1.relation == "UP FROM HERE OVER ACROSS" and
                 not &1.from_down_under)
           )

    assert Enum.any?(
             model.relationships,
             &(&1.subject == s.staged.id and &1.relation == "FROM OVER ACROSS")
           )

    assert model.future_relation.status == :not_established
    assert model.future_relation.actual_material_ids == []
  end

  test "camera pivot alone changes appearance but not appointment, aperture, material or axle" do
    s = A.new() |> furnish(30)
    before = A.model(s)
    next = step(s, {:pivot, 60})
    assert A.model(next) == before
    assert next.target == s.target
    assert next.furnished == s.furnished

    refute A.project(s.inherited.vertices, "flat", 30) ==
             A.project(s.inherited.vertices, "flat", 60)

    assert step(next, :appoint_wedging).target.angle == 60
    assert s.target.angle == 30
  end

  test "stage requires explicit appointment and cannot replace an existing staged specimen" do
    s = A.new()
    {:ok, next, :blocked_staging, _} = A.command(s, :stage)
    assert next.staged == nil
    s = s |> step({:pivot, 30}) |> step(:appoint_wedging) |> step(:stage)
    moved = s |> step({:pivot, 60}) |> step(:appoint_wedging)
    {:ok, blocked, :blocked_staging, _} = A.command(moved, :stage)
    assert blocked.staged == s.staged
    retained = step(blocked, :retain_furnishing)
    assert hd(retained.furnished).id == s.staged.id
    assert hd(retained.furnished).vertices == s.staged.vertices
    assert hd(retained.furnished).status == :candidate_furnished
  end

  test "successive furnishings derive a control deflection, not a pre-drawn occupied axle" do
    s = A.new()
    assert A.model(s).axle.points == [s.inherited.center]
    assert A.model(s).axle.deflections == []
    one = furnish(s, 30)
    assert length(A.model(one).axle.points) == 2
    assert A.model(one).axle.deflections == []
    two = furnish(one, 60)
    model = A.model(two)
    assert length(model.axle.points) == 3
    assert length(model.axle.deflections) == 1
    assert_in_delta hd(model.axle.deflections), 30, 1.0e-8
    assert model.axle.occupied_curvature == :unproved
    assert model.axle.basis == Enum.map([two.inherited | two.furnished], & &1.id)
    assert A.model(step(two, {:pivot, 90})).axle == model.axle
    assert Enum.at(two.furnished, 1).inherited_furnishing == [hd(two.furnished).id]
  end

  test "occupied duplicate and out-of-frame proposals preserve prior material" do
    s = A.new() |> step(:appoint_wedging)
    {:ok, blocked, :blocked_staging, result} = A.command(s, :stage)
    assert blocked.staged == nil
    assert result.operation == :staging
    s = A.new() |> step({:pivot, 90}) |> step(:appoint_wedging)
    {:ok, blocked, :blocked_staging, result} = A.command(s, :stage)
    assert :occupied_material_outside_registered_frame in result.missing
    assert A.materials(blocked) == A.materials(s)
  end

  test "acquisition and COB scan cannot establish FROM DOWN UNDER or authorize another frame" do
    s = A.new() |> furnish(30) |> furnish(60)

    for action <- [:acquire_landing, :cob_scan] do
      {:ok, blocked, :blocked_staging, _} = A.command(s, action)
      assert A.materials(blocked) == A.materials(s)
      refute blocked.human_frame_acquired
      refute blocked.landinging_acquired
      refute blocked.from_down_under
      refute A.model(blocked).work.permitted
      assert A.model(blocked).work.actual_cob == nil
      refute Enum.any?(A.model(blocked).relationships, &(&1.relation == "FROM DOWN UNDER"))
    end

    assert {:error, :unsupported_staging_operation} = A.command(s, {:from_down_under, true})
  end

  test "master revision guard records distinct stages and preserves B, framing and index" do
    initial = G.new()

    commands = [
      {:pivot, 30},
      :appoint_wedging,
      :stage,
      :retain_furnishing,
      :acquire_landing,
      :cob_scan
    ]

    final =
      Enum.reduce(commands, initial, fn command, s ->
        {:ok, next} = G.operate(s, s.revision, {:staging, command})
        next
      end)

    assert Enum.map(final.events, & &1.kind) == [
             :regarding_pivot,
             :human_appointment,
             :material_staged,
             :candidate_material_furnished,
             :blocked_staging,
             :blocked_staging
           ]

    assert final.index == 0 and final.from == "ZERO"
    assert G.model(final).frame == G.model(initial).frame
    assert G.model(final).turn_measure == G.model(initial).turn_measure
    assert G.model(final).turn_measure.prospective_join.next_extent_status == :not_furnished
    assert {:error, :stale_or_session_limit} = G.operate(final, 0, {:staging, {:pivot, 60}})
    assert List.last(final.events).staging_provenance.from_down_under == false
  end

  test "finite surfaces and stable material identity survive flat/transverse/plan views" do
    s = A.new() |> furnish(30) |> furnish(60)

    for material <- A.materials(s) do
      assert length(material.vertices) == 8
      assert length(material.faces) == 6
      assert material.thickness == 0.03
      assert material.frame == "exploration-six-v1"
      assert "current-turn:xt-toward-yt-measure" in material.ancestry

      for view <- ~w(flat transverse plan),
          do: assert(is_binary(A.project(material.vertices, view, 60)))
    end

    assert {:error, :unknown_material} = A.command(s, {:inspect, "invented-segmentation"})
  end
end
