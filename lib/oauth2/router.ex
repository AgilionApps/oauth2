defmodule OAuth2.Router do
  import Plug.Conn
  use Plug.Router

  plug Plug.Parsers, parsers: [PlugJsonParser]
  plug :match
  plug :dispatch

  get "status" do
    conn |> send_json(200, %{status: 'okay'})
  end

  post "token" do
    case conn.params["grant_type"] do
      "password" -> authenticate_with_password(conn)
      "token"    -> authenticate_with_refresh_token(conn)
      _          -> send_resp(conn, 401, "Unsupported Grant Type")
    end
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end

  defp authenticate_with_password(conn) do
    username = conn.params["username"]
    password = conn.params["password"]
    case authenticate(username, password) do
      {:ok,    user} -> send_new_token(conn, user)
      {:error, _ }   -> send_not_authorized(conn)
    end
  end

  defp authenticate_with_refresh_token(conn) do
    conn |> send_resp(200, "Token")
  end

  defp authenticate(_username, _password) do
    {:error, "not implimented"}
  end

  defp send_json(conn, status, body) do
    send_resp(conn, status, Jazz.encode!(body))
  end

  defp send_new_token(conn, _user) do
    #token = Token.create_for_user(user)
    send_json(conn, 201, %{token: 'wat'})
  end

  defp send_not_authorized(conn) do
    send_resp(conn, 401, "")
  end
end
