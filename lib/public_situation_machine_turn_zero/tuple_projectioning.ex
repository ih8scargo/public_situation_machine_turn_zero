defmodule PublicSituationMachineTurnZero.TupleProjectioning do
  @moduledoc """
  Loads the canonical Tuple Position table from its single Markdown source.
  """

  @path "priv/tuple/canonical_tuple_positions.md"

  def table do
    Application.app_dir(:public_situation_machine_turn_zero, @path)
    |> File.read!()
    |> parse_table()
  end

  defp parse_table(markdown) do
    [header_line, _divider_line | row_lines] =
      markdown
      |> String.split("\n", trim: true)

    %{
      headers: parse_line(header_line),
      rows: Enum.map(row_lines, &parse_line/1)
    }
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.trim("|")
    |> String.split("|")
    |> Enum.map(&parse_cell/1)
  end

  defp parse_cell(cell) do
    text = String.trim(cell)
    emphasized? = String.starts_with?(text, "*") && String.ends_with?(text, "*")

    %{
      text: if(emphasized?, do: String.trim(text, "*"), else: text),
      emphasized?: emphasized?
    }
  end
end
