defmodule Nevermore.Timing do
  @moduledoc false

  def autonomous_time(), do: 15

  def transition_time(), do: 1

  def teleop_time(), do: 105

  def endgame_time(), do: 30

  def format_time(time) do
    cond do
      time > transition_time() + teleop_time() + endgame_time() ->
        time - (transition_time() + teleop_time() + endgame_time())

      time > teleop_time() + endgame_time() && time <= transition_time() + teleop_time() + endgame_time() ->
        0

      time <= teleop_time() + endgame_time() ->
        time
    end
  end
end
