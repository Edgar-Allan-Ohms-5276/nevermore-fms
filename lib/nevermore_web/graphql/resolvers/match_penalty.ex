defmodule NevermoreWeb.Resolvers.MatchPenalty do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def get_match_penalty(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.MatchPenalty, args.id)

    if doc != nil do
      {:ok, doc}
    else
      {:error, "Could not find that row."}
    end
  end

  def list_match_penalties(_parent, args, _resolution) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.MatchPenalty, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def create_match_penalty(_parent, args, _resolution) do
    changeset =
      Nevermore.MatchPenalty.changeset(%Nevermore.MatchPenalty{}, args)
      |> put_assoc(Nevermore.Schedule, :schedule, args)
      |> put_assoc(Nevermore.ScheduledMatch, :scheduled_match, args)
      |> put_assoc(Nevermore.Match, :match, args)
      |> put_assoc(Nevermore.StationAssignment, :station_assignment, args)
      |> put_assoc(Nevermore.Alliance, :alliance, args)

    Nevermore.Repo.insert(changeset)
  end

  def update_match_penalty(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.MatchPenalty, args.id)

    if doc != nil do
      changeset =
        Nevermore.MatchPenalty.changeset(doc, args)
        |> put_assoc(Nevermore.Schedule, :schedule, args)
        |> put_assoc(Nevermore.ScheduledMatch, :scheduled_match, args)
        |> put_assoc(Nevermore.Match, :match, args)
        |> put_assoc(Nevermore.StationAssignment, :station_assignment, args)
        |> put_assoc(Nevermore.Alliance, :alliance, args)

      Nevermore.Repo.update(changeset)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_match_penalty(_parent, args, _resolution) do
    doc = Nevermore.Repo.get(Nevermore.MatchPenalty, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end
end
