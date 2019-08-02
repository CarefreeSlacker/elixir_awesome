defmodule ElixirAwesome.GithubData.ApiTest do
  @moduledoc false

  use ElixirAwesome.TestCase
  alias ElixirAwesome.GithubData.{Api, Manager, ProxyManager, Supervisor}

  import Mock

  test "#start_manager" do
    response = {:ok, :pid}

    with_mock(Supervisor, start_manager: fn _ -> response end) do
      assert response == Api.start_manager([1, 2, 3])

      assert_called(Supervisor.start_manager(:_))
    end
  end

  test "#get_get_processed_count" do
    response = {:ok, "13/2345"}

    with_mock(Manager, get_processed: fn -> response end) do
      assert response == Api.get_get_processed_count()

      assert_called(Manager.get_processed())
    end
  end

  test "#start_proxy_manager" do
    response = {:ok, :pid}

    with_mock(Supervisor, start_proxy_manager: fn -> response end) do
      assert response == Api.start_proxy_manager()

      assert_called(Supervisor.start_proxy_manager())
    end
  end

  test "#start_request_worker" do
    response = {:ok, "13/2345"}

    with_mock(Supervisor,
      start_request_worker: fn %{worker_id: 1, library_data: %{name: "Library"}} -> response end
    ) do
      assert response == Api.start_request_worker(1, %{name: "Library"})

      assert_called(
        Supervisor.start_request_worker(%{worker_id: 1, library_data: %{name: "Library"}})
      )
    end
  end

  test "#get_free_proxy" do
    response = {:ok, "sdfsdf-lumitati.io:234234:proxy_user:proxy_password"}

    with_mock(ProxyManager, get_proxy: fn -> response end) do
      assert response == Api.get_free_proxy()

      assert_called(ProxyManager.get_proxy())
    end
  end
end
