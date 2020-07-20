defmodule NevermoreWeb.Errors do
  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Ecto.Changeset{} = changeset} -> format_changeset(changeset)
        val -> val
      end
    end
  end

  defp format_changeset(changeset) do
    errors =
      changeset.errors
      |> Enum.map(fn {key, {value, context}} ->
        [message: "#{key} #{value}", details: Map.new(context)]
      end)

    {:error, errors}
  end
end
