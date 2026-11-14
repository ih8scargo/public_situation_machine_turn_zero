defmodule PublicSituationMachineTurnZero.Workshop.BearingRegistrationStudyTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.BearingRegistrationStudy

  test "the two 45° bearings terminate before the registered face" do
    %{face_match: true, area: 9, trials: [a, b, control]} = BearingRegistrationStudy.model()
    assert_in_delta a.elevation, 45, 1.0e-10
    assert_in_delta b.elevation, 45, 1.0e-10
    assert a.bearing == [[0, 0, 0], [3, 3, 0]]
    assert a.plane_hit == nil
    assert [3.0, height, 3.0] = b.plane_hit
    assert_in_delta height, 3 * :math.sqrt(2), 1.0e-10
    assert a.face_hit == nil and b.face_hit == nil
    refute a.point_match or b.point_match
    assert control.point_match
    assert control.face_hit == [3.0, 3.0, 3.0]
    assert_in_delta control.elevation, 35.26438968, 1.0e-8
  end

  test "finite trials distinguish unjoined clearances from collisions at the registered corner" do
    %{trials: [a, b, control]} = BearingRegistrationStudy.model()
    refute a.overlap or b.overlap
    assert control.overlap
    assert Enum.count(control.hinge, & &1.overlap) == 8
    assert List.last(a.hinge).seam_aperture == :outside_radius

    for trial <- [a, b, control] do
      refute trial.end_match
      refute trial.trial_combined_aperture
      assert trial.footprints == [false, false]
      assert trial.workshop_aperture == :outside_radius
      assert length(trial.hinge) == 9
      assert Enum.all?(trial.hinge, &(&1.length_error < 1.0e-12))
      refute Enum.any?(trial.hinge, & &1.both_fit_six)
      refute List.last(trial.hinge).newest_nearest
    end
  end
end
