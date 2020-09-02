defmodule Nevermore.Repo.Migrations.CreateAllianceTeams do
  use Ecto.Migration

  def change do
    create table(:alliance_teams) do
      add :alliance_id, references(:alliances, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)
    end

    create index(:alliance_teams, [:alliance_id])
    create index(:alliance_teams, [:team_id])
  end
end
