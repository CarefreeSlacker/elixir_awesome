defmodule ElixirAwesome.DomainModel.Section do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirAwesome.DomainModel.Library

  @cast_fields [:name, :comment]
  @required_fields [:name]

  @type t :: %__MODULE__{}

  schema "sections" do
    field :name, :string
    field :comment, :string

    has_many :libraries, Library

    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
