defmodule Nevermore.Repo.Migrations.CreateMatchPenalties do
  use Ecto.Migration

  def change do
    create table(:match_penalties) do
      add :type, :string
      add :occurred_at, :naive_datetime
      add :schedule_id, references(:schedules, on_delete: :nothing)
      add :scheduled_match_id, references(:scheduled_matches, on_delete: :nothing)
      add :match_id, references(:matches, on_delete: :nothing)
      add :alliance_id, references(:alliances, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:match_penalties, [:schedule_id])
    create index(:match_penalties, [:scheduled_match_id])
    create index(:match_penalties, [:match_id])
    create index(:match_penalties, [:alliance_id])
    create index(:match_penalties, [:team_id])
  end
end
