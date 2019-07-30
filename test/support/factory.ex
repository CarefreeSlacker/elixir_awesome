defmodule ElixirAwesome.Testing.Factory do
  @moduledoc """
  Contains common API for creating models
  """

  alias ElixirAwesome.Factories.{LibraryFactory, SectionFactory}

  def create(_model, attrs \\ %{})

  def create(:library, attrs) do
    LibraryFactory.create(attrs)
  end

  def create(:section, attrs) do
    SectionFactory.create(attrs)
  end

  def default_attrs(:library) do
    LibraryFactory.default_attrs()
  end

  def default_attrs(:section) do
    SectionFactory.default_attrs()
  end
end
