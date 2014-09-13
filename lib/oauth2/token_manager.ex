defmodule OAuth2.TokenManager do
  use GenServer
  alias OAuth2.Token

  @one_hour 60 * 60

  # Client

  def start_link do
    state = {HashDict.new, HashDict.new}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create(user_id) do
    GenServer.call(__MODULE__, {:create, user_id})
  end

  def find(token) do
    GenServer.call(__MODULE__, {:find, token})
  end

  def find_by_refresh(token) do
    GenServer.call(__MODULE__, {:find_by_refresh, token})
  end

  def prune, do: send(__MODULE__, :prune)

  # Server

  def init(state) do
    :erlang.send_after(@one_hour, self, :prune)
    {:ok, state}
  end

  def handle_call({:create, user_id}, _from, {tokens, refresh_tokens}) do
    token = Token.create(user_id, tokens, refresh_tokens)
    tokens = HashDict.put_new(tokens, token.access_token, token)
    refresh_tokens = HashDict.put_new(refresh_tokens, token.refresh_token, token)
    {:reply, {:ok, token}, {tokens, refresh_tokens}}
  end

  def handle_call({:find, access_token}, _from, {tokens, refresh_tokens}) do
    case HashDict.get(tokens, access_token) do
      nil   -> {:reply, {:error, "Invalid token"}, {tokens, refresh_tokens}}
      token -> case Token.expired?(token) do
        true ->
          tokens = HashDict.delete(tokens, access_token)
          {:reply, {:error, "Expired token"}, {tokens, refresh_tokens}}
        _   ->
          {:reply, {:ok, token}, {tokens, refresh_tokens}}
      end
    end
  end

  def handle_call({:find_by_refresh, token}, _from, {tokens, refresh_tokens}) do
    case HashDict.get(refresh_tokens, token) do
      nil   -> {:reply, {:error, "Invalid token"}, {tokens, refresh_tokens}}
      token -> case Token.refresh_expired?(token) do
        true ->
          refresh_tokens = HashDict.delete(refresh_tokens, token)
          {:reply, {:error, "Expired refresh token"}, {tokens, refresh_tokens}}
        _  ->
          {:reply, {:ok, token}, {tokens, refresh_tokens}}
      end
    end
  end

  def handle_info(:prune, {tokens, refresh_tokens} = state) do
    spawn(__MODULE__, :find_expired, [self, tokens])
    spawn(__MODULE__, :find_expired_refresh, [self, refresh_tokens])
    :erlang.send_after(@one_hour, self, :prune)
    {:noreply, state}
  end

  def handle_cast({:delete, token}, {tokens, refresh_tokens}) do
    {:noreply, {HashDict.delete(tokens, token), refresh_tokens}}
  end

  def handle_cast({:delete_refresh, token}, {tokens, refresh_tokens}) do
    {:noreply, {tokens, HashDict.delete(refresh_tokens, token)}}
  end

  def find_expired(pid, tokens) do
    for {k, v} <- tokens, Token.expired?(v) do
      GenServer.cast(pid, {:delete, k})
    end
  end

  def find_expired_refresh(pid, tokens) do
    for {k, v} <- tokens, Token.refresh_expired?(v) do
      GenServer.cast(pid, {:delete_refresh, k})
    end
  end
end
