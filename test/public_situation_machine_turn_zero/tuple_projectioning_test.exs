defmodule PublicSituationMachineTurnZero.TupleProjectioningTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.TupleProjectioning

  test "loads the seven-column, seven-position canonical Markdown table" do
    table = TupleProjectioning.table()

    assert length(table.headers) == 7
    assert length(table.rows) == 7

    assert Enum.map(table.headers, & &1.text) == [
             "Tuple Position",
             "Constitutional Geometry Furnished",
             "Prepositional Labor",
             "Constitutional Labor",
             "Embodied Inhabitationing",
             "Unfolding Toward Coherence",
             "One Soundinging of Stewardly Regard"
           ]

    assert Enum.map(table.rows, fn row -> hd(row).text end) == ~w(0 1 2 3 4 5 6)
    assert Enum.all?(table.rows, &(length(&1) == 7))
  end
end
