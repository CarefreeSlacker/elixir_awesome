defmodule ElixirAwesome.GithubData.Api do
  @moduledoc """
  For getting data for all libraries we need to perform ~2000 requests.
  It will face to anti-spam protection. To solve this problem i will use proxies.
  We gonna send data with delays via proxies.
  Besides that we have distinct count of proxies.
  So we need something to manage proxies and workers.
  This module contains functions for managing and monitoring data requesting process.
  """

  alias ElixirAwesome.GithubData.{Manager, ProxyManager, Supervisor}

  @doc """
  Start worker those manage requesting process.
  """
  @spec start_manager(list(map)) :: {:ok, pid} | {:error, any}
  def start_manager(libraries_list) do
    Supervisor.start_manager(libraries_list)
  end

  @doc """
  Return requesting status in format {:ok, "downloaded_count/total_count"}.
  """
  @spec get_get_processed_count :: {:ok, binary} | {:error, binary}
  def get_get_processed_count do
    Manager.get_processed()
  end

  @doc """
  Check if download manager run. This is criteria if refreshing process is ongoing
  """
  @spec refreshing_github_data? :: boolean
  def refreshing_github_data? do
    not is_nil(GenServer.whereis(Manager))
  end

  @doc """
  Start proxy maanager
  """
  @spec start_proxy_manager :: {:ok, pid} | {:error, any}
  def start_proxy_manager do
    Supervisor.start_proxy_manager()
  end

  @doc """
  Start RequestWorker for given library data.
  """
  @spec start_request_worker(integer, map) :: {:ok, pid} | {:error, atom}
  def start_request_worker(worker_id, library_data) do
    Supervisor.start_request_worker(%{worker_id: worker_id, library_data: library_data})
  end

  @doc """
  Return free proxy or error if all proxies occupied.
  """
  @spec get_free_proxy :: {:ok, binary} | {:error, :no_available_proxies}
  def get_free_proxy do
    ProxyManager.get_proxy()
  end
end
