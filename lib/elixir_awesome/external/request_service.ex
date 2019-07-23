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

  @user_repo_regex ~r/.+\/([^\/]+)\/([^\/]+)$/
  @commit_time_format "{YYYY}-{M}-{D}T{h24}:{m}:{s}Z"

  @doc """
  Request metadata for given libraries.
  Requests stars count and last_commit date_time.
  Enrich given sections data libraries with new information.
  """
  def request_libs_data(sections_data) do
    enriched_sections_data = sections_data
    |> Enum.map(fn %{libraries: libraries} = section_data ->
      enriched_libraries =
        libraries
        |> Enum.map(&request_library_github_data/1)

      Map.put(section_data, :libraries, enriched_libraries)
    end)

    {:ok, enriched_sections_data}
  end

  defp request_library_github_data(%{url: url} = library_data) do
    with [_common, author, repo] <- Regex.run(@user_repo_regex, url),
         {:ok, last_commit_date_time} <- request_last_commit(author, repo),
         {:ok, stars_count} <- request_stars_count(author, repo) do
      Map.merge(library_data, %{last_commit: last_commit_date_time, stars: stars_count})
    else
      nil ->
        {:error, "Wrong url format #{inspect(url)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp request_last_commit(author, repo) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get("https://api.github.com/repos/#{author}/#{repo}/commits", [], []),
         {:ok, [last_commit | _]} <- Jason.decode(body),
         {:ok, naive_date_time} <-
           Timex.parse(last_commit["commit"]["committer"]["date"], @commit_time_format) do
      {:ok, naive_date_time}
    else
      error ->
        {:error, "Unexpected error #{inspect(error)}"}
    end
  end

  defp request_stars_count(author, repo) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get("https://api.github.com/repos/#{author}/#{repo}", [], []),
         {:ok, %{"stargazers_count" => stars_count}} <- Jason.decode(body) do
      {:ok, stars_count}
    else
      error ->
        {:error, "Unexpected error #{inspect(error)}"}
    end
  end
end
