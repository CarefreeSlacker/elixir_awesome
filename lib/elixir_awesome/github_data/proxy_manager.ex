defmodule ElixirAwesome.GithubData.ProxyManager do
  @moduledoc """
  Store Proxy data inside itself. Keep free and occupied proxies list.
  """

  use GenServer

  @proxy_configuration_list Application.get_env(:elixir_awesome, :github_data)[:proxies_list]

  # API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{free_proxies: @proxy_configuration_list, occupied_proxies: []}}
  end

  def get_proxy do
    GenServer.call(__MODULE__, :get_proxy)
  end

  # Callbacks
  def handle_call(
        :get_proxy,
        {from_pid, from_reference},
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
    IO.puts("!! #{inspect(NaiveDateTime.utc_now())} proxy_manager handle_info #{inspect({:DOWN, _ref, :process, fallen_reference, _reason})}")
    index =
      Enum.find_index(occupied_proxies, fn {_occupied_proxy, ref} ->
        ref == fallen_reference
      end)
    IO.puts("!! proxy index #{index} falen_ref #{inspect(fallen_reference)} occupied proxies #{inspect(occupied_proxies)}")
    {occupied_proxy, _proxy_pid} = Enum.at(occupied_proxies, index)
    new_occupied_proxies = List.delete_at(occupied_proxies, index)

    {:noreply,
     %{
       state
       | free_proxies: [occupied_proxy | free_proxies],
         occupied_proxies: new_occupied_proxies
     }}
  end
end
