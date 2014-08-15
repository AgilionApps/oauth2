defmodule OAuth2.DevRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias OAuth2.DevRouter

  test "wrong path" do
    conn = conn("GET", "/missing")
    conn = DevRouter.call(conn, [])
    assert conn.status == 404
  end
end
