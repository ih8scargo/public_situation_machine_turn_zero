defmodule PublicSituationMachineTurnZero.SnailNearMonitorTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailEmergence,
    SnailNearMonitor
  }

  defp model(s) do
    base = SnailWeaveGeometry.model(s)
    g = Map.put(base, :emergence, SnailEmergence.model(s, base))
    SnailNearMonitor.model(s, g)
  end

  test "empty and merely retained material do not silently furnish monitor staging" do
    s = SnailWeave.new()
    assert model(s).flat.material == nil

    {:ok, saved} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    # Registration, not presence in the material collection, supplies the presentation.
    unregistered = %{saved | "turns" => []}
    assert length(unregistered["body"]["material"]) > 0
    assert model(unregistered).flat.material == nil
  end

  test "registered material maps right on the same monitor plane; frames and source remain distinct" do
    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    before = SnailWeave.export(s)
    m = model(s)
    assert m.flat.material["id"] == List.last(s["turns"])["material"]
    [a, b] = m.flat.center_line
    assert hd(a) == hd(b)
    assert hd(m.flat.staging_point) > hd(a)
    assert Enum.at(m.flat.staging_point, 2) == Enum.at(a, 2)

    assert m.cubical.earlier_regions["ch"]["frame"]["origin"] !=
             m.cubical.earlier_regions["tc"]["frame"]["origin"]

    assert m.cubical.snail_seat == [0, 0, 0]
    assert m.cubical.native_seat.point == [0, -0.85, 0.35]
    assert length(m.orientation) == 8
    assert SnailWeave.export(s) == before
  end
end
