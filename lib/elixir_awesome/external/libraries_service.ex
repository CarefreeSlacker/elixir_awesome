defmodule ElixirAwesome.External.LibrariesService do
  @moduledoc """
  Perform requesting parsing and writing to database.
  """

  alias ElixirAwesome.External.{LibrariesCreator, Parser, RequestService}

  @doc """
  First request Readme.md from sweet-xml repository.
  Than parse and draw sections data from it.
  Than request metadata about commit and stars count from github for each library.
  Than create record databases for Sections and Libraries.
  """
  def perform do
    with {:ok, markdown} <- RequestService.get_page(),
         {:ok, sections_data} <- Parser.perform(markdown),
         {:ok, enriched_sections_data} <- RequestService.request_libs_data(sections_data),
         {:ok, {{created_sec, updated_sec, deleted_sec}, {created_lib, updated_lib, deleted_lib}}} <-
           LibrariesCreator.perform(enriched_sections_data) do
      {:ok,
       "Request successful. #{created_sec} sections created. #{created_lib} libraries created."}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
