defmodule ElixirAwesome.External.RefreshDataScheduler do
  @moduledoc """
  Perform refreshing libraries data every day at 0:00.
  """

  use Cronex.Scheduler
  alias ElixirAwesome.External.RefreshDataService

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  every(1, :day, at: "10:00") do
    IO.puts("!! scheduler result #{RefreshDataService.perform()}")
    IO.puts("!!! it's time to refresh")
  end

  every(1, :minute) do
    #    result = RefreshDataService.perform()
    #    IO.puts("!!! libraries creation result #{inspect(result)}")
  end
end
