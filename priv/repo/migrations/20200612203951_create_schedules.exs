defmodule Nevermore.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :name, :string
      add :notes, :string

      timestamps()
    end
  end
end
