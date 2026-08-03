defmodule PublicSituationMachineTurnZero.TupleProjectioningTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.TupleProjectioning

  test "loads the seven-column, seven-position canonical Markdown table" do
    table = TupleProjectioning.table()

    assert length(table.headers) == 7
    assert length(table.rows) == 7

    assert Enum.map(table.headers, & &1.text) == [
             "Constitutional Geometry Furnished",
             "Laboringing Prepositions",
             "Tuple Position",
             "Constitutioning Labor",
             "Unfolding Toward Coherence",
             "Embodying Inhabitationing",
             "One Soundinging of Stewardly Regard"
           ]

    assert Enum.map(table.rows, fn row -> Enum.at(row, 2).text end) == ~w(0 1 2 3 4 5 6)
    assert Enum.all?(table.rows, &(length(&1) == 7))
  end
end
