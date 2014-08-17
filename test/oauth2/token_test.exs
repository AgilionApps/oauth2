defmodule OAuth2.TokenTest do
  use ExUnit.Case, async: true
  alias OAuth2.Token

  setup do
    token = %Token{
      access_token:  "myaccesstokenstring",
      user_id:       1,
      refresh_token: "myrefreshtokenstring",
      created_at:    "todo"
    }
    {:ok, token: token}
  end

  test "it is rendered as json correctly", context do
    json = Token.as_json(context[:token])
    assert json[:access_token]  == "myaccesstokenstring"
    assert json[:refresh_token] == "myrefreshtokenstring"
    assert json[:user_id]       == 1
  end

end
