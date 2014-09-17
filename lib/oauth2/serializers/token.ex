defimpl Poison.Encoder, for: OAuth2.Token do
  def encode(token, _opts) do
    Poison.encode!(
      %{
        user_id:       token.user_id,
        access_token:  token.access_token,
        refresh_token: token.refresh_token,
        token_type:    "bearer",
        expires_in:    OAuth2.Token.expires_in
      }
    )
  end
end
