defmodule OAuth2.Mixfile do
  use Mix.Project

  def project do
    [app:     :oauth2,
     version: "0.0.1",
     elixir:  "~> 1.0.0",
     deps:    deps]
  end

  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :plug],
     mod: {OAuth2, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [{:cowboy,           "~> 1.0.0"},
     {:plug,             "~> 0.7.0"},
     {:poison,           "~> 1.1.1"},
     {:plug_json_parser, "~> 0.0.6"},
     {:timex,            "~> 0.12.3"}]
  end
end
