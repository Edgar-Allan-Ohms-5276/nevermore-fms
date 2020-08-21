defmodule Nevermore.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :notes, :string
      add :final, :boolean
      add :schedule_id, references(:schedules, on_delete: :nothing)
      add :scheduled_match_id, references(:scheduled_matches, on_delete: :nothing)

      timestamps()
    end

    create index(:matches, [:schedule_id])
    create index(:matches, [:scheduled_match_id])
  end
end
