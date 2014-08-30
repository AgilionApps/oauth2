defmodule OAuth2.TokenTest do
  use ExUnit.Case, async: true
  alias OAuth2.Token
  use Timex

  setup do
    token = %Token{
      access_token:  "myaccesstokenstring",
      user_id:       1,
      refresh_token: "myrefreshtokenstring",
      created_at:    Time.now
    }
    {:ok, token: token}
  end

  test "it is rendered as json correctly", context do
    json = Token.as_json(context[:token])
    assert json[:access_token]  == "myaccesstokenstring"
    assert json[:refresh_token] == "myrefreshtokenstring"
    assert json[:user_id]       == 1
    assert json[:expires_in]    == 60 * 60
  end
end
