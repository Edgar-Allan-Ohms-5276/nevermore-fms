defmodule NevermoreWeb.GraphQL.Driverstation do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic

  node object(:driverstation) do
    field :team_num, :integer
    field :status, :driverstation_status
    field :station, :station
    field :e_stopped, :boolean
    field :request_e_stopped, :boolean
    field :comms, :boolean
    field :radio_ping, :boolean
    field :rio_ping, :boolean
    field :enabled, :boolean
    field :battery_voltage, :float
    field :udp_sequence_num, :integer
    field :last_udp_message_time, :integer
  end

  enum :driverstation_status do
    value(:good, as: 0)
    value(:bad, as: 1)
    value(:waiting, as: 2)
  end

  object :driverstation_queries do
    field :driverstation, :driverstation do
      arg(:team_number, :integer)

      resolve(fn %{team_number: team_number}, res ->
        if Map.has_key?(res.context, :user) do
          driverstation = get_driverstation_by_team(team_number)

          if driverstation != nil do
            {:ok, Nevermore.Driverstation.get_state(driverstation)}
          else
            {:error, "That team is not connected to the field or is not in this match."}
          end
        else
          {:error, "Not Authenticated"}
        end
      end)
    end
  end

  object :driverstation_mutations do
    field :set_enabled, :success do
      arg(:team_number, non_null(:integer))
      arg(:enabled, non_null(:boolean))

      resolve(fn %{team_number: team_number, enabled: enabled}, res ->
        if Map.has_key?(res.context, :user) do
          driverstation = get_driverstation_by_team(team_number)

          if driverstation != nil do
            Nevermore.Driverstation.set_enabled(driverstation, enabled)
            {:ok, %{successful: true}}
          else
            {:error, "That team is not connected to the field or is not in this match."}
          end
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :set_emergency_stop, :success do
      arg(:team_number, non_null(:integer))
      arg(:emergency_stop, non_null(:boolean))

      resolve(fn %{team_number: team_number, emergency_stop: emergency_stop}, res ->
        if Map.has_key?(res.context, :user) do
          driverstation = get_driverstation_by_team(team_number)

          if driverstation != nil do
            Nevermore.Driverstation.set_e_stopped(driverstation, emergency_stop)
            {:ok, %{successful: true}}
          else
            {:error, "That team is not connected to the field or is not in this match."}
          end
        else
          {:error, "Not Authenticated"}
        end
      end)
    end
  end

  object :driverstation_subscriptions do
    field :driverstation_update, :driverstation do
      arg(:team_number, non_null(:integer))

      config(fn args, _ ->
        {:ok, topic: "driverstation_update_#{args.team_number}"}
      end)

      resolve(fn driverstation, _, res ->
        if Map.has_key?(res.context, :user) do
          {:ok, driverstation}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end
  end

  defp get_driverstation_by_team(team_num) do
    field = Nevermore.Field.get_state()

    if Map.has_key?(field.team_num_to_alliance_station, team_num) do
      if Map.has_key?(
           field.alliance_station_to_driverstation,
           field.team_num_to_alliance_station[team_num]
         ) do
        field.alliance_station_to_driverstation[field.team_num_to_alliance_station[team_num]]
      else
        nil
      end
    else
      nil
    end
  end
end
