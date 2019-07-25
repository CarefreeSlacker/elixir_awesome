defmodule ElixirAwesome.GithubData.RequestWorker do
  @moduledoc """
  Perform requests
  """

  use GenServer

  # Public API

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, worker_id, name: :"#{__MODULE__}##{worker_id}")
  end

  def get_processed do
    %{processed: processed, total: total} = GenServer.cast(__MODULE__, :get_state)
    "#{processed}/#{total}"
  end

  # Callbacks
  def init(worker_id) do
    {:ok, %{worker_id: worker_id, libraries: []}}
  end
end
