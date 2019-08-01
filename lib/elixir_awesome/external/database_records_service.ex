defmodule ElixirAwesome.External.DatabaseRecordsService do
  @moduledoc """
  Gets sections data and libraries data and create or update database records.
  """

  alias ElixirAwesome.DomainModel.{Context, Section}

  @doc """
  Create new of update old sections by given sections data.
  Sections data is list of maps with attributes `%{name: binary, comment: binary}`.
  Find existing sections in database by name. Because there are not other valid attributes.
  """
  @spec create_sections(list(map)) :: {:ok, list(Section.t())}
  def create_sections(sections_data) do
    section_db_records =
      sections_data
      |> Enum.map(fn section_data -> create_or_update_section(section_data) end)

    {:ok, section_db_records}
  end

  @doc """
  Sections data with libraries and sections records.
  Gets all libraries data and enrich them with section_id from records.
  """
  @spec add_section_id_to_libraries_data(list(map), list(Section.t())) :: {:ok, list(map)}
  def add_section_id_to_libraries_data(section_db_records, raw_sections_data) do
    libraries_data_with_section_id =
      section_db_records
      |> Enum.zip(raw_sections_data)
      |> Enum.reduce([], fn {%{id: section_id}, %{libraries: libraries_data}}, acc ->
        acc ++
          Enum.map(libraries_data, fn library_data ->
            Map.put(library_data, :section_id, section_id)
          end)
      end)

    {:ok, libraries_data_with_section_id}
  end

  defp create_or_update_section(section_data) do
    create_if_necessary(
      section_data,
      &Context.section_by_name/1,
      &Context.create_section/1,
      &Context.update_section/2
    )
  end

  def create_or_update_library(library_data) do
    create_if_necessary(
      library_data,
      &Context.library_by_name/1,
      &Context.create_library/1,
      &Context.update_library/2
    )
  end

  defp create_if_necessary(
         %{name: name} = data_map,
         find_function,
         create_function,
         update_function
       ) do
    case find_function.(name) do
      nil ->
        {:ok, record} = create_function.(data_map)
        record

      record ->
        {:ok, record} = update_function.(record, data_map)
        record
    end
  end
end
