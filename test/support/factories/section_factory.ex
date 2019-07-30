defmodule ElixirAwesome.Factories.SectionFactory do
  @moduledoc false

  alias ElixirAwesome.Repo
  alias ElixirAwesome.DomainModel.{Section, Context}

  def create(attrs \\ %{}) do
    default_attrs()
    |> Map.merge(attrs)
    |> Context.create_section()
  end

  def default_attrs do
    %{
      name: "Section Name #{:rand.uniform(9999)}",
      comment: "Section comment ##{:rand.uniform(9999)}"
    }
  end
end
