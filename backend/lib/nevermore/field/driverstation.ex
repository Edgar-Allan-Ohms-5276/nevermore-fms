defmodule Nevermore.Driverstation do
  @moduledoc """
    Defines a Genserver that handles one DriverStation. The Field will create these itself, do not manually create one.
  """

  use Timex

  # Alias the constants modules just for it to look better
  alias Nevermore.Timing
  alias Nevermore.Field.Enums

  defstruct team_num: 0,
            socket: nil,
            field: nil,
            status: 0,
            station: 0,
            # Set this value if you want to emergency stop the robot.
            e_stopped: false,
            request_e_stopped: false,
            comms: false,
            radio_ping: false,
            rio_ping: false,
            # The tick loop automatically detects if the robot should be enabled according to the time, this is what is used to manually disable the robot.
            enabled: true,
            battery_voltage: 0.0,
            udp_sequence_num: 0,
            last_udp_message_time: 0

  import Bitwise

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init({team_num, socket, field}) do
    {:ok,
     %Nevermore.Driverstation{
       team_num: team_num,
       socket: socket,
       field: field,
       last_udp_message_time: Duration.now()
     }}
  end

  def handle_info({:tcp, _socket, packet}, state) do
    if Enum.at(packet, 2) == 0x18 do
      team_num = (Enum.at(packet, 3) <<< 8) + Enum.at(packet, 4)
      send(state.field, {:driverstation_login, team_num, self()})
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    send(state.field, {:driverstation_close, self()})
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _, _reason}, state) do
    {:noreply, state}
  end

  def handle_info({:send_info, status, station}, state) do
    original_state = state
    send_station_info(status, station)
    send_event_name("EAO")
    state = Map.put(state, :status, status)
    state = Map.put(state, :station, station)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info({:send_game_data, data}, state) do
    packet = <<>>

    packet = packet <> <<0x1C>>
    packet = packet <> <<String.length(data)>>
    packet = packet <> data

    send(self(), {:send_tcp_packet, packet})
    {:noreply, state}
  end

  def send_event_name(event_name) do
    packet = <<>>

    packet = packet <> <<0x14>>
    packet = packet <> <<String.length(event_name)>>
    packet = packet <> event_name

    send(self(), {:send_tcp_packet, packet})
  end

  def send_station_info(status, station) do
    packet = <<>>
    packet = packet <> <<0x19>>
    packet = packet <> <<station>>
    packet = packet <> <<status>>

    send(self(), {:send_tcp_packet, packet})
  end

  @doc """
  Returns the driverstation's state
  """
  def handle_call(:get_driverstation, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Sets a key in the state
  """
  def handle_info({:set_state_key, key, value}, state) do
    original_state = state
    state = Map.put(state, key, value)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info({:send_tcp_packet, packet}, state) do
    buffer = <<>>

    # Write short containing packet length
    buffer = buffer <> <<byte_size(packet) >>> 8 &&& 0xFF>>
    buffer = buffer <> <<byte_size(packet) &&& 0xFF>>
    buffer = buffer <> packet

    :gen_tcp.send(state.socket, buffer)
    {:noreply, state}
  end

  def handle_info(
        {:receive_udp, emergency_stop_request, comms, radio_ping, rio_ping, _, _,
         battery_voltage},
        state
      ) do
    original_state = state
    state = Map.put(state, :last_udp_message_time, Duration.now())
    state = Map.put(state, :request_e_stopped, emergency_stop_request)
    state = Map.put(state, :comms, comms)
    state = Map.put(state, :radio_ping, radio_ping)
    state = Map.put(state, :rio_ping, rio_ping)
    state = Map.put(state, :battery_voltage, battery_voltage)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info({:tick, match_state, time_left, match_level, match_num, udp_socket}, state) do
    original_state = state

    if Duration.diff(Duration.now(), state.last_udp_message_time, :seconds) > 10 do
      IO.puts("here912")
      send(self(), :kick)
      {:noreply, state}
    else
      # Figure out if this DS should be enabled.
      enabled =
        if !should_be_enabled(match_state, time_left) do
          if match_level == Enums.level_test() do
            state.enabled
          else
            false
          end
        else
          state.enabled
        end

      # Get the current mode the ds should be in
      mode = get_current_mode(time_left, match_level)

      # Get the current time
      time = Timex.now()
      {microseconds, _} = time.microsecond
      time_left = Timing.format_time(time_left)

      # Write a short containing the udp sequence number
      # Unknown use
      # Unknown use
      # We don't really care to tell the ds about the replay num. But maybe later.
      packet =
        <<state.udp_sequence_num >>> 8 &&& 0xFF>> <>
          <<state.udp_sequence_num &&& 0xFF>> <>
          <<0x00>> <>
          <<(boolean_to_integer(state.e_stopped) <<< 7) + (boolean_to_integer(enabled) <<< 2) +
              mode>> <>
          <<0x00>> <>
          <<state.station>> <>
          <<match_level>> <>
          <<match_num >>> 8 &&& 0xFF>> <>
          <<match_num &&& 0xFF>> <>
          <<0x00>> <>
          <<(microseconds * 1000) >>> (8 * 3) &&& 0xFF>> <>
          <<(microseconds * 1000) >>> (8 * 2) &&& 0xFF>> <>
          <<(microseconds * 1000) >>> (8 * 1) &&& 0xFF>> <>
          <<microseconds * 1000 &&& 0xFF>> <>
          <<time.second &&& 0xFF>> <>
          <<time.minute &&& 0xFF>> <>
          <<time.hour &&& 0xFF>> <>
          <<time.day &&& 0xFF>> <>
          <<time.month &&& 0xFF>> <>
          <<time.year &&& 0xFF>> <>
          <<time_left >>> 8 &&& 0xFF>> <>
          <<time_left &&& 0xFF>>

      # Get the ip using the tcp socket TODO: Do this on init? Maybe?
      {:ok, {ip, _}} = :inet.peername(state.socket)

      :gen_udp.send(udp_socket, ip, 1121, packet)

      state =
        state
        |> Map.put(:udp_sequence_num, state.udp_sequence_num + 1)

      check_state_and_publish(original_state, state)
      {:noreply, state}
    end
  end

  def handle_info(:kick, state) do
    send(state.field, {:driverstation_close, self()})
    {:stop, :normal, state}
  end

  defp get_current_mode(time_left, match_level) do
    if match_level == Enums.level_test() do
      Enums.mode_test()
    else
      if time_left > Timing.transition_time() + Timing.teleop_time() + Timing.endgame_time() do
        Enums.mode_autonomous()
      else
        Enums.mode_teleop()
      end
    end
  end

  defp boolean_to_integer(bool) do
    if bool, do: 1, else: 0
  end

  defp should_be_enabled(match_state, time_left) do
    if match_state == Enums.state_started() do
      cond do
        time_left > Timing.transition_time() + Timing.teleop_time() + Timing.endgame_time() ->
          true

        time_left > Timing.teleop_time() + Timing.endgame_time() ->
          false

        time_left > 0 ->
          true

        # This is essentially the final else in an else if sequence. (It is ran if all others fail)
        true ->
          false
      end
    else
      false
    end
  end

  defp check_state_and_publish(original_state, new_state) do
    if original_state != new_state do
      Absinthe.Subscription.publish(NevermoreWeb.Endpoint, new_state,
        driverstation_update: "driverstation_update_#{new_state.team_num}"
      )
    end
  end

  # Helper Functions

  @doc """
  Returns the state of the DS.
  """
  @spec get_state(pid()) :: none()
  def get_state(ds) do
    GenServer.call(ds, :get_driverstation)
  end

  @doc """
  Sets the enabled value for the driverstation, if true the robot is enabled.
  """
  @spec set_enabled(pid(), atom()) :: none()
  def set_enabled(ds, enabled) do
    send(ds, {:set_state_key, :enabled, enabled})
  end

  @doc """
  Sets the e_stop value for the driverstation, if true the robot is e_stopped.
  """
  @spec set_e_stopped(pid(), atom()) :: none()
  def set_e_stopped(ds, e_stopped) do
    send(ds, {:set_state_key, :e_stopped, e_stopped})
  end

  @doc """
  Kicks the driverstation.
  """
  @spec kick(pid()) :: none()
  def kick(ds) do
    send(ds, :kick)
  end
end
