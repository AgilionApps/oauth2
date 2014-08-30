use Mix.Config

config :oauth2,
  authenticateable: OAuth2.Dev.User,
  token_expires_in_seconds: 60 * 60,
  refresh_token_expires_in_seconds: 60 * 60 * 24 * 30
