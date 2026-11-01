defmodule PublicSituationMachineTurnZero.Architecture.ApplianceCutaway do
  @moduledoc "One appliance frame and one inward Diorama frame. Parameters are experimental; the six relations are not duplicated."
  def model(floor \\ -1.2) do
    %{
      "version" => "appliance-cutaway-v1",
      "status" => "experimental approach proportions",
      "appliance_extent" => %{
        "id" => "appliance-cubical-frame",
        "min" => [-4.8, -4.8, -2],
        "max" => [4.8, 4.8, 13.2]
      },
      "diorama_extent" => %{
        "id" => "local-diorama-cubical-frame",
        "min" => [-3.6, floor, 0],
        "max" => [3.6, 3.6, 13.2],
        "basis" => "projection_body.square_embedding",
        "recursive_children" => []
      },
      "crossing" => %{
        "id" => "projectioning-crossing",
        "z" => -2,
        "default_half" => 3.2,
        "min_half" => 1.8,
        "max_half" => 4.0
      },
      "approach" => %{
        "mouth_half" => 3.6,
        "depth" => 2.0,
        "floor_y" => -1.2,
        "left" => "approaching-left",
        "right" => "approaching-right"
      },
      "floor_y" => floor,
      "camera_center" => [0, 0, 5.5],
      "camera_distance" => 24,
      "destination_is_seat" => false,
      "reserved_seat" => %{
        "id" => "aperture-seat-reserve-v1",
        "point" => [0, floor + 0.35, 0.35],
        "facing" => [0, 0, 1],
        "source" => "aperture-available",
        "status" => "future Seat WITH COB, beneath aperture; not seated"
      },
      "resolutioning_source" =>
        "one retained projection_foundation, six provisional possibilities"
    }
  end
end
