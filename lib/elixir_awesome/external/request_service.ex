defmodule ElixirAwesome.External.RequestService do
  @moduledoc """
  Download Readme.md file from ElixirAwesome repository
  """

  require Logger

  @file_url Application.get_env(:elixir_awesome, :external)[:readme_file_url]
  @await_between_requests_interval Application.get_env(:elixir_awesome, :github_data)[
                                     :between_requests_interval
                                   ]
  @basic_authentication_credentials Application.get_env(:elixir_awesome, :github_credentials)

  @doc """
  Request data and return {:ok, markdown_file_as_string} | {:error, reason}
  """
  @spec get_page :: {:ok, binary} | {:error, term}
  def get_page do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(@file_url, [], []) do
      {:ok, body}
    else
      error -> error
    end
  end

  @user_repo_regex ~r/.+\/([^\/]+)\/([^\/]+)$/
  @commit_time_format "{YYYY}-{M}-{D}T{h24}:{m}:{s}Z"

  def get_library_identity(%{url: url} = library_data) do
    with [_common, author, repo] <- Regex.run(@user_repo_regex, url) do
      Map.merge(library_data, %{author: author, repo: repo})
    else
      nil ->
        {:error, "Wrong url format #{inspect(url)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def request_last_commit({author, repo}, proxy_data) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           perform_request("https://api.github.com/repos/#{author}/#{repo}/commits", proxy_data),
         {:ok, decoded_body} <- Jason.decode(body),
         {:ok, last_commit} <- get_last_commit(decoded_body, proxy_data),
         {:ok, naive_date_time} <-
           Timex.parse(last_commit["commit"]["committer"]["date"], @commit_time_format) do
      {:ok, naive_date_time}
    else
      error ->
        {:error, "Unexpected error #{inspect(error)}"}
    end
  end

  defp get_last_commit(decoded_body, proxy_data) do
    with %{"url" => url} <- decoded_body,
         :ok <- :timer.sleep(@await_between_requests_interval),
         {:ok, %HTTPoison.Response{body: body}} <- perform_request(url, proxy_data),
         {:ok, new_decoded_body} <- Jason.decode(body) do
      get_last_commit(new_decoded_body, proxy_data)
    else
      [last_commit | _] -> {:ok, last_commit}
      error -> {:error, error}
    end
  end

  def request_stars_count({author, repo}, proxy_data) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           perform_request("https://api.github.com/repos/#{author}/#{repo}", proxy_data),
         {:ok, %{"stargazers_count" => stars_count}} <- Jason.decode(body) do
      {:ok, stars_count}
    else
      error ->
        {:error, "Unexpected error #{inspect(error)}"}
    end
  end

  defp perform_request(url, {host, port, proxy_user, proxy_password}) do
    HTTPoison.request(
      :get,
      url,
      "",
      [basic_authentication_header(@basic_authentication_credentials)],
      proxy: {host, port},
      proxy_auth: {proxy_user, proxy_password}
    )
  end

  defp basic_authentication_header(username: username, password: password) do
    {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}
  end
end
