defmodule Oauth2.Mixfile do
  use Mix.Project

  def project do
    [app: :oauth2,
     version: "0.0.1",
     elixir: "~> 0.15.0",
     deps: deps]
  end

  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :postgrex, :ecto, :cowboy, :plug]]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [{:cowboy,   "~> 1.0.0"},
     {:plug,     "~> 0.5.3"},
     {:postgrex, ">= 0.0.0"},
     {:ecto,     "~> 0.2.0"}]
  end
end
