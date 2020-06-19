defmodule NevermoreWeb.Resolvers.Team do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def get_team(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Team, args.id)

    if doc != nil do
      {:ok, doc}
    else
      {:error, "Could not find that row."}
    end
  end

  def list_teams(_parent, args, _resolution) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.Team, where: ^Map.to_list(args), order_by: :id
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def create_team(_parent, args, _resolution) do
    Nevermore.Repo.insert(Nevermore.Team.changeset(%Nevermore.Team{}, args))
  end

  def update_team(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Team, args.id)

    if doc != nil do
      Nevermore.Repo.update(Nevermore.Team.changeset(doc, args))
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_team(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Team, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end
end
