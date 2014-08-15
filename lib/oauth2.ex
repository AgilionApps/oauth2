defmodule OAuth2 do
  @moduledoc """
  Implements OAuth2 Resource Owners Password Credentials Grant.

  To use add as a mix dependency and start oauth2 application.
  Then forward your desired namespace to OAuth2.Router.

    defmodule MyApp.Router do
      import Plug.Conn
      use Plug.Router

      plug :match
      plug :dispatch

      forward "api/v1/oauth", to: OAuth2.Router

      #...
    end
  """
  use Application

  @doc """
  Main OAuth2 entry point.
  Starts main supervisor, also starts cowboy http server in dev.
  """
  def start(_type, _args) do
    # When used as a dependency env is always prod.
    if Mix.env == :dev do
      Plug.Adapters.Cowboy.http(OAuth2.DevRouter, [])
    end
    OAuth2.Supervisor.start_link
  end
end
