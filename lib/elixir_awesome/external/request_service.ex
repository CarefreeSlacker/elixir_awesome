defmodule ElixirAwesome.External.RequestService do
  @moduledoc """
  Download Readme.md file from ElixirAwesome repository
  """

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

  @doc """
  Request metadata for given libraries.
  Requests stars count and last_commit date_time.
  Enrich given sections data libraries with new information.
  """
  def request_libs_data(sections_data) do
  end
end
