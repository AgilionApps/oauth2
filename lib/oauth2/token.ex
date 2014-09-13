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
end
