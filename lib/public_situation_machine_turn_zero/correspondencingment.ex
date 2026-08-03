defmodule PublicSituationMachineTurnZero.Correspondencingment do
  @moduledoc """
  The minimal publication structure for a Correspondencingment.
  """

  @enforce_keys [:number, :title, :publication_date, :summary]
  defstruct [
    :number,
    :title,
    :subtitle,
    :publication_date,
    :summary,
    :body,
    :video_id,
    featured: false
  ]
end
