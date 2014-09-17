defmodule OAuth2.TokenTest do
  use ExUnit.Case, async: true
  alias OAuth2.Token
  use Timex

  test "isnt expired" do
    token = %Token{
      access_token:  "myaccesstokenstring",
      user_id:       1,
      refresh_token: "myrefreshtokenstring",
      created_at:    Time.now(:secs)
    }

    assert !Token.expired?(token)
    assert !Token.refresh_expired?(token)
  end

  test "access token expired" do
    token = %Token{
      access_token:  "myaccesstokenstring",
      user_id:       1,
      refresh_token: "myrefreshtokenstring",
      created_at:    Time.now(:secs) - (60 * 60) - 1
    }

    assert Token.expired?(token)
    assert !Token.refresh_expired?(token)
  end

  test "refresh expired" do
    token = %Token{
      access_token:  "myaccesstokenstring",
      user_id:       1,
      refresh_token: "myrefreshtokenstring",
      created_at:    Time.now(:secs) - (60 * 60 * 24 * 30) - 1
    }

    assert Token.expired?(token)
    assert Token.refresh_expired?(token)
  end
end
