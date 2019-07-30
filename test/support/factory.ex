defmodule ElixirAwesome.Testing.Factory do
  @moduledoc """
  Contains common API for creating models
  """

  alias ElixirAwesome.Factories.{Library, Section}

  def create(_model, attrs \\ %{})

  def create(:library, attrs) do
    Library.create(attrs)
  end

  def create(:section, attrs) do
    Section.create(attrs)
  end

  def default_attrs(:library) do
    Library.default_attrs()
  end

  def default_attrs(:section) do
    Section.default_attrs()
  end
end
