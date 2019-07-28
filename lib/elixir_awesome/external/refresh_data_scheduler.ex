defmodule ElixirAwesome.External.RefreshDataScheduler do
  @moduledoc """
  Perform refreshing libraries data every day at 0:00.
  """

  use Cronex.Scheduler
  alias ElixirAwesome.External.RefreshDataService

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  every(1, :day, at: "00:00") do
    RefreshDataService.perform()
  end
end
