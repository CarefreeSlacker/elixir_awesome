defmodule ElixirAwesome.External.LibrariesService do
  @moduledoc """
  Perform requesting parsing and writing to database.
  """

  alias ElixirAwesome.External.{LibrariesCreator, Parser, RequestService}

  @doc """
  First request Readme.md from sweet-xml repository. Than parse and draw sections data from it.
  Than create record databases.
  """
  def perform do
    with {:ok, markdown} <- RequestService.perform(),
         {:ok, {sections_data, libraries_data}} <- Parser.perform(markdown),
         {:ok, {created_sections, created_libraries}} <-
           LibrariesCreator.perform(sections_data, libraries_data) do
      {:ok,
       "Request successful. #{length(created_sections)} sections created. #{
         length(created_libraries)
       } libraries created."}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
