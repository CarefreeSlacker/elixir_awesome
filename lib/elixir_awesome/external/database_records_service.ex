defmodule ElixirAwesome.External.DatabaseRecordsService do
  @moduledoc """
  Gets sections data and libraries data and create or update database records.
  """

  alias ElixirAwesome.DomainModel.Context

  @doc """
  Create or update libraries by data given in section_data
  """
  @spec create_or_update(list(map)) ::
          {:ok, {{integer, integer}, {integer, integer}}} | {:error, term}
  def create_or_update(%{name: name, libraries: libraries} = section_data) do
    %{id: section_id} =
      create_if_necessary(section_data, &Context.section_by_name/1, &Context.create_section/1)

    libraries
    |> Enum.map(fn %{name: name} = library_attrs ->
      # TODO except section_id remove merging fields
      library_attrs
      |> Map.merge(%{section_id: section_id, stars: 0, last_commit: NaiveDateTime.utc_now()})
      |> create_if_necessary(&Context.library_by_name/1, &Context.create_library/1)
    end)

    {:ok, {{0, 0}, {0, 0}}}
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

  def create_or_update_section(section_data) do
    create_if_necessary(
      section_data,
      &Context.section_by_name/1,
      &Context.create_section/1,
      &Context.update_section/1
    )
  end

  def create_or_update_library(library_data) do
    create_if_necessary(
      library_data,
      &Context.library_by_name/1,
      &Context.create_library/1,
      &Context.update_library/1
    )
  end

  @doc """
  Delete libraries by data given in sections_data
  """
  @spec delete(list(map)) :: {:ok, {integer, integer}} | {:error, term}
  def delete(section_data) do
    {:ok, {0, 0}}
  end
end
