defmodule TokenManagerTest do
  use ExUnit.Case, async: true
  alias OAuth2.TokenManager

  setup do
    {:ok, pid} = GenServer.start_link(TokenManager, HashDict.new)
    {:ok, pid: pid}
  end

  test "creating a token", context do
    {:ok, results} = GenServer.call(context[:pid], {:create, 1})
    assert results.user_id == 1
    assert results.access_token
  end

  test "finding a token", context do
    {:ok, %{access_token: token}} = GenServer.call(context[:pid], {:create, 1})
    {:ok, results} = GenServer.call(context[:pid], {:find, token})
    assert results.user_id == 1
  end
end
