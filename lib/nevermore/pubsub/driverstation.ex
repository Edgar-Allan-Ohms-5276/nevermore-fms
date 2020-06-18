defmodule Nevermore.PubSub.Driverstation do
  @moduledoc false

  def publish(team_num, message) do
    Phoenix.PubSub.broadcast(Nevermore.PubSub, "ds:#{team_num}", message)
  end

  def subscribe(team_num) do
    Phoenix.PubSub.subscribe(Nevermore.PubSub, "ds:#{team_num}")
  end

  def unsubscribe(team_num) do
    Phoenix.PubSub.unsubscribe(Nevermore.PubSub, "ds:#{team_num}")
  end
end
