defmodule Nevermore.Field do
  @moduledoc """
    Defines a Genserver that handles one singular FRC field. Do not directly create this, use the FieldManager Genserver to create fields.
  """

  # We do bitmath in here so import Bitwise
  import Bitwise

  # Alias the constants modules just for it to look better
  alias Nevermore.Timing
  alias Nevermore.Field.Enums

  # This defines the field state
  defstruct id: 0,
            ip: nil,
            udp_port: 0,
            tcp_port: 0,
            udp_socket: nil,
            tcp_error: nil,
            udp_error: nil,
            match_num: 0,
            match_state: 0,
            time_left: 0,
            event_name: "",
            match_level: 0,
            match_started_at: 0,
            alliance_station_to_driverstation: %{},
            team_num_to_alliance_station: %{},
            driver_stations: []

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    ip = {10, 0, 100, 5}
    udp_port = 1160
    tcp_port = 1750

    # Open a udp server on udp_port
    socket =
      case :gen_udp.open(udp_port, [:list, ip: ip]) do
        {:error, reason} ->
          send(self(), {:cant_bind_udp, reason})
          nil

        {:ok, socket} ->
          :gen_udp.controlling_process(socket, self())
          socket
      end

    field_pid = self()
    spawn(fn -> start_tcp_server(ip, tcp_port, field_pid) end)

    # Start the tick loop and timer
    send(self(), :tick)
    send(self(), :timer)

    IO.puts("here")

    {:ok,
     %Nevermore.Field{
       ip: ip,
       tcp_port: tcp_port,
       udp_port: udp_port,
       udp_socket: socket
     }}
  end

  def start_tcp_server(ip, port, field) do
    socket =
      case :gen_tcp.listen(port, [:list, ip: ip]) do
        {:error, reason} ->
          send(field, {:cant_bind_tcp, reason})
          nil

        {:ok, socket} ->
          send(field, :tcp_good)
          socket
      end

    if socket != nil do
      loop_acceptor(socket, field)
    end
  end

  def loop_acceptor(socket, field) do
    try do
      {:ok, client} = :gen_tcp.accept(socket)
      {:ok, ds} = GenServer.start_link(Nevermore.Driverstation, {0, client, field})
      :gen_tcp.controlling_process(client, ds)
    catch
      _ -> nil
    end

    loop_acceptor(socket, field)
  end

  def handle_info({:cant_bind_udp, error}, state) do
    original_state = state
    state = Map.put(state, :udp_error, error)
    Process.send_after(self(), :retry_bind_udp, 500)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info(:retry_bind_udp, state) do
    original_state = state
    socket =
      case :gen_udp.open(state.udp_port, [:list, ip: state.ip]) do
        {:error, _} ->
          nil

        {:ok, socket} ->
          :gen_udp.controlling_process(socket, self())
          socket
      end

    if socket != nil do
      state = Map.put(state, :udp_error, nil)
      check_state_and_publish(original_state, state)
      {:noreply, state}
    else
      Process.send_after(self(), :retry_bind_udp, 500)
      {:noreply, state}
    end
  end

  def handle_info({:cant_bind_tcp, error}, state) do
    original_state = state
    state = Map.put(state, :tcp_error, error)
    Process.send_after(self(), :retry_bind_tcp, 500)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info(:tcp_good, state) do
    original_state = state
    state = Map.put(state, :tcp_error, nil)
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  def handle_info(:retry_bind_tcp, state) do
    field_pid = self()
    spawn(fn -> start_tcp_server(state.ip, state.tcp_port, field_pid) end)
    {:noreply, state}
  end

  def handle_info({:driverstation_login, team_num, driverstation}, state) do
    original_state = state
    state = Map.put(state, :driver_stations, state.driver_stations ++ [driverstation])

    state =
      if Map.has_key?(state.team_num_to_alliance_station, team_num) do
        send(
          driverstation,
          {:send_info, Enums.status_good(), state.team_num_to_alliance_station[team_num]}
        )

        new_alliance_map =
          Map.put(
            state.alliance_station_to_driverstation,
            state.team_num_to_alliance_station[team_num],
            driverstation
          )

        state = Map.put(state, :alliance_station_to_driverstation, new_alliance_map)
        state
      else
        send(driverstation, {:send_info, Enums.status_waiting(), Enums.red1()})
        state
      end

    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  @doc """
  Sets up the field for a new match
  """
  def handle_info(
        {:setup_field, match_num, tournament_level, red1, red2, red3, blue1, blue2, blue3},
        state
      ) do
    original_state = state
    kick_all(state)
    new_team_to_station = %{}
    new_team_to_station = Map.put(new_team_to_station, red1, Enums.red1())
    new_team_to_station = Map.put(new_team_to_station, red2, Enums.red2())
    new_team_to_station = Map.put(new_team_to_station, red3, Enums.red3())
    new_team_to_station = Map.put(new_team_to_station, blue1, Enums.blue1())
    new_team_to_station = Map.put(new_team_to_station, blue2, Enums.blue2())
    new_team_to_station = Map.put(new_team_to_station, blue3, Enums.blue3())

    # You can blame immutability for the terrible code that is about to be written
    alliance_station_to_driverstation = %{}

    alliance_station_to_driverstation =
      if red1 != nil || red1 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.red1(), nil)
      end

    alliance_station_to_driverstation =
      if red2 != nil || red2 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.red2(), nil)
      end

    alliance_station_to_driverstation =
      if red3 != nil || red3 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.red3(), nil)
      end

    alliance_station_to_driverstation =
      if blue1 != nil || blue1 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.blue1(), nil)
      end

    alliance_station_to_driverstation =
      if blue2 != nil || blue2 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.blue2(), nil)
      end

    alliance_station_to_driverstation =
      if blue3 != nil || blue3 != 0 do
        Map.put(alliance_station_to_driverstation, Enums.blue3(), nil)
      end

    state = Map.put(state, :team_num_to_alliance_station, new_team_to_station)
    state = Map.put(state, :alliance_station_to_driverstation, alliance_station_to_driverstation)
    state = Map.put(state, :match_num, match_num)
    state = Map.put(state, :match_level, tournament_level)
    state = Map.put(state, :match_state, Enums.state_notready())

    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  def handle_info({:driverstation_close, driverstation}, state) do
    original_state = state
    state = Map.put(state, :driver_stations, List.delete(state.driver_stations, driverstation))

    state =
      try do
        Enum.each(state.alliance_station_to_driverstation, fn {station, ds} ->
          if driverstation == ds do
            throw(station)
          end
        end)

        state
      catch
        station ->
          new_alliance_to_ds = Map.delete(state.alliance_station_to_driverstation, station)
          Map.put(state, :alliance_station_to_driverstation, new_alliance_to_ds)
      end

    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  @doc """
  Handles a UDP message to the FMS.
  """
  def handle_info({:udp, _socket, _address, _port, data}, state) do
    if length(data) < 8 do
      {:noreply, state}
    else
      emergency_stop_request = (Enum.at(data, 3) >>> 7 &&& 0x01) == 1
      comms = (Enum.at(data, 3) >>> 5 &&& 0x01) == 1
      radio_ping = (Enum.at(data, 3) >>> 4 &&& 0x01) == 1
      rio_ping = (Enum.at(data, 3) >>> 3 &&& 0x01) == 1
      enabled = (Enum.at(data, 3) >>> 2 &&& 0x01) == 1
      mode = Enum.at(data, 3) &&& 0x03
      team_number = (Enum.at(data, 4) <<< 8) + Enum.at(data, 5)
      battery_voltage = Enum.at(data, 6) + Enum.at(data, 7) / 256

      if Map.has_key?(state.team_num_to_alliance_station, team_number) do
        send(
          state.alliance_station_to_driverstation[
            state.team_num_to_alliance_station[team_number]
          ],
          {:receive_udp, emergency_stop_request, comms, radio_ping, rio_ping, enabled, mode,
           battery_voltage}
        )
      end

      {:noreply, state}
    end
  end

  def handle_info({:udp_error, _, _}, state) do
    {:noreply, state}
  end

  @doc """
  Starts the field
  """
  def handle_info(:start_field, state) do
    original_state = state
    state =
      Map.put(
        state,
        :time_left,
        Timing.autonomous_time() + Timing.transition_time() + Timing.teleop_time() +
          Timing.endgame_time()
      )

    state = Map.put(state, :match_state, Enums.state_started())
    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  @doc """
  Stops the field
  """
  def handle_info({:stop_field, is_early}, state) do
    original_state = state
    state =
      if is_early do
        state = Map.put(state, :match_state, Enums.state_done())
        state
      else
        state = Map.put(state, :match_state, Enums.state_inreview())
        state
      end

    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  @doc """
  Pauses the field
  """
  def handle_info(:pause_field, state) do
    original_state = state
    state = Map.put(state, :match_state, Enums.state_paused())
    check_state_and_publish(original_state, state)
    {:noreply, state}
  end

  @doc """
  Unpauses the field
  """
  def handle_info(:unpause_field, state) do
    original_state = state
    state = Map.put(state, :match_state, Enums.state_started())
    check_state_and_publish(original_state, state)

    {:noreply, state}
  end

  @doc """
  Returns the field state
  """
  def handle_call(:get_field, _from, state) do
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

  def handle_info({:send_game_data_all, data}, state) do
    Enum.each(state.alliance_station_to_driverstation, fn {_, driverstation} ->
      if driverstation != nil do
        send(driverstation, {:send_game_data, data})
      end
    end)

    {:noreply, state}
  end

  @doc """
  Runs every second to decrease the timer
  """
  def handle_info(:timer, state) do
    original_state = state

    state =
      if state.match_state == Enums.state_started() && state.match_level != Enums.level_test() do
        if state.time_left <= 0 do
          send(self(), {:stop_field, false})
          state
        else
          state = Map.put(state, :time_left, state.time_left - 1)
          state
        end
      else
        state
      end

    check_state_and_publish(original_state, state)
    Process.send_after(self(), :timer, 1000)
    {:noreply, state}
  end

  @doc """
  Runs every 500 ms
  """
  def handle_info(:tick, state) do
    original_state = state

    state =
      if state.match_state == Enums.state_notready() do
        if all_driverstations_ready?(state) do
          state = Map.put(state, :match_state, Enums.state_ready())
          state
        else
          state
        end
      else
        if state.match_state == Enums.state_ready() do
          if !all_driverstations_ready?(state) do
            state = Map.put(state, :match_state, Enums.state_notready())
            state
          else
            state
          end
        else
          state
        end
      end

    Enum.each(state.alliance_station_to_driverstation, fn {_, driverstation} ->
      if driverstation != nil do
        send(
          driverstation,
          {:tick, state.match_state, state.time_left, state.f, state.match_num,
           state.udp_socket}
        )
      end
    end)

    check_state_and_publish(original_state, state)
    Process.send_after(self(), :tick, 500)
    {:noreply, state}
  end

  defp all_driverstations_ready?(state) do
    try do
      Enum.each(state.alliance_station_to_driverstation, fn {_, driverstation} ->
        if driverstation == nil do
          throw(:break)
        end
      end)

      true
    catch
      :break -> false
    end
  end

  defp check_state_and_publish(original_state, new_state) do
    if original_state != new_state do
      team_num_to_alliance_station = Enum.reduce(new_state.team_num_to_alliance_station, [], fn {team, station}, list ->
        if team != nil do
          list ++ [%{team: Nevermore.Repo.get(Nevermore.Team, team), station: station}]
        else
          list
        end
      end)
      new_state = Map.put(new_state, :ip, :inet.ntoa(new_state.ip))
      Absinthe.Subscription.publish(NevermoreWeb.Endpoint, Map.put(new_state, :team_num_to_alliance_station, team_num_to_alliance_station), field_state_update: "field_state_update")
    end
  end

  defp kick_all(state) do
    Enum.each(state.driver_stations, fn driverstation ->
      if driverstation != nil do
        send(driverstation, :kick)
      end
    end)
  end

  # Helper Functions
  @doc """
  Gets the state of the field, use this to get the state on load, then listen for updates.
  """
  @spec get_state() :: map()
  def get_state() do
    GenServer.call(Nevermore.Field, :get_field)
  end

  @doc """
  Sets up the field, run this to configure the match to allow the match's teams to connect.

  Parameters:
    * `field`: This is the pid to the field you want to modify.
    * `match_num`: This is the match's number.
    * `tournament_level`: The tournament level of the match.
    * `red1 thru blue3`: These are the team numbers inside of the match, put down nil if you don't want anyone in that station.

  Returns:
    Nothing
  """
  @spec setup_field(
          integer(),
          integer(),
          integer(),
          integer(),
          integer(),
          integer(),
          integer(),
          integer()
        ) :: none()
  def setup_field(match_num, tournament_level, red1, red2, red3, blue1, blue2, blue3) do
    send(
      Nevermore.Field,
      {:setup_field, match_num, tournament_level, red1, red2, red3, blue1, blue2, blue3}
    )
  end

  @doc """
  This starts the field, timer, and tick loop.

  Parameters:
      * `field`: This is the pid to the field you want to start.

  Returns:
    Nothing
  """
  @spec start_field() :: none()
  def start_field() do
    send(Nevermore.Field, :start_field)
  end

  def send_game_data_all(data) do
    send(Nevermore.Field, {:send_game_data_all, data})
  end

  @doc """
  This stops the field, timer, and tick loop.

  Parameters:
      * `field`: This is the pid to the field you want to stop.

  Returns:
    Nothing
  """
  @spec stop_field() :: none()
  def stop_field() do
    send(Nevermore.Field, {:stop_field, true})
  end

  @doc """
  This pauses the match.

  Parameters:
      * `field`: This is the pid to the field you want to pause.

  Returns:
    Nothing
  """
  @spec pause_match() :: none()
  def pause_match() do
    send(Nevermore.Field, :pause_match)
  end

  @doc """
  This unpauses the match.

  Parameters:
      * `field`: This is the pid to the field you want to unpause.

  Returns:
    Nothing
  """
  @spec unpause_match() :: none()
  def unpause_match() do
    send(Nevermore.Field, :unpause_match)
  end
end
