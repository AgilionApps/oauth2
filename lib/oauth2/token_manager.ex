defmodule OAuth2.TokenManager do
  use GenServer
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
    }
    tokens = HashDict.put_new(tokens, token.access_token, token)
    {:reply, {:ok, token}, tokens}
  end

  def handle_call({:find, token}, _from, tokens) do
    #TODO: handle expiration
    token = HashDict.get(tokens, token)
    {:reply, {:ok, token}, tokens}
  end

  def handle_call(msg, from, state) do
    super(msg, from, state)
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
