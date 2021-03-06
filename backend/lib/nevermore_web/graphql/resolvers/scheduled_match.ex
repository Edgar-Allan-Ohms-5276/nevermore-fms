defmodule NevermoreWeb.Resolvers.ScheduledMatch do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_scheduled_matches(args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.ScheduledMatch, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_scheduled_matches(_, _) do
    {:error, "Not Authenticated"}
  end

  def create_scheduled_match(args, %{context: %{user: _user}}) do
    changeset =
      Nevermore.ScheduledMatch.changeset(%Nevermore.ScheduledMatch{}, args)
      |> put_assoc(Nevermore.Schedule, :schedule, args)
      |> put_assoc(Nevermore.Alliance, :red_station, args)
      |> put_assoc(Nevermore.Alliance, :blue_station, args)

    Nevermore.Repo.insert(changeset)
  end

  def create_scheduled_match(_, _) do
    {:error, "Not Authenticated"}
  end

  def update_scheduled_match(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.ScheduledMatch, args.id)

    if doc != nil do
      changeset =
        Nevermore.ScheduledMatch.changeset(doc, args)
        |> put_assoc(Nevermore.Schedule, :schedule, args)
        |> put_assoc(Nevermore.Alliance, :red_station, args)
        |> put_assoc(Nevermore.Alliance, :blue_station, args)

      Nevermore.Repo.update(changeset)
    else
      {:error, "That id does not exist."}
    end
  end

  def update_scheduled_match(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_scheduled_match(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.ScheduledMatch, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_scheduled_match(_, _) do
    {:error, "Not Authenticated"}
  end
end
