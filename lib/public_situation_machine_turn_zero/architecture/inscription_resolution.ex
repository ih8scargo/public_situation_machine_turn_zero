defmodule PublicSituationMachineTurnZero.Architecture.InscriptionResolution do
  # Geometry reconciliation: Curved letter source retains its version; ordinal correspondence does not appoint a physical metric transform.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc """
  THE/PUBLIC bend, PUBLIC/SITUATION face, N twist purchase and MACHINE return.
  Relations follow the Human's inscription scheme; arc planes, radii and width
  are trial drawing parameters. The physical twist angle remains unappointed.
  This derived projection does not rewrite Standing or an appointed instrument.
  """
  @words [{"THE", 0}, {"PUBLIC", 3}, {"SITUATION", 9}, {"MACHINE", 18}]
  @radius 1.6
  @half_width 0.18

  def model do
    letters =
      Enum.flat_map(@words, fn {word, offset} ->
        word
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.map(fn {letter, i} ->
          index = offset + i

          %{
            "id" => "inscription-letter-#{index}",
            "index" => index,
            "letter" => letter,
            "word" => word,
            "relations" =>
              memberships(word) ++ if(index == 18, do: ["situation-n-twist"], else: []),
            "samples" => Enum.map(0..8, &sample(index - 1 + &1 / 8))
          }
        end)
      end)

    %{
      "version" => "inscription-resolution-v1",
      "source" => "Human-supplied THE/PUBLIC/SITUATION/MACHINE scheme, 2026-11-03",
      "relations" => [
        relation("the-public-bend", ["THE", "PUBLIC"], "XT toward XT", nil),
        relation(
          "public-situation-face",
          ["PUBLIC", "SITUATION"],
          "XT toward YT",
          "the-public-bend"
        ),
        relation("situation-n-twist", ["SITUATION"], nil, "public-situation-face"),
        relation("machine-return", ["MACHINE"], "YT toward YT", "situation-n-twist")
      ],
      "letters" => letters,
      "twist" => %{
        "relation" => "situation-n-twist",
        "letter_id" => "inscription-letter-18",
        "purchase" => 18,
        "angle" => nil,
        "handedness" => nil,
        "status" => "purchase established; physical twist unresolved"
      },
      "end_bearing" => "XT toward XT",
      "geometry" => %{
        "status" => "trial arc embedding; not metric calibration or an appointed twist",
        "radius" => @radius,
        "half_width" => @half_width,
        "spatial_closure" => false
      }
    }
  end

  defp relation(id, words, bearing, through),
    do: %{"id" => id, "words" => words, "bearing" => bearing, "through" => through}

  defp memberships("THE"), do: ["the-public-bend"]
  defp memberships("PUBLIC"), do: ["the-public-bend", "public-situation-face"]
  defp memberships("SITUATION"), do: ["public-situation-face"]
  defp memberships("MACHINE"), do: ["machine-return"]

  # Tangent-continuous trial arcs. Frame transport is continuous through N;
  # it does not add an unappointed material roll at the twist purchase.
  defp sample(purchase) do
    {point, tangent, across} =
      cond do
        purchase <= 9 ->
          a = purchase / 9 * :math.pi() / 2

          {[@radius * :math.sin(a), 0.0, @radius * (1 - :math.cos(a))],
           [:math.cos(a), 0.0, :math.sin(a)], [0.0, 1.0, 0.0]}

        purchase <= 18 ->
          a = (purchase - 9) / 9 * :math.pi() / 2

          {[@radius, @radius * (1 - :math.cos(a)), @radius * (1 + :math.sin(a))],
           [0.0, :math.sin(a), :math.cos(a)], [0.0, :math.cos(a), -:math.sin(a)]}

        true ->
          a = (purchase - 18) / 7 * :math.pi() / 2

          {[@radius * (2 - :math.cos(a)), @radius * (1 + :math.sin(a)), 2 * @radius],
           [:math.sin(a), :math.cos(a), 0.0], [0.0, 0.0, -1.0]}
      end

    %{
      "purchase" => purchase,
      "point" => point,
      "tangent" => tangent,
      "edges" =>
        Enum.map([-1, 1], fn sign ->
          Enum.zip_with(point, across, &(&1 + sign * @half_width * &2))
        end)
    }
  end
end
