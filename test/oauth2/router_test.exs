defmodule OAuth2.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias OAuth2.Router

  test "status" do
    conn = conn("GET", "status")
    conn = Router.call(conn, [])
    assert conn.status == 200
  end

  defp post_json(path, body) do
    headers = [{"content-type", "application/json"}]
    body = Jazz.encode!(body)
    conn("POST", path, body, headers: headers)
  end

  test "authenticating with password" do
    body = %{grant_type: "password"}
    conn = post_json("token", body)
    conn = Router.call(conn, [])
    assert conn.status == 401
  end

  test "wrong path" do
    conn = conn("GET", "missing")
    conn = Router.call(conn, [])
    assert conn.status == 404
  end
end
