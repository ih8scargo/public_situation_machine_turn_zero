defmodule PublicSituationMachineTurnZero.Workshop.LayeringZero do
  @moduledoc "Source registry for the first standing-appliance rehearsal."
  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuilding,
    CoBuildingGeometry,
    GeometryExploration,
    LayeringZeroOpening,
    MaterialRibbon,
    SnailBody
  }

  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  @center [3, 0, -3]
  @references ~w(cb:monitor cb:glass cb:seat cb:square-axle cb:table cb:zero-square cb:HERE cb:local-unit cb:wedge-A cb:wedge-B)

  def model do
    inherited = CoBuilding.model(CoBuilding.new())
    direction = M.unit([0.3, :math.sqrt(1.09), 1])
    at = fn t -> M.add(@center, M.scale(direction, t)) end
    crossing = at.(2 / Enum.at(direction, 2))
    coil = Enum.map(0..144, &coil_point(&1 / 144))
    ceiling = [inherited.one |> hd(), 6, Enum.at(inherited.one, 2)]

    references =
      for id <- @references do
        part = CoBuilding.selected(inherited, id)
        piece(id, part.name, "reference", part.source_geometry.faces, Map.get(part, :lines, []))
      end

    terminal = [7.5, 4, -2]

    course = [
      line("cob:approach", "COB · FROM Seat TOWARD prospective ceiling", "approach", [
        inherited.one,
        M.add(inherited.one, [0, 3, 0]),
        ceiling
      ]),
      line("cob:bank", "COB · bank into current ROUNDABOUT", "course", [
        ceiling,
        [4.5, 1.1, -3],
        hd(coil)
      ]),
      line("cob:roundabout", "COB · current ROUNDABOUT candidate", "course", Enum.take(coil, 97)),
      line(
        "cob:return",
        "COB · inherited YT / potential next XT",
        "return",
        Enum.drop(coil, 96) ++ [[1.5, 0.12, -5.52], [6.5, 4, -2], terminal]
      )
    ]

    opening = LayeringZeroOpening.build(@center, inherited.one)
    shift = M.sub(opening.midpoint, @center)
    {first, aperture} = footing(1, "first", shift, 1)
    {blocked, _} = footing(1, "blocked", [0, 0, 0], 1)
    {alongside, _} = footing(2, "alongside", M.add(shift, [0.25, 0, 0]))
    {stacked, _} = footing(2, "stacked", M.add(shift, [0, -0.19, 0]))

    %{
      version: "layering-zero-round-one.v3",
      center: @center,
      seat: inherited.one,
      table: inherited.three,
      zero: inherited.zero,
      crossing: crossing,
      monitor_z: -1,
      ceiling: ceiling,
      opening: Map.delete(opening, :pieces),
      pieces:
        references ++
          doors() ++
          [
            line("xt:zero-one", "ZERO TO ONE · Groundward extent", "datum", [
              inherited.zero,
              @center,
              inherited.one
            ]),
            line("transverse:axis", "XT TOWARD YT · source bearing", "datum", [
              at.(-0.65),
              at.(4.5)
            ]),
            piece(
              "transverse:bar",
              "XT TOWARD YT · historical solid-strip control",
              "bar",
              G.strap(at.(-0.65), at.(4.5), 0.25, 0.055, M.unit(M.cross(direction, [1, 0, 0]))).faces
            ),
            line("monitor:intersection", "Monitor-plane intersection", "crossing", [crossing]),
            line(
              "monitor:projection",
              "Flat Projectioning of source bearing",
              "projection",
              Enum.map([at.(-0.65), at.(4.5)], fn [x, y, _] -> [x, y, -1] end)
            ),
            line("snail:coil", "Invariant local coil · complete native profile", "coil", coil),
            piece(
              "footing:opening",
              "Central opening · cut section edges",
              "opening",
              [],
              aperture
            ),
            first,
            blocked,
            alongside,
            stacked
          ] ++ letters(at) ++ course ++ opening.pieces
    }
  end

  defp coil_point(t) do
    [x, y, z] = SnailBody.arc_point(t)
    M.add(@center, [x * 1.5 / 0.85, y + 0.55, z * 1.5 / 0.85])
  end

  defp doors do
    for i <- 0..7 do
      start = (i - 0.5) / 8
      finish = (i + 0.5) / 8

      rim = fn t, r, y ->
        angle = t * 2 * :math.pi()
        M.add(@center, [r * :math.cos(angle), y, r * :math.sin(angle)])
      end

      # Boundary traces remain inspectable even where there is no shell stock.
      outline = Enum.map(0..8, &rim.(start + (finish - start) * &1 / 8, 1.5, 0))
      boundary = [@center | outline] ++ [@center]
      id = "gallery-door:#{i + 1}"
      door = piece(id, "Gallery Door #{i + 1}", "door", [], [boundary])

      shell =
        for {side, sign} <- [{"upper", 1}, {"lower", -1}] do
          faces =
            for j <- 0..7,
                t = start + (finish - start) * j / 8,
                next = start + (finish - start) * (j + 1) / 8,
                # Bind the open quarter and the separate eighth to exact angular edges.
                phase = rem(i * 8 + j + 60, 64),
                phase not in 16..31 and phase not in 48..55 do
              [
                rim.(t, 1.25, sign * 0.10),
                rim.(next, 1.25, sign * 0.10),
                rim.(next, 1.56, sign * 0.35),
                rim.(t, 1.56, sign * 0.35)
              ]
            end

          piece("#{id}:#{side}", "Gallery Door #{i + 1} · #{side} shell", side, faces)
        end

      [door | shell]
    end
    |> List.flatten()
  end

  defp footing(n, kind, shift, trim \\ 1) do
    source = GeometryExploration.coil(n)
    pose = fn p -> p |> M.sub(source.entrance) |> M.add(@center) |> M.add(shift) end
    # Retain the same coil address and remove equal stock at both sides of the center.
    faces = source.segments |> Enum.slice(trim, 32 - 2 * trim) |> Enum.flat_map(& &1.faces)

    cut_edges =
      for section <- [Enum.at(source.sections, trim), Enum.at(source.sections, 32 - trim)] do
        corners = Enum.map(section.corners, pose)
        corners ++ [hd(corners)]
      end

    material =
      piece(
        "footing:#{kind}",
        "Little ROUNDING Footing · #{kind}",
        kind,
        Enum.map(faces, &Enum.map(&1, pose))
      )

    {material, cut_edges}
  end

  defp letters(at) do
    glyphs = %{
      "X" => ~w(101 101 010 101 101),
      "T" => ~w(111 010 010 010 010),
      "Y" => ~w(101 101 010 010 010)
    }

    for {glyph, address, i} <- [{"X", 0.45, 1}, {"T", 1.05, 2}, {"Y", 3.35, 3}, {"T", 4.0, 4}] do
      faces =
        for {row, y} <- Enum.with_index(glyphs[glyph]),
            {"1", x} <- Enum.with_index(String.graphemes(row)),
            origin = M.add(at.(address), [(x - 1) * 0.063, (4 - y) * 0.063 + 0.027, 0]),
            face <- G.box(origin, M.add(origin, [0.063, 0.063, 0.085])).faces,
            do: face

      piece("transverse:letter:#{i}", glyph, "letter", faces)
    end
  end

  defp line(id, label, kind, points), do: piece(id, label, kind, [], [points])

  defp piece(id, label, kind, faces, paths \\ []),
    do: %{id: id, label: label, kind: kind, faces: faces, paths: paths}
end
