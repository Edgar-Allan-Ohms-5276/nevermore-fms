defmodule NevermoreWeb.GraphQL.Helpers do
  @moduledoc false

  def put_assoc(changeset, _type, atom, args) do
    if Map.has_key?(args, atom) do
      Ecto.Changeset.put_assoc(changeset, atom, args)
    else
      changeset
    end
  end
end
