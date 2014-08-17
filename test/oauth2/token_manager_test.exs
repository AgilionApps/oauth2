defmodule TokenManagerTest do
  use ExUnit.Case, async: true
  alias OAuth2.TokenManager
  alias OAuth2.Token
  use Timex

  setup do
    valid = %Token{
      access_token: 'valid',
      user_id: 1,
      created_at: Time.now(:secs)
    }
    expired = %Token{
      access_token: 'expired',
      user_id: 1,
      created_at: Time.now(:secs) - (60 * 60 * 24)
    }
    existing_tokens = HashDict.new
      |> HashDict.put_new(valid.access_token, valid)
      |> HashDict.put_new(expired.access_token, expired)
    {:ok, pid} = GenServer.start_link(TokenManager, existing_tokens)
    {:ok, pid: pid, valid: valid, expired: expired}
  end

  test "creating a token", context do
    {:ok, results} = GenServer.call(context[:pid], {:create, 1})
    assert results.user_id == 1
    assert results.access_token
  end

  test "finding a token", context do
    {:ok, results} = GenServer.call(context[:pid], {:find, context[:valid].access_token})
    assert results.user_id == 1
  end

  test "finding an expired token", context do
    {:error, message} = GenServer.call(context[:pid], {:find, context[:expired].access_token})
    assert message == "Expired token"
  end

  test "finding missing token", context do
    {:error, message} = GenServer.call(context[:pid], {:find, "nonsense"})
    assert message == "Invalid token"
  end
end
