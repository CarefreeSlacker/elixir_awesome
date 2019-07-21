defmodule ElixirAwesome.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :name, :string, null: false
      add :comment, :string

      timestamps()
    end

    create unique_index(:sections, :name)
  end
end
