defmodule ElixirAwesome.GithubData.Manager do
  @moduledoc """
  Perform requesting process management
  """

  use GenServer

  # Public API

  def start_link(libraries_list) do
    GenServer.start_link(__MODULE__, libraries_list, name: __MODULE__)
  end

  def get_processed do
    %{processed: processed, total: total} = GenServer.cast(__MODULE__, :get_state)
    "#{processed}/#{total}"
  end

  # Callbacks
  def init(libraries_list) do
    {:ok, %{libraries: libraries_list}}
  end

  defp initial_state(libraries_list) do
    %{
      libraries_list: libraries_list,
      pending_libraries_list: [],
      processed: 0,
      total: length(libraries_list),
      workers_count: 0,
      workers_list: []
    }
  end

  def handle_cast(:get_state, _from, state) do
    {:reply, state, state}
  end
end
