defmodule NevermoreWeb.Resolvers.StationAssignment do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_station_assignments(args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.StationAssignment, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_station_assignments(_, _) do
    {:error, "Not Authenticated"}
  end

  def create_station_assignment(args, %{context: %{user: _user}}) do
    changeset =
      Nevermore.StationAssignment.changeset(%Nevermore.StationAssignment{}, args)
      |> put_assoc(Nevermore.Alliance, :alliance, args)
      |> put_assoc(Nevermore.Team, :station_one, args)
      |> put_assoc(Nevermore.Team, :station_two, args)
      |> put_assoc(Nevermore.Team, :station_three, args)

    Nevermore.Repo.insert(changeset)
  end

  def create_station_assignment(_, _) do
    {:error, "Not Authenticated"}
  end

  def update_station_assignment(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.StationAssignment, args.id)

    if doc != nil do
      changeset =
        Nevermore.StationAssignment.changeset(doc, args)
        |> put_assoc(Nevermore.Alliance, :alliance, args)
        |> put_assoc(Nevermore.Team, :station_one, args)
        |> put_assoc(Nevermore.Team, :station_two, args)
        |> put_assoc(Nevermore.Team, :station_three, args)

      Nevermore.Repo.update(changeset)
    else
      {:error, "That id does not exist."}
    end
  end

  def update_station_assignment(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_station_assignment(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.StationAssignment, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_station_assignment(_, _) do
    {:error, "Not Authenticated"}
  end
end
