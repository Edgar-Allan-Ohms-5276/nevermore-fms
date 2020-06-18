defmodule Nevermore.PubSub.Field do
  @moduledoc false

  def publish(message) do
    Phoenix.PubSub.broadcast(Nevermore.PubSub, "field:0", message)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Nevermore.PubSub, "field:0")
  end

  def unsubscribe() do
    Phoenix.PubSub.unsubscribe(Nevermore.PubSub, "field:0")
  end
end
