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

  test "authenticating with correct password" do
    json = %{
      grant_type: "password",
      username:   "testuser",
      password:   "correctpassword"
    }
    conn = post_json("token", json)
    conn = Router.call(conn, [])
    assert conn.status == 201
    result = conn.resp_body |> Jazz.decode!
    assert result["user_id"] == 1
    assert result["token_type"] == "bearer"
    assert Dict.has_key?(result, "access_token")
    assert Dict.has_key?(result, "refresh_token")
    assert Dict.has_key?(result, "expires_in")
  end

  test "authenticating with wrong password" do
    json = %{
      grant_type: "password",
      username:   "testuser",
      password:   "wrong"
    }
    conn = post_json("token", json)
    conn = Router.call(conn, [])
    assert conn.status == 401
  end

  test "wrong path" do
    conn = conn("GET", "missing")
    conn = Router.call(conn, [])
    assert conn.status == 404
  end
end
