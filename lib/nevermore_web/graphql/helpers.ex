defmodule NevermoreWeb.GraphQL.Helpers do
  @moduledoc false

  def put_assoc(changeset, type, atom, args) do
    if Map.has_key?(args, atom) do
      doc = Nevermore.Ecto.get(type, args[atom])
      Ecto.Changeset.put_assoc(changeset, atom, args)
    else
      changeset
    end
  end
end
