defmodule NevermoreWeb.Resolvers.Alliance do
  import Ecto.Query, only: [from: 2]
  import NevermoreWeb.GraphQL.Helpers

  def list_alliances(_parent, args, %{context: %{user: _user}}) do
    {page, page_limit, args} = get_page_attrs(args)
    query = from Nevermore.Alliance, where: ^Map.to_list(args)
    {:ok, Nevermore.Repo.paginate(query, page: page, page_size: page_limit)}
  end

  def list_alliances(_, _, _) do
    {:error, "Not Authenticated"}
  end

  def create_alliance(args, %{context: %{user: _user}}) do
    changeset = Nevermore.Alliance.changeset(%Nevermore.Alliance{}, args)

    if Map.has_key?(args, :teams) do
      # Get all teams
      teams =
        Enum.reduce(args.teams, [], fn team_num, teams ->
          team_doc =
            Nevermore.Team
            |> Nevermore.Repo.get(team_num)
            |> Nevermore.Repo.preload(:alliances)

          if team_doc != nil do
            teams ++ [team_doc]
          else
            teams
          end
        end)

      changeset = Ecto.Changeset.put_assoc(changeset, :teams, teams)
      Nevermore.Repo.insert(changeset)
    else
      Nevermore.Repo.insert(changeset)
    end
  end

  def create_alliance(_, _) do
    {:error, "Not Authenticated"}
  end

  def update_alliance(args, %{context: %{user: _user}}) do
    doc =
      Nevermore.Alliance
      |> Nevermore.Repo.get(args.id)
      |> Nevermore.Repo.preload(:teams)

    if doc != nil do
      changeset = Nevermore.Alliance.changeset(doc, args)

      if Map.has_key?(args, :teams) do
        # Get all teams
        teams =
          Enum.reduce(args.teams, [], fn team_num, teams ->
            team_doc =
              Nevermore.Team
              |> Nevermore.Repo.get(team_num)
              |> Nevermore.Repo.preload(:alliances)

            if team_doc != nil do
              [team_doc | teams]
            else
              teams
            end
          end)

        changeset = Ecto.Changeset.put_assoc(changeset, :teams, teams)
        Nevermore.Repo.update(changeset)
      else
        Nevermore.Repo.update(changeset)
      end
    else
      {:error, "That id does not exist."}
    end
  end

  def update_alliance(_, _) do
    {:error, "Not Authenticated"}
  end

  def delete_alliance(args, %{context: %{user: _user}}) do
    doc = Nevermore.Repo.get(Nevermore.Alliance, args.id)

    if doc != nil do
      Nevermore.Repo.delete(doc)
    else
      {:error, "That id does not exist."}
    end
  end

  def delete_alliance(_, _) do
    {:error, "Not Authenticated"}
  end
end
