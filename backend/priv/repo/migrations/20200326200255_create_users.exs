defmodule Nevermore.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :permissions, {:array, :string}
      add :notes, :string

      timestamps()
    end

  end
end
