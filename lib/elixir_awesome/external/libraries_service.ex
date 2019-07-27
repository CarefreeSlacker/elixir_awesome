defmodule ElixirAwesome.External.LibrariesService do
  @moduledoc """
  Perform requesting parsing and writing to database.
  """

  alias ElixirAwesome.External.{DatabaseRecordsService, Parser, RequestService}
  alias ElixirAwesome.GithubData.Api

  @doc """
  First request Readme.md from sweet-xml repository.
  Than parse and draw sections data from it.
  Than request metadata about commit and stars count from github for each library.
  Than create record databases for Sections and Libraries.
  """
  def perform do
    with {:ok, markdown} <- RequestService.get_page(),
         {:ok, sections_data} <- Parser.perform(markdown),
         # RequestService.request_libs_data(sections_data),
         {:ok, enriched_sections_data} <- {:ok, sections_data},
         {:ok, {{created_sec, updated_sec}, {created_lib, updated_lib}}} <-
           create_or_update_database_records(enriched_sections_data),
         {:ok, {deleted_sec, deleted_lib}} <-
           delete_extra_database_records(enriched_sections_data) do
      {:ok,
       "Request successful. #{created_sec} sections created. #{created_lib} libraries created."}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_or_update_database_records(enriched_sections_data) do
    enriched_sections_data
    |> Enum.map(fn section_data ->
      DatabaseRecordsService.create_or_update_section(section_data)
    end)
  end

  defp delete_extra_database_records(enriched_sections_data) do
    enriched_sections_data
    |> Enum.map(fn section_data -> DatabaseRecordsService.delete(section_data) end)
  end
end
