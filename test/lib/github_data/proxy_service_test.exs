defmodule ElixirAwesome.GithubData.ProxyServiceTest do
  @moduledoc false

  use ElixirAwesome.TestCase
  alias ElixirAwesome.GithubData.ProxyService

  test "#get_proxies_credentials" do
    standard = [
      {"zproxy.lum-superproxy.io", 22_225,
       "lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-38.131.159.167", "lrzxs947e0j7"}
    ]

    assert standard == ProxyService.get_proxies_credentials()
  end
end
