defmodule NevermoreWeb.Resolvers.User do
  @moduledoc false

  alias Nevermore.Accounts.User
  alias Nevermore.Repo

  def login(_, params, _) do
    with {:ok, user} <- Nevermore.Session.authenticate(params, Nevermore.Repo),
         {:ok, jwt, _} <- Nevermore.Guardian.encode_and_sign(user, :access) do
      {:ok, %{token: jwt}}
    end
  end

  def update(_, params, _info) do
    Repo.get!(User, params.id)
    |> User.update_changeset(params)
    |> Repo.update()
  end

  def create(_, params, _info) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end
end
