defmodule ElixirAwesome.GithubData.ProxyManagerTest do
  @moduledoc false

  use ElixirAwesome.TestCase
  alias ElixirAwesome.GithubData.ProxyManager

  setup do
    {:ok, pid} = ProxyManager.start_link([])

    on_exit(fn ->
      :ok = ProxyManager.finish_work()
    end)

    {:ok, pid: pid}
  end

  describe "#get_proxy" do
    setup do
      {
        :ok,
        caller_process_mock_function: fn time_await, watcher ->
          fn ->
            received_value = ProxyManager.get_proxy()
            :timer.sleep(time_await)
            Process.send_after(watcher, {:received_value, received_value}, 0)
          end
        end
      }
    end

    test "Return first proxy from list", %{
      caller_process_mock_function: caller_process_mock_function
    } do
      proxy_standard =
        {"zproxy.lum-superproxy.io", 22225,
         "lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-38.131.159.167", "lrzxs947e0j7"}

      {:ok, _caller_pid} = Task.start_link(caller_process_mock_function.(50, self()))

      receive do
        {:received_value, {:ok, ^proxy_standard}} ->
          assert true
      after
        500 ->
          assert false
      end
    end

    test "Return error if all proxies occupied", %{
      caller_process_mock_function: caller_process_mock_function
    } do
      {:ok, _caller1_pid} = Task.start_link(caller_process_mock_function.(100, self()))

      # We message from this Task. It's callback time is much less than first
      {:ok, _caller2_pid} = Task.start_link(caller_process_mock_function.(10, self()))

      receive do
        {:received_value, {:error, :no_available_proxies}} ->
          assert true
      after
        500 ->
          assert false
      end
    end

    test "After process terminating free occupied proxies", %{
      caller_process_mock_function: caller_process_mock_function
    } do
      {:ok, _caller1_pid} = Task.start_link(caller_process_mock_function.(50, self()))

      # We message from this Task. It's callback time is much less than first
      {:ok, _caller2_pid} = Task.start_link(caller_process_mock_function.(10, self()))

      receive do
        {:received_value, {:error, :no_available_proxies}} ->
          assert true
      after
        500 ->
          assert false
      end

      :timer.sleep(50)

      proxy_standard =
        {"zproxy.lum-superproxy.io", 22225,
         "lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-38.131.159.167", "lrzxs947e0j7"}

      {:ok, _caller_pid} = Task.start_link(caller_process_mock_function.(50, self()))

      receive do
        {:received_value, {:ok, ^proxy_standard}} ->
          assert true
      after
        500 ->
          assert false
      end
    end
  end

  describe "#finish_work" do
    test "Stop process after calling API method", %{pid: pid} do
      assert ^pid = GenServer.whereis(ProxyManager)

      ProxyManager.finish_work()
      :timer.sleep(50)

      assert is_nil(GenServer.whereis(ProxyManager))
    end
  end
end
