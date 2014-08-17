defmodule OAuth2.Dev.Router do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/oauth", to: OAuth2.Router

  match _ do
    conn |> send_resp(404, "Not Found")
  end
end
