defmodule ElixirAwesome.GithubData.ProxyManager do
  @moduledoc """
  Store Proxy data inside itself. Keep free and occupied proxies list.
  """

  use Agent

  @proxy_configuration_list []

  def start_link(_opts) do
    Agent.start_link(fn -> %{free_proxies: @proxy_configuration_list, occupied_proxies: []} end,
      name: __MODULE__
    )
  end
end
