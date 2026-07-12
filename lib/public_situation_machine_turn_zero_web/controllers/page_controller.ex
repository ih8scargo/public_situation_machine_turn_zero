defmodule PublicSituationMachineTurnZeroWeb.PageController do
  use PublicSituationMachineTurnZeroWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
