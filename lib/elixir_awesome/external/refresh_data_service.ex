defmodule ElixirAwesome.External.RefreshDataService do
  @moduledoc """
  Perform requesting parsing and writing to database sections and libraries data.
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
         {:ok, raw_sections_data} <- Parser.perform(markdown),
         {:ok, db_sections_data} <- DatabaseRecordsService.create_sections(raw_sections_data),
         {:ok, libraries_data_with_section_id} <-
           DatabaseRecordsService.add_section_id_to_libraries_data(
             db_sections_data,
             raw_sections_data
           ),
         {:ok, _pid} <- Api.start_manager(Enum.take(libraries_data_with_section_id, 30)) do
      {:ok,
       "Request successful. Requesting successful libraries data #{
         inspect(Enum.take(libraries_data_with_section_id, 30))
       }"}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
