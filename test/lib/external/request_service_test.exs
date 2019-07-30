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
  end

  describe "#request_stars_count" do
  end
end
