defmodule PublicSituationMachineTurnZero.Architecture.Diorama do
  @moduledoc "Read-only rehearsal of two inherited CUBICAL faces. Never furnishes standing."
  alias PublicSituationMachineTurnZero.Architecture, as: A
  @reserve Path.expand("../../../docs/machine-instructionings/material-reserve.json", __DIR__)
  @external_resource @reserve
  @markings @reserve |> File.read!() |> Jason.decode!()

  def markings, do: @markings

  def presentation(m) do
    if !A.legacy?(m) && A.complete?(m) do
      %{
        "reference" => m.standing["opening_geometry"]["wireframe"],
        "ancestry" => ["opening-accomplished", "aperture-available", "pointingable-standing"],
        "status" => "provisional mechanical rehearsal",
        "markings" => Enum.filter(@markings, &(&1["region"] != nil))
      }
    end
  end
end
