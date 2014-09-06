defmodule OAuth2.Protected do
  import Plug.Conn

  defmacro with_valid_token(conn, clauses) do
    do_clause = Keyword.get(clauses, :do)
    quote do
      case OAuth2.Protected.get_bearer_token(unquote(conn)) do
        {:ok, access_token} ->
          case OAuth2.TokenManager.find(access_token) do
            {:ok, token} ->
              var!(user_id) = token.user_id
              unquote(do_clause)
            {:error, _ } ->
              OAuth2.Protected.send_unauthorized(unquote(conn))
          end
        {:error, _ } ->
          OAuth2.Protected.send_unauthorized(unquote(conn))
      end
    end
  end

  def get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] -> {:ok, access_token}
      _ -> {:error, "No token found"}
    end
  end

  def send_unauthorized(conn) do
    conn |> send_resp(401, "")
  end
end
