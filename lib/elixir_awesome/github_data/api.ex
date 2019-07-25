defmodule ElixirAwesome.GithubData.Api do
  @moduledoc """
  For getting data for all libraries we need to perform ~2000 requests.
  It will face to anti-spam protection. To solve this problem i will use proxies.
  We gonna send data with delays via proxies.
  Besides that we have distinct count of proxies.
  So we need something to manage proxies and workers.
  This module contains functions for managing and monitoring data requesting process.
  """

  @doc """
  Start worker those manage requesting process.
  """
  @spec start_request_manager(list(map)) :: {:ok, pid} | {:error, any}
  def start_request_manager(libraries_list) do
    {:ok, :pid}
  end

  @doc """
  Return requesting status in format {:ok, "downloaded_count/total_count"}.
  """
  @spec get_processed_status :: {:ok, binary} | {:error, binary}
  def get_processed_status do
    {:ok, "0/0"}
  end

  @doc """
  Gets worker data from manager
  """
  @spec get_worker_data :: {:ok, binary}
  def get_worker_data do
    {:ok, "0/0"}
  end

  @doc """
  Start RequestWorker for given library data.
  """
  @spec start_request_worker :: {:ok, pid} | {:error, atom}
  def start_request_worker do
    {:ok, "0/0"}
  end

  @doc """
  Return free proxy or error if all proxies occupied.
  """
  @spec get_free_proxy :: {:ok, pid} | {:error, atom}
  def get_free_proxy do
    {:ok, "0/0"}
  end

  @doc """
  Free given proxy.
  """
  @spec free_proxy(binary) :: {:ok, pid} | {:error, atom}
  def free_proxy(binary) do
    {:ok, "0/0"}
  end
end
