defmodule OAuth2.Dev.User do
  # use OAuth2.Authenticateable # Todo, define behavior

  def authenticate("testuser","correctpassword") do
    {:ok, 1}
  end

  def authenticate(_username,_password) do
    {:error, "Invalid username or password"}
  end

  def find(1) do
    {:ok, %{id: 1, username: "testuser", email: "test@example.com"}}
  end

  def find(_id) do
    {:error, "User not found"}
  end
end
