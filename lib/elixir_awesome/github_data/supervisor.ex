defmodule ElixirAwesome.GithubData.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias ElixirAwesome.GithubData.{Manager, ProxyManager, RequestWorker}

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one, resetart: :transient)
  end

  def start_manager do
    DynamicSupervisor.start_child(__MODULE__, {Manager, []})
  end

  def start_proxy_manager do
    DynamicSupervisor.start_child(__MODULE__, {ProxyManager, []})
  end

  def start_request_worker do
    DynamicSupervisor.start_child(__MODULE__, {RequestWorker, :rand.uniform()})
  end
end