defmodule ElixirAwesome.DomainModel.Library do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirAwesome.DomainModel.Section

  @cast_fields [:name, :url, :stars, :last_commit, :section_id, :comment]
  @required_fields [:name, :url, :stars, :last_commit, :section_id]

  @type t :: %__MODULE__{}

  schema "libraries" do
    field :name, :string
    field :stars, :integer
    field :url, :string
    field :last_commit, :naive_datetime
    field :comment, :string
    belongs_to :section, Section

    timestamps()
  end

  @doc false
  def changeset(library, attrs) do
    library
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_number(:stars, greater_than_or_equal_to: 0)
  end
end
