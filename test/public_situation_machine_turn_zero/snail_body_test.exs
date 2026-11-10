defmodule PublicSituationMachineTurnZero.SnailBodyTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{SnailBody, WedgingGeometry}
  alias SnailBody, as: B

  defp act(s, c) do
    assert {:ok, n} = B.operate(s, c)
    n
  end

  defp length_of(points),
    do:
      Enum.zip(points, tl(points))
      |> Enum.map(fn {a, b} -> WedgingGeometry.distance(a, b) end)
      |> Enum.sum()

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))

  test "all fold alternatives and quarter localities retain standing; shared surfaces rotate isometrically into downward openings" do
    s = B.new()
    fixed = B.model(s).fixed

    for q <- 0..5, angle <- [0, 30, 45, 60, 90] do
      m = B.model(s, angle, q)
      assert m.fixed == fixed
      assert_in_delta WedgingGeometry.distance(m.within_eye, m.fold.tunnel_axis), 0.08, 1.0e-10
      assert_in_delta dot(sub(m.within_eye, m.fold.tunnel_axis), m.fold.normal), 0.08, 1.0e-10
      assert_in_delta dot(m.fold.normal, m.fold.normal), 1, 1.0e-10
      assert_in_delta length_of(m.fold.shared_points), 0.48, 1.0e-10

      for p <- m.fold.mouth do
        assert_in_delta dot(sub(p, m.fold.center), m.fold.normal), 0, 1.0e-10
      end

      for {a, b} <- Enum.zip(m.fold.mouth, m.fold.far) do
        assert_in_delta WedgingGeometry.distance(a, b), 0.35, 1.0e-10
      end

      if angle == 90, do: assert_in_delta(Enum.at(m.fold.normal, 1), -1, 1.0e-10)
      [a, b] = m.fold[:XT_to_YT]
      [c, d] = m.fold[:YT_to_XT]
      assert a == d && b == c
    end

    assert Enum.at(B.model(s, 0).fold.normal, 1) == 0
  end

  test "side port is an actual cutout, corner reflection is perpendicular, projection has distinct coplanar surfaces, shield blocks direct top access" do
    m = B.model(B.new())
    i = m.instrumentation
    [side, corner, inner, _] = i.path
    assert hd(side) == -1.45
    incoming = sub(corner, side)
    outgoing = sub(inner, corner)
    assert_in_delta dot(incoming, outgoing), 0, 1.0e-10

    reflected =
      Enum.zip_with(incoming, i.reflection_normal, fn v, n ->
        v - 2 * dot(incoming, i.reflection_normal) * n
      end)

    assert_in_delta hd(reflected), 0, 1.0e-10
    assert Enum.at(reflected, 2) > 0
    refute Enum.any?(m.surfaces, &(&1.id == "cabinet-5"))
    assert Enum.uniq(Enum.map(i.inner, &Enum.at(&1, 2))) == [0.75]
    assert Enum.all?(i.monitor, &(abs(Enum.at(&1, 2) - 1.4) < 1.0e-10))
    assert i.inner != i.monitor
    assert m.separation.direct_vertical_access == false
    assert m.separation.shield_bottom > m.separation.computer_top
    assert m.separation.table_opening_radius < 0.45
  end

  test "held time has no timer; exact bobbin conservation, archived line/material and readying without PINNING survive replay" do
    s = B.new()
    fixed = B.model(s).fixed
    assert {:error, :condition} = B.operate(s, {:withdraw, 500})

    s =
      s
      |> act(:take)
      |> act({:withdraw, 1250})
      |> act({:quill, "A retained Quilling witness"})
      |> act({:withdraw, 750})

    held = s["held"]
    material = s["material"]
    trace = List.last(s["pieces"])["line_trace"]
    assert_in_delta length_of(B.model(s).line.visible), 2, 1.0e-10
    s = act(s, :return)
    assert s["held"] == nil && s["needle"] == "gathering"
    assert {:error, :condition} = B.operate(s, :take)
    assert {:error, :condition} = B.operate(s, {:gather, 2001})
    s = act(s, {:gather, 500})
    assert s["outstanding"] == 1500 && s["gathered"] == 500
    assert_in_delta length_of(B.model(s).line.visible), 1.5, 1.0e-10
    s = act(s, {:gather, 1500})
    assert s["withdrawn"] == s["outstanding"] + s["gathered"]
    assert s["ready_for_pinning"] && s["needle"] == "inkwell"
    assert s["material"] == material
    assert List.last(s["pieces"])["id"] == held
    assert List.last(s["pieces"])["line_trace"] == trace
    assert B.model(s).fixed == fixed
    assert {:ok, ^s} = B.import(B.export(s))
    corrupt = put_in(s, ["gathered"], 1999)
    assert {:error, :invalid_witness} = B.import(B.export(corrupt))
    assert {:error, :condition} = B.operate(s, {:quill, "not held"})
    next = act(s, :take)
    assert next["held"] != held && next["material"] == material
    assert next["withdrawn"] == next["outstanding"] + next["gathered"]
  end

  test "zero-line return readies directly; negative, excessive and malformed witness amounts are rejected" do
    s = B.new() |> act(:take)

    for n <- [-1, 0, 3001, 0.5, "500"],
        do: assert({:error, :condition} == B.operate(s, {:withdraw, n}))

    s = act(s, :return)
    assert s["ready_for_pinning"]
    assert {:error, :invalid_witness} = B.import("{}")
    assert {:error, :invalid_witness} = B.import(String.duplicate("x", 1_000_001))
    # All legal material at the run bound must remain exportable/restorable.
    full =
      Enum.reduce(1..158, B.new() |> act(:take), fn _, acc ->
        act(acc, {:quill, String.duplicate("Q", 2000)})
      end)
      |> act(:return)

    exported = B.export(full)
    assert byte_size(exported) > 500_000
    assert {:ok, ^full} = B.import(exported)
  end
end
