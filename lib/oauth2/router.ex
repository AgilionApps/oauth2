defmodule OAuth2.Router do
  import Plug.Conn
  use Plug.Router
  alias OAuth2.TokenManager
  alias OAuth2.Token

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

  defp authenticate(username, password) do
    Application.get_env(:oauth2, :authenticateable)
      |> Kernel.apply(:authenticate, [username, password])
  end

  defp send_json(conn, status, body) do
    send_resp(conn, status, Jazz.encode!(body))
  end

  defp send_new_token(conn, user) do
    {:ok, token} = TokenManager.create(user[:id])
    token = Token.as_json(token)
    send_json(conn, 201, token)
  end

  defp send_not_authorized(conn) do
    send_resp(conn, 401, "")
  end
end