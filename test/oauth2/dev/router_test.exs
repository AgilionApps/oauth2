defmodule OAuth2.DevRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias OAuth2.Dev.Router

  test "wrong path" do
    conn = conn("GET", "/missing")
    conn = Router.call(conn, [])
    assert conn.status == 404
  end

  test "protected path" do
    conn = conn("GET", "/protected")
    conn = Router.call(conn, [])
    assert conn.status == 401
  end

  test "protected path with valid token" do
    {:ok, token} = OAuth2.TokenManager.create(1)
    headers = [authorization: "Bearer #{token.access_token}"]
    conn = conn("GET", "/protected", nil, headers: headers)
    conn = Router.call(conn, [])
    assert conn.status == 200
    assert conn.resp_body == "1"
  end
end
