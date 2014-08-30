defmodule OAuth2.TokenManager do
  use GenServer
  use Timex
  alias OAuth2.Token

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

  def prune do
    send __MODULE__, :prune
    send __MODULE__, :prune_refresh
  end

  # Server

  def init(state) do
    :erlang.send_after(60*60*5, self, :prune)
    :erlang.send_after(60*60*24, self, :prune_refresh)
    {:ok, state}
  end

  def handle_call({:create, user_id}, _from, {tokens, refresh_tokens}) do
    token = %Token{
      access_token:  new_token(tokens),
      refresh_token: new_token(refresh_tokens),
      user_id:       user_id,
      created_at:    Time.now(:secs)
    }
    tokens = HashDict.put_new(tokens, token.access_token, token)
    refresh_tokens = HashDict.put_new(refresh_tokens, token.refresh_token, token)
    {:reply, {:ok, token}, {tokens, refresh_tokens}}
  end

  def handle_call({:find, access_token}, _from, {tokens, refresh_tokens}) do
    invalid_before = Time.now(:secs) - Token.expires_in
    case HashDict.get(tokens, access_token) do
      nil ->
        {:reply, {:error, "Invalid token"}, {tokens, refresh_tokens}}

      %Token{created_at: c} when c < invalid_before ->
        tokens = HashDict.delete(tokens, access_token)
        {:reply, {:error, "Expired token"}, {tokens, refresh_tokens}}

      token ->
        {:reply, {:ok, token}, {tokens, refresh_tokens}}
    end
  end

  def handle_call({:find_by_refresh, token}, _from, {tokens, refresh_tokens}) do
    invalid_before = Time.now(:secs) - Token.refresh_expires_in
    case HashDict.get(refresh_tokens, token) do
      nil ->
        {:reply, {:error, "Invalid token"}, {tokens, refresh_tokens}}

      %Token{created_at: c} when c < invalid_before ->
        refresh_tokens = HashDict.delete(refresh_tokens, token)
        {:reply, {:error, "Expired refresh token"}, {tokens, refresh_tokens}}

      token ->
        {:reply, {:ok, token}, {tokens, refresh_tokens}}
    end
  end

  def handle_info(:prune, _from, {tokens, refresh_tokens}) do
    tokens = prune(tokens)
    :erlang.send_after(60*60*5, self, :prune)
    {:noreply, {tokens, refresh_tokens}}
  end

  def handle_info(:prune_refresh, _from, {tokens, refresh_tokens}) do
    refresh_tokens = prune_refresh(refresh_tokens)
    :erlang.send_after(60*60*24, self, :prune_refresh)
    {:noreply, {tokens, refresh_tokens}}
  end

  defp prune(tokens) do
    for {k, v} <- tokens, !Token.expired?(v), into: HashDict.new, do: {k, v}
  end

  defp prune_refresh(tokens) do
    for {k, v} <- tokens, !Token.refresh_expired?(v), into: HashDict.new, do: {k, v}
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
