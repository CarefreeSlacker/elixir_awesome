defmodule ElixirAwesome.GithubData.Manager do
  @moduledoc """
  Perform requesting process management
  """

  @stages_white_list [:start_proxy_manager, :working, :finish_work]
  @max_workers_count length(Application.get_env(:elixir_awesome, :github_data)[:proxies_list])

  alias ElixirAwesome.GithubData.{Api, ProxyManager}

  use GenServer, restart: :transient

  # Public API

  def start_link(libraries_list) do
    GenServer.start_link(__MODULE__, libraries_list, name: __MODULE__)
  end

  def get_processed do
    __MODULE__
    |> GenServer.whereis()
    |> case do
      nil ->
        {:error, "No refreshing status"}

      _gen_server_pid ->
        %{processed: processed, total: total} = GenServer.call(__MODULE__, :get_state)
        {:ok, "#{processed}/#{total}"}
    end
  end

  # Callbacks
  def init(libraries_list) do
    schedule_stage(:start_proxy_manager)
    {:ok, initial_state(libraries_list)}
  end

  defp initial_state(libraries_list) do
    %{
      libraries_list: libraries_list,
      processing_libraries_list: [],
      processed: 0,
      total: length(libraries_list),
      workers_count: 0,
      workers_list: List.duplicate(nil, @max_workers_count)
    }
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:start_proxy_manager, state) do
    Api.start_proxy_manager()
    schedule_stage(:working)
    {:noreply, state}
  end

  def handle_info(
        :working,
        %{
          libraries_list: libraries_list,
          processing_libraries_list: processing_libraries_list,
          workers_count: workers_count,
          workers_list: workers_list
        } = state
      ) do
    cond do
      workers_count >= @max_workers_count ->
        schedule_stage(:working, 1000)
        {:noreply, state}

      workers_count == 0 and length(libraries_list) == 0 ->
        schedule_stage(:finish_work)
        {:noreply, state}

      true ->
        with worker_id when not is_nil(worker_id) <- Enum.find_index(workers_list, &is_nil(&1)),
             [library_data | rest_libraries] <- libraries_list,
             {:ok, pid} <- Api.start_request_worker(worker_id, library_data) do
          Process.monitor(pid)
          schedule_stage(:working, 1000)

          {:noreply,
           %{
             state
             | libraries_list: rest_libraries,
               processing_libraries_list: processing_libraries_list ++ [{pid, library_data}],
               workers_count: workers_count + 1,
               workers_list: List.update_at(workers_list, worker_id, fn _val -> pid end)
           }}
        else
          _ ->
            schedule_stage(:working, 1000)
            {:noreply, state}
        end
    end
  end

  def handle_info(:finish_work, state) do
    ProxyManager.finish_work()
    {:stop, :normal, state}
  end

  def handle_info(
        {:DOWN, _ref, :process, process_pid, _reason},
        %{
          processing_libraries_list: processing_libraries_list,
          workers_count: workers_count,
          workers_list: workers_list,
          processed: processed
        } = state
      ) do
    worker_id = Enum.find_index(workers_list, fn worker_pid -> worker_pid == process_pid end)
    new_workers_list = List.update_at(workers_list, worker_id, fn _val -> nil end)

    processed_library_index =
      Enum.find_index(processing_libraries_list, fn {worker_pid, _library_data} ->
        worker_pid == process_pid
      end)

    new_processing_libraries_list =
      List.delete(processing_libraries_list, processed_library_index)

    {:noreply,
     %{
       state
       | processing_libraries_list: new_processing_libraries_list,
         workers_count: workers_count - 1,
         workers_list: new_workers_list,
         processed: processed + 1
     }}
  end

  def schedule_stage(stage, timeout \\ 100) when stage in @stages_white_list do
    GenServer.whereis(__MODULE__)
    |> Process.send_after(stage, timeout)
  end
end
