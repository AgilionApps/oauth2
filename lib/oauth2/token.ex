defmodule OAuth2.Token do
  use Timex

  @one_hour 60 * 60
  @thirty_days @one_hour * 24 * 30

  defstruct [:access_token, :refresh_token, :user_id, :created_at]

  def expires_in do
    Application.get_env(:oauth2, :token_expires_in_seconds) || @one_hour
  end

  def refresh_expires_in do
    Application.get_env(:oauth2, :refresh_expires_in_seconds) || @thirty_days
  end

  def expired?(token) do
    invalid_before = Time.now(:secs) - expires_in
    token.created_at < invalid_before
  end

  def refresh_expired?(token) do
    invalid_before = Time.now(:secs) - refresh_expires_in
    token.created_at < invalid_before
  end

  def create(user_id, access_tokens, refresh_tokens) do
    %__MODULE__{
      access_token:  new_token(access_tokens),
      refresh_token: new_token(refresh_tokens),
      user_id:       user_id,
      created_at:    Time.now(:secs)
    }
  end

  defp new_token(tokens) do
    token = :base64.encode(:crypto.strong_rand_bytes(100))
    if HashDict.has_key?(tokens, token) do
      new_token(tokens)
    else
      token
    end
  end
end
