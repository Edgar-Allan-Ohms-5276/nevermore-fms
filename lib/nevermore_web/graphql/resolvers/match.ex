defmodule NevermoreWeb.Resolvers.Match do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_matches(_parent, args, _resolution) do
    query = from Nevermore.Match, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.all(query)}
  end

  def create_match(_parent, args, _resolution) do
    changeset =
      Nevermore.Match.changeset(%Nevermore.Match{}, args)
      |> put_assoc(Nevermore.Schedule, :schedule, args)
      |> put_assoc(Nevermore.ScheduledMatch, :scheduled_match, args)

    Nevermore.Repo.insert(changeset)
  end

  def update_match(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Match, args.id)

    if doc != nil do
      changeset =
        Nevermore.Match.changeset(doc, args)
        |> put_assoc(Nevermore.Schedule, :schedule, args)
        |> put_assoc(Nevermore.ScheduledMatch, :scheduled_match, args)

      Nevermore.Repo.update(changeset)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_match(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Match, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end
end
