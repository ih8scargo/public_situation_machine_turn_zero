defmodule PublicSituationMachineTurnZero.Workshop.DrawOut do
  @moduledoc "Read-only inspection of a provisional Projectioning presentation."
  alias PublicSituationMachineTurnZero.Workshop.Projection

  def witness(model, registry, mode) do
    crossing = model["entities"]["central"]
    [left, bottom, _near] = crossing["frame"]["origin"]
    [width, height, depth] = crossing["dimensions"]
    right = left + width
    forward = right + width
    top = bottom + height

    projection = model["projection"]
    %{"point" => craft} = Projection.cob(projection, model["rehearsal"]["progress"])
    [_, craft_y, craft_z] = craft
    materials = Map.new(registry["items"], &{&1["id"], &1})
    here = materials["HERE"]
    next = materials["NEXT"]
    xs = Enum.map(next["points"], &hd/1)
    x_min = Enum.min(xs)
    source_width = Enum.max(xs) - x_min

    # The existing rehearsal course advances along +X. Stretch only a copy of NEXT.
    prospective =
      Enum.map(next["points"], fn [x, _y, z] ->
        [right + width * (x - x_min) / source_width, top, z]
      end)

    eye_y = craft_y + height / 6
    eye_z = craft_z + depth / 3

    project =
      case mode do
        "tunnel" ->
          # Look along the existing course. The sight point is one base width behind
          # the Crossing, so registered geometry remains in front of the view plane.
          fn [x, y, z] ->
            scale = 200 / (x - (left - width))
            {320 + (z - eye_z) * scale, 176 - (y - eye_y) * scale}
          end

        "side" ->
          fn [x, y, z] -> {74 + (x - left) * 41 + z * 6, 244 - (y - bottom) * 25 - z * 6} end
      end

    outlines =
      for surface <- crossing["surfaces"] do
        Enum.map(surface["vertices"], &Enum.at(crossing["vertices"], &1))
        |> polyline(project)
      end

    zs = Enum.map(next["points"], &Enum.at(&1, 2))
    z_center = (Enum.min(zs) + Enum.max(zs)) / 2
    head = [forward, top, z_center]
    threshold = [right, top, z_center]
    sight = if mode == "tunnel", do: {320, 176}, else: nil

    %{
      outlines: outlines,
      here: polyline(here["points"], project),
      here_provenance: here["provenance"]["source"],
      next_provenance: next["provenance"]["source"],
      prospective: polyline(prospective, project),
      prospective_world: prospective,
      craft: project.(craft),
      craft_world: craft,
      standing:
        Enum.map(model["rehearsal"]["footings"], fn footing ->
          point = projection |> Projection.material(footing) |> get_in(["vertical", "point"])

          %{
            point: project.(point),
            id: footing["id"],
            letter: footing["letter"],
            sequence: footing["sequence"]
          }
        end),
      up_over: polyline([[right, craft_y, z_center], threshold], project),
      head: project.(head),
      return: polyline([head, threshold], project),
      sight: sight,
      datum: if(sight, do: screen_points([sight, project.(head)])),
      ticks: for(x <- [left, right, forward], do: {x, project.([x, bottom, 0])}),
      width: width
    }
  end

  defp polyline(points, project), do: points |> Enum.map(project) |> screen_points()
  defp screen_points(points), do: Enum.map_join(points, " ", fn {x, y} -> "#{x},#{y}" end)
end
