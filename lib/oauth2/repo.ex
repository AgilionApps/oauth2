defmodule OAuth2.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, env: Mix.env

  def conf(env), do: parse_url url(env)

  defp url(:dev),  do: "ecto://localhost/vagrant_dev"
  defp url(:test), do: "ecto://localhost/vagrant_test"
  defp url(:prod), do: "ecto://localhost/vagrant_prod"
end
