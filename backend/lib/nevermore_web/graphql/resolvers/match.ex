defmodule NevermoreWeb.Resolvers.Match do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_matches(_parent, args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.Match, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_matches(_, _, _) do
    {:error, "Not Authenticated"}
  end

  def create_match(args, %{context: %{user: _user}}) do
    changeset =
      Nevermore.Match.changeset(%Nevermore.Match{}, args)
      |> put_assoc(Nevermore.Schedule, :schedule, args)
      |> put_assoc(Nevermore.ScheduledMatch, :scheduled_match, args)

    Nevermore.Repo.insert(changeset)
  end

  def create_match(_, _) do
    {:error, "Not Authenticated"}
  end

  def update_match(args, %{context: %{user: _user}}) do
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

  def update_match(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_match(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Match, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_match(_, _) do
    {:error, "Not Authenticated"}
  end
end
