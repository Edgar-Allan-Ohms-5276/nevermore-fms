defmodule Mix.Tasks.CreateAdmin do
  use Mix.Task

  alias Nevermore.Accounts.User
  alias Nevermore.Repo

  @shortdoc "Creates a new admin. `mix create_admin Test test@test.com testtest`"
  def run(args) do
    %User{}
    |> User.registration_changeset(%{ name: Enum.at(args, 0), email: Enum.at(args, 1), password: Enum.at(args, 2)})
    |> Repo.insert()
  end
end
