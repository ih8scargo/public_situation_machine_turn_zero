defmodule PublicSituationMachineTurnZero.SharedFaceStudyTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{GeometryExploration, SharedFaceStudy}

  setup do
    %{study: SharedFaceStudy.model()}
  end

  test "both inherited corners and complete faces match; the repeat translates by SIX", %{
    study: m
  } do
    [blue, yellow, third] = m.registrations
    assert blue.bearing == [[0, 0, 0], [3, 3, 3]]
    assert yellow.bearing == [[3, 3, 3], [0, 0, 6]]
    assert third.bearing == [[0, 0, 6], [3, 3, 9]]
    assert third.tangent == blue.tangent
    assert third.normal == blue.normal
    assert [blue.inside_parent, yellow.inside_parent, third.inside_parent] == [true, true, false]

    for {join, z} <- Enum.zip(m.handoffs, [3, 6]) do
      assert join.point_match and join.face_match
      assert join.shared_face == [[0, 0, z], [0, 3, z], [3, 0, z], [3, 3, z]]
      assert join.face_area == 9
      assert join.face_normals == [[0, 0, 1], [0, 0, -1]]
    end
  end

  test "straight finite bars fail angular and material continuity at both joints", %{study: m} do
    for join <- m.handoffs do
      assert_in_delta join.tangent_dot, -1 / 3, 1.0e-12
      assert_in_delta join.normal_dot, 1 / 3, 1.0e-12
      refute join.tangent_match
      refute join.normal_match
      refute join.material_boundary_match
      assert join.bearing_stock_overlap
    end
  end

  test "coil clearance and order are conditional on independent trial planes", %{study: m} do
    assert m.workshop_opening == %{
             id: "un-vanishing-aperture",
             center: [3, 3, 0],
             normal: [0, 0, 1]
           }

    assert m.aperture_status == :drawing_planes_unresolved
    assert m.common_aperture_control.segment_a == "coil-candidate-1:segment-0"
    assert m.common_aperture_control.segment_b == "coil-candidate-2:segment-0"
    assert Enum.all?(m.coil_pairs, &is_nil(&1.interference))
    assert m.newest_nearest_floor

    for {r, ordinal} <- Enum.with_index(m.registrations, 1) do
      assert_in_delta r.bearing_length, 3 * :math.sqrt(3), 1.0e-12
      assert r.coil.length == GeometryExploration.coil(ordinal).material_length
      assert r.coil.length > r.bearing_length
      assert r.coil.width == 0.16 and r.coil.thickness == 0.04
      assert r.coil.inside_parent == ordinal <= 2
      assert r.coil.through_trial_plane
      assert r.coil.trial_aperture.normal == [1, 0, 0]
    end

    assert m.registered_inside == m.minimum_capacity
    assert m.physical_capacity == :mechanism_unproved
    refute m.snail.fits_six_height
    assert List.last(m.snail.height_range) > 6
    assert m.optics == :unproved
  end

  test "inspection preserves material, frame, constitutional state and global diagonals" do
    state = GeometryExploration.new()
    before = GeometryExploration.model(state)
    assert {:ok, viewed} = GeometryExploration.operate(state, 0, {:experiment, 9})

    assert viewed.experiment == 9

    assert Map.take(viewed, [:from, :index, :frame_status, :coils, :staging]) ==
             Map.take(state, [:from, :index, :frame_status, :coils, :staging])

    assert GeometryExploration.model(viewed) == before
    assert Enum.find(before.references, &(&1.id == "diagonal-A")).points == [[0, 0, 0], [6, 6, 0]]
    assert before.turn_measure.points == [[0, 6, 0], [6, 0, 0]]
  end
end
