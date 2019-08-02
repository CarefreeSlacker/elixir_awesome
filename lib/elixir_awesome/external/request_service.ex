defmodule ElixirAwesome.External.RequestService do
  @moduledoc """
  Download Readme.md file from ElixirAwesome repository
  """

  require Logger

  @file_url Application.get_env(:elixir_awesome, :external)[:readme_file_url]

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

  @user_repo_regex ~r/.+com\/([^\/]+)\/([^\/]+)$/

  @doc """
  Gets library data, parse :url field and merge field to library data
  """
  @spec get_library_identity(map()) :: {:ok, map} | {:error, binary}
  def get_library_identity(%{url: url} = library_data) do
    case Regex.run(@user_repo_regex, url) do
      [_common, author, repo] ->
        {:ok, Map.merge(library_data, %{author: author, repo: repo})}

      nil ->
        {:error, "Wrong url format #{inspect(url)}"}
    end
  end

  def get_library_identity(_library_data),
    do: {:error, "Library params does not have URL attribute"}

  @commit_time_format "{YYYY}-{M}-{D}T{h24}:{m}:{s}Z"

  @doc """
  Perform request with given proxy configurations and basic authentication.
  Decode body.
  If repository moved, perform one more request.
  Then parse commit and return {:ok, NaiveDateTime}.
  If any error happen, return {:error, binary}.
  """
  @spec request_last_commit({binary, binary}, {binary, integer, binary, binary}) ::
          {:ok, NaiveDateTime.t()} | {:error, binary}
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
         {:ok, %HTTPoison.Response{body: body}} <- perform_request(url, proxy_data),
         {:ok, new_decoded_body} <- Jason.decode(body) do
      get_last_commit(new_decoded_body, proxy_data)
    else
      [last_commit | _] -> {:ok, last_commit}
      {:error, error} -> {:error, error}
      %{"message" => "Not Found"} -> {:error, "Repo not found #{}"}
    end
  end

  @max_commit_request_attempts 4

  @doc """
  Perform request with given proxy configurations and basic authentication.
  Decode body.
  If repository moved, perform one more request.
  Then parse commit and return {:ok, NaiveDateTime}.
  If any error happen, return {:error, binary}.
  """
  @spec request_last_commit({binary, binary}, {binary, integer, binary, binary}) ::
          {:ok, NaiveDateTime.t()} | {:error, binary}
  def request_stars_count({author, repo}, proxy_data) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           perform_request("https://api.github.com/repos/#{author}/#{repo}", proxy_data),
         {:ok, decoded_body} <- Jason.decode(body),
         {:ok, stars_count} <- get_stars_count(decoded_body, proxy_data, 0) do
      {:ok, stars_count}
    else
      error ->
        {:error, "Unexpected error #{inspect(error)}"}
    end
  end

  defp get_stars_count(decoded_body, proxy_data, attempts) do
    with true <- attempts < @max_commit_request_attempts,
         %{"url" => url, "message" => "Moved Permanently"} <- decoded_body,
         {:ok, %HTTPoison.Response{body: body}} <- perform_request(url, proxy_data),
         {:ok, new_decoded_body} <- Jason.decode(body |> String.replace("\\\\\\", "\\")) do
      get_stars_count(new_decoded_body, proxy_data, attempts + 1)
    else
      %{"stargazers_count" => stars_count} ->
        {:ok, stars_count}

      false ->
        {:error,
         "Too many attempts #{inspect(attempts)}\nKeys #{inspect(Map.keys(decoded_body))}"}

      error ->
        {:error, error}
    end
  end

  @basic_authentication_credentials Application.get_env(:elixir_awesome, :github_credentials)

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
