defmodule NevermoreWeb.GraphQL.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        IO.puts(inspect(context))
        put_private(conn, :absinthe, %{context: context})

      thing ->
        IO.puts(inspect(inspect(thing)))
        conn
    end
  end

  defp build_context(conn) do
    with ["User " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- authorize(token) do
      {:ok, %{user: user, token: token}}
    end
  end

  defp authorize(token) do
    case Phoenix.Token.verify(NevermoreWeb.Endpoint, "user auth", token, max_age: 86400) do
      {:ok, user_id} ->
        user = Nevermore.Repo.get(Nevermore.Accounts.User, user_id)

        if user != nil do
          {:ok, user}
        else
          {:error, "Invalid Token"}
        end

      _ ->
        {:error, "Invalid Token"}
    end
  end
end
