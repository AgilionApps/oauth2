defmodule OAuth2.Router do
  import Plug.Conn
  use Plug.Router
  alias OAuth2.TokenManager
  alias OAuth2.Token

  plug Plug.Parsers, parsers: [:urlencoded, :multipart, PlugJsonParser]
  plug :match
  plug :dispatch

  get "/status" do
    conn |> send_json(200, %{status: "okay"})
  end

  post "/token" do
    case conn.params["grant_type"] do
      "password"      -> authenticate_with_password(conn)
      "refresh_token" -> authenticate_with_refresh_token(conn)
      _               -> send_resp(conn, 401, "Unsupported Grant Type")
    end
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end

  defp authenticate_with_password(conn) do
    username = conn.params["username"]
    password = conn.params["password"]
    case authenticate(username, password) do
      {:ok,    user_id} -> send_new_token(conn, user_id)
      {:error, _ }   -> send_not_authorized(conn)
    end
  end

  defp authenticate_with_refresh_token(conn) do
    token = conn.params["refresh_token"]
    case TokenManager.find_by_refresh(token) do
      {:ok,   token} -> send_new_token(conn, token.user_id)
      {:error, _ }   -> send_not_authorized(conn)
    end
  end

  defp authenticate(username, password) do
    Application.get_env(:oauth2, :authenticateable)
      |> Kernel.apply(:authenticate, [username, password])
  end

  defp send_json(conn, status, body) do
    send_resp(conn, status, Poison.encode!(body, string: true))
  end

  defp send_new_token(conn, user_id) do
    {:ok, token} = TokenManager.create(user_id)
    token = Token.as_json(token)
    send_json(conn, 201, token)
  end

  defp send_not_authorized(conn) do
    send_resp(conn, 401, "")
  end
end
