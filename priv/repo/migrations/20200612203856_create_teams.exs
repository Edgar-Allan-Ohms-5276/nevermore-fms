defmodule Nevermore.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :logo_url, :string
      add :song_url, :string
      add :notes, :string

      timestamps()
    end
  end
end
