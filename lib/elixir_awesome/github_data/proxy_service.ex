defmodule ElixirAwesome.GithubData.ProxyService do
  @moduledoc """
  Contains logic for manipulating with proxies
  """

  @proxy_configuration_list Application.get_env(:elixir_awesome, :github_data)[:proxies_list]

  def get_proxies_credentials do
    @proxy_configuration_list
    |> Enum.map(fn proxy_data ->
      [host, port, user, password] = String.split(proxy_data, ":")
      {number_port, ""} = Integer.parse(port)
      {host, number_port, user, password}
    end)
  end
end
