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
end