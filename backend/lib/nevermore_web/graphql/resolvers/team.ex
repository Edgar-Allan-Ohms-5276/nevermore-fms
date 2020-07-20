defmodule NevermoreWeb.Resolvers.Team do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_teams(args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.Team, where: ^Map.to_list(args), order_by: :id
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_teams(_, _) do
    {:error, "Not Authenticated"}
  end

  def create_team(_parent, args, %{context: %{user: _user}}) do
    Nevermore.Repo.insert(Nevermore.Team.changeset(%Nevermore.Team{}, args))
  end

  def create_team(_, _, _) do
    {:error, "Not Authenticated"}
  end

  def update_team(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Team, args.id)

    if doc != nil do
      Nevermore.Repo.update(Nevermore.Team.changeset(doc, args))
    else
      {:error, "That id does not exist."}
    end
  end

  def update_team(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_team(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Team, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_team(_, _) do
    {:error, "Not Authenticated"}
  end
end
