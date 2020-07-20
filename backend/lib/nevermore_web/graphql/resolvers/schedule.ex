defmodule NevermoreWeb.Resolvers.Schedule do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_schedules(args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.Schedule, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_schedules(_, _) do
    {:error, "Not Authenticated"}
  end

  def create_schedule(_parent, args, %{context: %{user: _user}}) do
    changeset = Nevermore.Schedule.changeset(%Nevermore.Schedule{}, args)

    Nevermore.Repo.insert(changeset)
  end

  def create_schedule(_, _, _) do
    {:error, "Not Authenticated"}
  end

  def update_schedule(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Schedule, args.id)

    if doc != nil do
      Nevermore.Repo.update(Nevermore.Schedule.changeset(doc, args))
    else
      {:error, "That id does not exist."}
    end
  end

  def update_schedule(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_schedule(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Schedule, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_schedule(_, _) do
    {:error, "Not Authenticated"}
  end
end
