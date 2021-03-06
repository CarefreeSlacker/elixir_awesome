defmodule ElixirAwesome.GithubData.ProxyManager do
  @moduledoc """
  Store Proxy data inside itself. Keep free and occupied proxies list.
  """

  use GenServer, restart: :transient

  alias ElixirAwesome.GithubData.ProxyService

  # API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{free_proxies: ProxyService.get_proxies_credentials(), occupied_proxies: []}}
  end

  @spec get_proxy :: {:ok, tuple} | {:error, :no_available_proxies}
  def get_proxy do
    GenServer.call(__MODULE__, :get_proxy)
  end

  def finish_work do
    GenServer.cast(__MODULE__, :finish_work)
  end

  # Callbacks
  def handle_call(
        :get_proxy,
        {from_pid, _from_reference},
        %{free_proxies: proxies_list, occupied_proxies: occupied_proxies} = status
      ) do
    case proxies_list do
      [] ->
        {:reply, {:error, :no_available_proxies}, status}

      [free_proxy | left_free_proxies] ->
        Process.monitor(from_pid)

        {:reply, {:ok, free_proxy},
         %{
           status
           | free_proxies: left_free_proxies,
             occupied_proxies: occupied_proxies ++ [{free_proxy, from_pid}]
         }}
    end
  end

  def handle_info(
        {:DOWN, _ref, :process, fallen_reference, _reason},
        %{free_proxies: free_proxies, occupied_proxies: occupied_proxies} = state
      ) do
    index =
      Enum.find_index(occupied_proxies, fn {_occupied_proxy, ref} ->
        ref == fallen_reference
      end)

    {occupied_proxy, _proxy_pid} = Enum.at(occupied_proxies, index)
    new_occupied_proxies = List.delete_at(occupied_proxies, index)
    new_free_proxies = free_proxies ++ [occupied_proxy]

    {:noreply,
     %{
       state
       | free_proxies: new_free_proxies,
         occupied_proxies: new_occupied_proxies
     }}
  end

  def handle_cast(:finish_work, state) do
    {:stop, :normal, state}
  end
end
