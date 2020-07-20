defmodule Nevermore.Repo.Migrations.CreateAlliances do
  use Ecto.Migration

  def change do
    create table(:alliances) do
      add :name, :string
      add :notes, :string

      timestamps()
    end
  end
end
