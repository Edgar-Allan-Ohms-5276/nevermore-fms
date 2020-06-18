defmodule NevermoreWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket,
      schema: NevermoreWeb.Schema

  def connect(params, socket) do
    #current_user = current_user(params)
    #socket = Absinthe.Phoenix.Socket.put_opts(socket, context: %{
      #current_user: current_user
    #})
    {:ok, socket}
  end

  #defp current_user(%{"user_id" => id}) do
    #MyApp.Repo.get(User, id)
  #end

  def id(_socket), do: nil
end
