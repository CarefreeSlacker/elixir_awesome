defmodule ElixirAwesome.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :stars, :integer, null: false, default: 0
      add :last_commit, :naive_datetime
      add :section_id, references(:sections, on_delete: :nothing), null: false
      add :comment, :string

      timestamps()
    end

    create unique_index(:libraries, :name)
    create unique_index(:libraries, :url)
    create index(:libraries, [:section_id])
    create index(:libraries, [:stars])
  end
end
