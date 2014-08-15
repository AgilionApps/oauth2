defmodule OAuth2.Supervisor do
  @moduledoc "Top level supervisor"
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(OAuth2.Repo, [])]
    supervise(children, strategy: :one_for_all)
  end
end
