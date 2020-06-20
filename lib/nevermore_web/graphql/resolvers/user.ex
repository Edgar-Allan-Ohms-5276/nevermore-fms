defmodule NevermoreWeb.Resolvers.User do
  @moduledoc false

  alias Nevermore.Accounts.User
  alias Nevermore.Repo

  def login(_, params, _) do
    with {:ok, user} <- Nevermore.Session.authenticate(params, Nevermore.Repo),
         token <- Phoenix.Token.sign(NevermoreWeb.Endpoint, "user auth", user.id) do
      {:ok, %{token: token}}
    end
  end

  def update(_, params, %{context: %{user: _user}}) do
    Repo.get!(User, params.id)
    |> User.update_changeset(params)
    |> Repo.update()
  end

  def update(_, _, _) do
    {:error, "Not Authenticated"}
  end

  def create(_, params, %{context: %{user: _user}}) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  def create(_, _, _) do
    {:error, "Not Authenticated"}
  end
end
