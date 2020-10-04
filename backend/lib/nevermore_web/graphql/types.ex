defmodule NevermoreWeb.GraphQL.Types do
  @moduledoc """
  The module `NevermoreWeb.GraphQL.Types` defines generic objects and scalars that are used in the NevermoreWeb.GraphQL` schema.
  """
  use Absinthe.Schema.Notation

  @desc """
  The `success` type is a generic type used in the GraphQL that tells us whether a request was successful.
  """
  object :success do
    field :successful, :boolean
  end

  @desc """
  Taken from [Absinthe Docs](https://hexdocs.pm/absinthe/custom-scalars.html).

  The [`DateTime`](https://hexdocs.pm/elixir/DateTime.html) scalar type represents a date and time in the UTC
  timezone. The DateTime appears in a JSON response as an ISO8601 formatted
  string, including UTC timezone ("Z"). The parsed date and time string will
  be converted to UTC and any UTC offset other than 0 will be rejected.
  """
  scalar :datetime, name: "DateTime" do
    serialize(&NaiveDateTime.to_iso8601/1)
    parse(&parse_datetime/1)
  end

  @desc """
  Parses a `DateTime` object from a string. It assumes the string is a ISO 8601 formatted time stamp.
  """
  @spec parse_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> :error
    end
  end

  defp parse_datetime(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_datetime(_) do
    :error
  end
end
