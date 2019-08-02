defmodule ElixirAwesome.External.RequestServiceTest do
  @moduledoc false

  import Mock

  use ElixirAwesome.TestCase
  alias ElixirAwesome.External.RequestService

  describe "#get_page" do
    test "Request page those set in :readme_file_url configuration. Return body." do
      file_url = Application.get_env(:elixir_awesome, :external)[:readme_file_url]
      mocked_body = "{\"mock\": \"body\"}"

      with_mock(HTTPoison,
        get: fn ^file_url, [], [] -> {:ok, %HTTPoison.Response{body: mocked_body}} end
      ) do
        assert {:ok, ^mocked_body} = RequestService.get_page()
      end
    end

    test "Return error if error occurred" do
      file_url = Application.get_env(:elixir_awesome, :external)[:readme_file_url]

      with_mock(HTTPoison,
        get: fn ^file_url, [], [] -> {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} end
      ) do
        assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = RequestService.get_page()
      end
    end
  end

  describe "#get_library_identity" do
    test "Parse :url field and merge :author and :repo fields to library data" do
      url = "https://github.com/awetzel/exos"

      assert {:ok, %{url: url, author: "awetzel", repo: "exos"}} ==
               RequestService.get_library_identity(%{url: url})
    end

    test "Return error if url has wrong format" do
      url = "http://github.com/fail"

      assert {:error, "Wrong url format \"#{url}\""} ==
               RequestService.get_library_identity(%{url: url})
    end

    test "Return error if params does not have :url field" do
      assert {:error, "Library params does not have URL attribute"} ==
               RequestService.get_library_identity(%{a: 1, b: 2})
    end
  end

  describe "#request_last_commit" do
    setup do
      [username: username, password: password] =
        Application.get_env(:elixir_awesome, :github_credentials)

      {:ok,
       author: "awetzel",
       repo: "exos",
       proxy_data: {"zproxy.lum-superproxy.io", 22_225, "proxy_user", "proxy_password"},
       authentication_header:
         {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}}
    end

    test "Return last commit if everything alright", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}/commits"
      first_commit_string_date_time = "2019-04-04T13:13:13Z"
      second_commit_string_date_time = "2019-04-04T13:13:13Z"

      naive_date_time = %NaiveDateTime{
        year: 2019,
        month: 4,
        day: 4,
        hour: 13,
        minute: 13,
        second: 13
      }

      response_body =
        Jason.encode!([
          %{commit: %{committer: %{date: first_commit_string_date_time}}},
          %{commit: %{committer: %{date: second_commit_string_date_time}}}
        ])

      with_mock(HTTPoison,
        request: fn :get,
                    ^url,
                    "",
                    [^authentication_header],
                    proxy: {^host, ^port},
                    proxy_auth: {^proxy_user, ^proxy_password} ->
          {:ok, %HTTPoison.Response{body: response_body}}
        end
      ) do
        assert {:ok, naive_date_time} ==
                 RequestService.request_last_commit({author, repo}, proxy_data)
      end
    end

    test "Return last commit if repo moved.", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}/commits"
      moved_repo_url = "https://api.github.com/repos/12341234"
      first_commit_string_date_time = "2019-04-04T13:13:13Z"
      second_commit_string_date_time = "2019-04-04T13:13:13Z"

      naive_date_time = %NaiveDateTime{
        year: 2019,
        month: 4,
        day: 4,
        hour: 13,
        minute: 13,
        second: 13
      }

      first_response_body = Jason.encode!(%{url: moved_repo_url, message: "Moved Permanently"})

      second_response_body =
        Jason.encode!([
          %{commit: %{committer: %{date: first_commit_string_date_time}}},
          %{commit: %{committer: %{date: second_commit_string_date_time}}}
        ])

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: first_response_body}}

          :get,
          ^moved_repo_url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: second_response_body}}
        end
      ) do
        assert {:ok, naive_date_time} ==
                 RequestService.request_last_commit({author, repo}, proxy_data)
      end
    end

    test "Return error if second request fails", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}/commits"
      moved_repo_url = "https://api.github.com/repos/12341234"
      response_body = Jason.encode!(%{url: moved_repo_url, message: "Moved Permanently"})

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: response_body}}

          :get,
          ^moved_repo_url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
        end
      ) do
        assert {:error, "Unexpected error {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}"} ==
                 RequestService.request_last_commit({author, repo}, proxy_data)
      end
    end

    test "Return error if response failed", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}/commits"

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
        end
      ) do
        assert {:error, "Unexpected error {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}"} ==
                 RequestService.request_last_commit({author, repo}, proxy_data)
      end
    end
  end

  describe "#request_stars_count" do
    setup do
      [username: username, password: password] =
        Application.get_env(:elixir_awesome, :github_credentials)

      {:ok,
       author: "awetzel",
       repo: "exos",
       proxy_data: {"zproxy.lum-superproxy.io", 22_225, "proxy_user", "proxy_password"},
       authentication_header:
         {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}}
    end

    test "Return stars count if everything alright", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}"
      stars_count = 235
      response_body = Jason.encode!(%{stargazers_count: stars_count})

      with_mock(HTTPoison,
        request: fn :get,
                    ^url,
                    "",
                    [^authentication_header],
                    proxy: {^host, ^port},
                    proxy_auth: {^proxy_user, ^proxy_password} ->
          {:ok, %HTTPoison.Response{body: response_body}}
        end
      ) do
        assert {:ok, stars_count} ==
                 RequestService.request_stars_count({author, repo}, proxy_data)
      end
    end

    test "Return stars count if repo moved.", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}"
      moved_repo_url = "https://api.github.com/repos/12341234"
      stars_count = 235
      first_response_body = Jason.encode!(%{url: moved_repo_url, message: "Moved Permanently"})
      second_response_body = Jason.encode!(%{stargazers_count: stars_count})

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: first_response_body}}

          :get,
          ^moved_repo_url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: second_response_body}}
        end
      ) do
        assert {:ok, stars_count} ==
                 RequestService.request_stars_count({author, repo}, proxy_data)
      end
    end

    test "Return error if too many attempts performed", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}"
      moved_repo_url = "https://api.github.com/repos/12341234"
      response_body = Jason.encode!(%{url: moved_repo_url, message: "Moved Permanently"})

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: response_body}}

          :get,
          ^moved_repo_url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:ok, %HTTPoison.Response{body: response_body}}
        end
      ) do
        assert {:error,
                "Unexpected error {:error, \"Too many attempts 4\\nKeys [\\\"message\\\", \\\"url\\\"]\"}"} ==
                 RequestService.request_stars_count({author, repo}, proxy_data)
      end
    end

    test "Return error if response failed", %{
      author: author,
      repo: repo,
      proxy_data: {host, port, proxy_user, proxy_password} = proxy_data,
      authentication_header: authentication_header
    } do
      url = "https://api.github.com/repos/#{author}/#{repo}"

      with_mock(HTTPoison,
        request: fn
          :get,
          ^url,
          "",
          [^authentication_header],
          proxy: {^host, ^port},
          proxy_auth: {^proxy_user, ^proxy_password} ->
            {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
        end
      ) do
        assert {:error, "Unexpected error {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}"} ==
                 RequestService.request_stars_count({author, repo}, proxy_data)
      end
    end
  end
end
