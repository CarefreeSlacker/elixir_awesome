defmodule ElixirAwesome.GithubData.RequestWorker do
  @moduledoc """
  Perform requests
  """

  @stages_white_list [
    :get_library,
    :get_proxy,
    :get_last_commit,
    :get_stars,
    :create_or_update_record,
    :finish_work
  ]
  @await_between_requests_interval Application.get_env(:elixir_awesome, :github_data)[
                                     :between_requests_interval
                                   ]

  alias ElixirAwesome.External.RequestService
  alias ElixirAwesome.GithubData.Api
  use GenServer, restart: :transient

  # Public API

  def start_link(%{worker_id: worker_id} = params) do
    GenServer.start_link(__MODULE__, params, name: :"#{__MODULE__}##{worker_id}")
  end

  # Callbacks
  def init(%{worker_id: worker_id, library_data: library_data}) do
    schedule_stage(:get_proxy, 100)
    {:ok, %{worker_id: worker_id, library_data: library_data, proxy: nil, stage: :initial}}
  end

  def handle_info(:get_proxy, state) do
    case Api.get_free_proxy() do
      {:ok, proxy} ->
        schedule_stage(:get_last_commit, 100)
        {:noreply, %{state | proxy: proxy, stage: :get_last_commit}}

      {:error, :no_available_proxies} ->
        schedule_stage(:get_proxy, 100)
        {:noreply, %{state | stage: :get_proxy}}
    end
  end

  def handle_info(:get_last_commit, %{library_data: library_data, proxy: proxy} = state) do
    with %{author: author, repo: repo} = updated_library_data <-
           RequestService.get_library_identity(library_data),
         {:ok, last_commit_date_time} <-
           RequestService.request_last_commit({author, repo}, proxy: proxy) do
      library_data_with_commit =
        Map.put(updated_library_data, :last_commit, last_commit_date_time)

      :timer.sleep(@await_between_requests_interval)
      schedule_stage(:get_stars, 100)
      {:noreply, %{state | library_data: library_data_with_commit}}
    else
      error ->
        IO.puts(
          "!!! request_worker error #{inspect(error)} during :get_last_commit\nState: #{
            inspect(state)
          }"
        )

        schedule_stage(:get_last_commit, 100)
    end

    {:noreply, state}
  end

  def handle_info(
        :get_stars,
        %{library_data: %{author: author, repo: repo} = library_data, proxy: proxy} = state
      ) do
    with {:ok, stars_count} <- RequestService.request_stars_count({author, repo}, proxy: proxy) do
      library_data_with_commit = Map.put(library_data, :stars, stars_count)
      :timer.sleep(@await_between_requests_interval)
      schedule_stage(:create_or_update_record, 100)
      {:noreply, %{state | library_data: library_data_with_commit}}
    else
      error ->
        IO.puts(
          "!!! request_worker error #{inspect(error)} during :get_stars\nState: #{inspect(state)}"
        )

        schedule_stage(:get_stars, 100)
    end

    {:noreply, state}
  end

  def handle_info(:get_stars, state) do
    :timer.sleep(@await_between_requests_interval)
    schedule_stage(:finish_work, 100)
    {:noreply, state}
  end

  def handle_info(:finish_work, state) do
    {:stop, :normal, state}
  end

  defp schedule_stage(stage, timeout \\ 100) when stage in @stages_white_list do
    Process.send_after(self(), stage, timeout)
  end
end
