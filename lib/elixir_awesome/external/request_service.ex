defmodule ElixirAwesome.External.RequestService do
  @moduledoc """
  Download Readme.md file from ElixirAwesome repository
  """

  @file_url Application.get_env(:elixir_awesome, :external)[:readme_file_url]

  @doc """
  Request data and return {:ok, markdown_file_as_string} | {:error, reason}
  """
  @spec perform :: {:ok, binary} | {:error, term}
  def perform do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(@file_url, [], []) do
      {:ok, body}
    else
      error -> error
    end
  end
end
