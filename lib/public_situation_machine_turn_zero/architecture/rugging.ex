defmodule PublicSituationMachineTurnZero.Architecture.Rugging do
  @moduledoc "Derived Rugging geometry rehearsal. No furnishing events or change of Human FROM."
  alias PublicSituationMachineTurnZero.Architecture, as: A

  def presentation(m) do
    if !A.legacy?(m) do
      g = m.standing["opening_geometry"]
      frame = g["wireframe"] || %{"min" => [-1.2, -1.2, 0], "max" => [1.2, 1.2, 2.4]}
      [_, floor, near] = frame["min"]
      [_, ceiling, far] = frame["max"]

      %{
        "pivot" => [0, floor, (near + far) / 2],
        "radius" => g["circle"]["radius"],
        "circle_identity" => "opening-circle-available",
        "responsibility" => "THIS ONE CONSTITUTIONING HUMAN'S STANDINGING LANDINGING FROM HERE",
        "floor_y" => floor,
        "ceiling_y" => ceiling,
        "near" => near,
        "far" => far,
        "ground_start" => [0, floor, near - 3.2],
        "field_available" => A.opened?(m),
        "seating_available" => A.furnished?(m, "aperture-available"),
        "gallery_available" => A.furnished?(m, "drawer-extent-standing"),
        "aperture_reference" => "aperture-available",
        "source" => if(A.opened?(m), do: "opening-accomplished", else: "human-standing"),
        "status" => "provisional geometric rehearsal; no new FROM"
      }
    end
  end
end
