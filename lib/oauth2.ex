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
  Main OAuth2 entry point. Starts main supervisor.
  """
  def start(_type, _args) do
    OAuth2.Supervisor.start_link
  end
end
