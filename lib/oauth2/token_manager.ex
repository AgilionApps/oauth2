defmodule OAuth2.TokenManager do
  use GenServer
  use Timex
  alias OAuth2.Token

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, HashDict.new, name: __MODULE__)
  end

  def create(user_id) do
    GenServer.call(__MODULE__, {:create, user_id})
  end

  def find(token) do
    GenServer.call(__MODULE__, {:find, token})
  end

  # Server

  def handle_call({:create, user_id}, _from, tokens) do
    token = %Token{
      access_token: new_token(tokens),
      user_id:      user_id,
      created_at:   Time.now(:secs)
    }
    tokens = HashDict.put_new(tokens, token.access_token, token)
    {:reply, {:ok, token}, tokens}
  end

  def handle_call({:find, access_token}, _from, tokens) do
    invalid_before = Time.now(:secs) - Token.expires_in
    case HashDict.get(tokens, access_token) do
      nil ->
        {:reply, {:error, "Invalid token"}, tokens}

      %Token{created_at: c} when c < invalid_before ->
        tokens = HashDict.delete(tokens, access_token)
        {:reply, {:error, "Expired token"}, tokens}

      token ->
        {:reply, {:ok, token}, tokens}
    end
  end

  defp new_token(tokens) do
    token = :base64.encode(:crypto.strong_rand_bytes(200))
    if HashDict.has_key?(tokens, token) do
      new_token(tokens)
    else
      token
    end
  end
end
