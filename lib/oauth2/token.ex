defmodule OAuth2.Token do
  defstruct access_token: nil, refresh_token: nil, user_id: nil, created_at: nil

  #TODO: Make this better. Protocols maybe?
  def as_json(token) do
    %{
      user_id:       token.user_id,
      access_token:  token.access_token,
      refresh_token: token.refresh_token,
      token_type:    "bearer",
      expires_in:    expires_in
    }
  end

  def expires_in do
    Application.get_env(:oauth2, :token_expires_in_seconds)
  end

  def refresh_expires_in do
    Application.get_env(:oauth2, :refresh_expires_in_seconds) || 60 * 60 * 24 * 30
  end

  def expired?(token) do
    invalid_before = Time.now(:secs) - Token.expires_in
    token.created_at < invalid_before
  end

  def refresh_expired?(token) do
    invalid_before = Time.now(:secs) - Token.refresh_expires_in
    token.created_at < invalid_before
  end
end
