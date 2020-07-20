defmodule Nevermore.Field.Enums do
  @moduledoc false

  def status_good(), do: 0
  def status_bad(), do: 1
  def status_waiting(), do: 2

  def red1(), do: 0
  def red2(), do: 1
  def red3(), do: 2
  def blue1(), do: 3
  def blue2(), do: 4
  def blue3(), do: 5

  def state_notready(), do: 0
  def state_ready(), do: 1
  def state_started(), do: 2
  def state_paused(), do: 3
  def state_inreview(), do: 4
  def state_done(), do: 5

  def mode_teleop(), do: 0
  def mode_test(), do: 1
  def mode_autonomous(), do: 2

  def level_test(), do: 0
  def level_practice(), do: 1
  def level_qualification(), do: 2
  def level_playoff(), do: 3
end
