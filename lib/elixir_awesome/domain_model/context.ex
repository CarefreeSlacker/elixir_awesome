defmodule ElixirAwesome.DomainModel.Context do
  @moduledoc """
  Contains functions for CRUD manipulations with database
  """

  alias ElixirAwesome.DomainModel.{Library, Section}
  alias ElixirAwesome.Repo

  import Ecto.Query

  @spec create_library(map) :: {:ok, Library.t()} | {:error, Ecto.Changeset.t()}
  def create_library(attributes) do
    %Library{}
    |> Library.changeset(attributes)
    |> Repo.insert()
  end

  @spec update_library(Library.t(), map) :: {:ok, Library.t()} | {:error, Ecto.Changeset.t()}
  def update_library(%Library{} = instance, attributes) do
    instance
    |> Library.changeset(attributes)
    |> Repo.update()
  end

  @spec delete_library(Library.t()) :: {:ok, Library.t()} | {:error, Ecto.Changeset.t()}
  def delete_library(%Library{} = instance) do
    instance
    |> Repo.delete()
  end

  @spec create_section(map) :: {:ok, Section.t()} | {:error, Ecto.Changeset.t()}
  def create_section(attributes) do
    %Section{}
    |> Section.changeset(attributes)
    |> Repo.insert()
  end

  @spec update_section(Section.t(), map) :: {:ok, Section.t()} | {:error, Ecto.Changeset.t()}
  def update_section(%Section{} = instance, attributes) do
    instance
    |> Section.changeset(attributes)
    |> Repo.update()
  end

  @spec delete_section(Section.t()) :: {:ok, Section.t()} | {:error, Ecto.Changeset.t()}
  def delete_section(%Section{} = instance) do
    instance
    |> Repo.delete()
  end

  @spec sections_with_libraries(map) :: list
  def sections_with_libraries(search_params \\ %{})

  def sections_with_libraries(%{min_stars: min_stars}) when not is_nil(min_stars) do
    select_section_with_libraries_query()
    |> where([s, l], l.stars >= ^min_stars)
    |> Repo.all()
  end

  def sections_with_libraries(_search_params) do
    select_section_with_libraries_query()
    |> Repo.all()
  end

  defp select_section_with_libraries_query do
    from(
      s in Section,
      join: l in assoc(s, :libraries),
      preload: :libraries,
      distinct: s.id,
      order_by: s.name
    )
  end
end
