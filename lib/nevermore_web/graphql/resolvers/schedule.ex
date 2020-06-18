defmodule NevermoreWeb.Resolvers.Schedule do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_schedules(_parent, args, _resolution) do
    query = from Nevermore.Schedule, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.all(query)}
  end

  def create_schedule(_parent, args, _resolution) do
    changeset = Nevermore.Schedule.changeset(%Nevermore.Schedule{}, args)

    Nevermore.Repo.insert(changeset)
  end

  def update_schedule(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Schedule, args.id)

    if doc != nil do
      Nevermore.Repo.update(Nevermore.Schedule.changeset(doc, args))
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_schedule(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.Schedule, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end
end
