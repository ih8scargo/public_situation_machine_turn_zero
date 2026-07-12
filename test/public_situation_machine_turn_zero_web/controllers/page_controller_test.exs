defmodule PublicSituationMachineTurnZeroWeb.PageControllerTest do
  use PublicSituationMachineTurnZeroWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "This Post Upon the Pier"
  end
end
