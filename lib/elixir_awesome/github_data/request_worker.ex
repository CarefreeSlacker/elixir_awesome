defmodule ElixirAwesome.GithubData.RequestWorker do
  @moduledoc """
  Perform requests
  """

  @stages_white_list [:get_library, :get_proxy, :get_last_commit, :get_stars, :finish_work]
  @await_between_requests_interval Application.get_env(:elixir_awesome, :github_data)[:between_requests_interval]

  alias ElixirAwesome.GithubData.Api
  use GenServer

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
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker get_proxy before #{inspect(self())} #{inspect(NaiveDateTime.utc_now())} state #{inspect(state)}")
    case Api.get_free_proxy do
      {:ok, proxy} ->
        schedule_stage(:get_last_commit, 100)
        {:noreply, %{state | proxy: proxy, stage: :get_last_commit}}
      {:error, :no_available_proxies} ->
        schedule_stage(:get_proxy, 100)
        {:noreply, %{state | stage: :get_proxy}}
    end
  end

  def handle_info(:get_last_commit, state) do
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker get_lst_commit before #{inspect(self())} #{inspect(NaiveDateTime.utc_now())} state #{inspect(state)}")
    :timer.sleep(@await_between_requests_interval)
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker get_lst_commit after #{inspect(self())} #{inspect(NaiveDateTime.utc_now())}")
    schedule_stage(:get_stars, 100)
    {:noreply, state}
  end

  def handle_info(:get_stars, state) do
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker get_stars before #{inspect(self())} #{inspect(NaiveDateTime.utc_now())} state #{inspect(state)}")
    :timer.sleep(@await_between_requests_interval)
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker get_stars after #{inspect(self())} #{inspect(NaiveDateTime.utc_now())}")
    schedule_stage(:finish_work, 100)
    {:noreply, state}
  end

  def handle_info(:finish_work, state) do
    IO.puts("!!!  #{inspect(NaiveDateTime.utc_now())} request_worker finish_work before #{inspect(self())} #{inspect(NaiveDateTime.utc_now())} state #{inspect(state)}")
    {:stop, :normal, state}
  end

  defp schedule_stage(stage, timeout \\ 100) when stage in @stages_white_list do
    Process.send_after(self(), stage, timeout)
  end
end
