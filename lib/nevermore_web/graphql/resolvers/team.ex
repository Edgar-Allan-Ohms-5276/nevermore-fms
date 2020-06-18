defmodule NevermoreWeb.Resolvers.Team do
  import Ecto.Query, only: [from: 2]

  def list_teams(_parent, args, _resolution) do
    query = from Nevermore.Team, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.all(query)}
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
