defmodule OAuth2.Dev.Router do
  import Plug.Conn
  use Plug.Router
  import OAuth2.Protected

  plug :match
  plug :dispatch

  forward "/oauth", to: OAuth2.Router

  match "protected" do
    with_valid_token(conn) do
      conn |> send_resp(200, "#{user_id}")
    end
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end
end
