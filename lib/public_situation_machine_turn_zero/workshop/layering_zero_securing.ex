defmodule PublicSituationMachineTurnZero.Workshop.LayeringZeroSecuring do
  @moduledoc "Finite joint specimens in the Round One world frame."
  alias PublicSituationMachineTurnZero.Workshop.{CoBuildingGeometry, MaterialRibbon}
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def specimens([x, y, z], [_, _, axle_z], terminal) do
    [tx, ty, tz] = terminal
    at = fn dx, dy, dz -> M.add(terminal, [dx, dy, dz]) end

    [
      solid("securing:xt-stock", "XT TO XT · local ONE stock", [x - 0.05, y - 0.07, axle_z], [
        x + 0.05,
        y,
        z
      ]),
      solid(
        "securing:pitton",
        "Groundward PITTON · through local stock",
        [
          x - 0.024,
          y - 0.27,
          z - 0.18
        ],
        [x + 0.024, y + 0.045, z - 0.132]
      ),
      solid(
        "securing:pitton-head",
        "PITTON · shoulder against XT top",
        [
          x - 0.072,
          y,
          z - 0.24
        ],
        [x + 0.072, y + 0.045, z - 0.072]
      ),
      solid(
        "securing:axle-shoe",
        "Square axle shoe · bent stock interface",
        [
          x - 0.13,
          y - 0.12,
          axle_z - 0.13
        ],
        [x + 0.13, y, axle_z + 0.13]
      ),
      solid(
        "securing:ground-purchase",
        "Ground band · PITTON embedment witness",
        [
          x - 0.22,
          y - 0.36,
          z - 0.38
        ],
        [x + 0.22, y - 0.07, z + 0.04]
      ),
      pinning_eye(at),
      solid(
        "securing:pin",
        "JANUSITE PINNING · square pin in circular eye",
        at.(-0.024, -0.055, -0.024),
        at.(0.024, 0.19, 0.024)
      ),
      terminal_ribbon(at),
      solid(
        "securing:cartridge-floor",
        "Situation Cartridge · receiving floor",
        at.(-0.08, -0.073, -0.12),
        at.(0.29, -0.041, 0.12)
      ),
      solid(
        "securing:cartridge-left",
        "Situation Cartridge · left guide",
        at.(-0.08, -0.041, -0.12),
        at.(0.29, 0.10, -0.074)
      ),
      solid(
        "securing:cartridge-right",
        "Situation Cartridge · right guide",
        at.(-0.08, -0.041, 0.074),
        at.(0.29, 0.10, 0.12)
      ),
      solid(
        "securing:cartridge-stop",
        "Situation Cartridge · terminal stop",
        at.(0.25, -0.041, -0.074),
        at.(0.29, 0.10, 0.074)
      ),
      solid(
        "securing:string-key",
        "Appointed terminal String · captive key",
        at.(0.11, -0.04, -0.058),
        at.(0.25, 0.034, 0.058)
      ),
      solid(
        "securing:zip-dog",
        "COB OVER seam · return latch",
        [
          tx + 0.064,
          ty - 0.035,
          tz - 0.070
        ],
        [tx + 0.11, ty + 0.11, tz + 0.070]
      )
    ]
  end

  defp pinning_eye(at) do
    geometry = G.pipe([at.(0, 0.084, 0), at.(0, 0.134, 0)], 0.106, 0.042, 16)
    specimen("securing:pin-eye", "JANUSITE PINNING · bend-side pivot eye", geometry)
  end

  defp terminal_ribbon(at) do
    path = [at.(-0.46, 0.17, 0), at.(-0.28, 0.17, 0), at.(-0.12, 0.115, 0), at.(0, 0.109, 0)]

    specimen(
      "securing:janusite",
      "JANUSITE · continuous terminal bend",
      G.sweep(path, 0.095, 0.03),
      [path]
    )
  end

  defp solid(id, label, min, max), do: specimen(id, label, G.box(min, max))

  defp specimen(id, label, geometry, paths \\ []) do
    %{id: id, label: label, kind: "securing", faces: geometry.faces, paths: paths}
  end
end
