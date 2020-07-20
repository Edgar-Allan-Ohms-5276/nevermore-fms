defmodule NevermoreWeb.GraphQL.Helpers do
  @moduledoc false

  def put_assoc(changeset, _type, atom, args) do
    if Map.has_key?(args, atom) do
      Ecto.Changeset.put_assoc(changeset, atom, args)
    else
      changeset
    end
  end

  def get_page_attrs(args) do
    page = args.page
    page_limit = args.page_limit

    args =
      args
      |> Map.delete(:page)
      |> Map.delete(:page_limit)

    {page, page_limit, args}
  end
end
