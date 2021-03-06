defmodule NevermoreWeb.GraphQL.Field do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic

  node object(:field_state) do
    field :ip, :string
    field :udp_port, :integer
    field :tcp_port, :integer
    field :tcp_error, :string
    field :udp_error, :string
    field :match_num, :string
    field :match_state, :match_state
    field :time_left, :integer
    field :event_name, :string
    field :match_level, :match_level
    field :team_num_to_alliance_station, list_of(:team_num_to_alliance_station)
    field :team_num_to_state, list_of(:team_state)
    field :match_started_at, :integer
    # field :driver_stations, list TODO
  end

  object :team_num_to_alliance_station do
    field :team, :team
    field :station, :station
  end

  object :team_state do
    field :team, :team
    field :enabled, :boolean
    field :e_stopped, :boolean
  end

  enum :station do
    value(:red1, as: 0)
    value(:red2, as: 1)
    value(:red3, as: 2)
    value(:blue1, as: 3)
    value(:blue2, as: 4)
    value(:blue3, as: 5)
  end

  enum :match_state do
    value(:notready, as: 0)
    value(:ready, as: 1)
    value(:started, as: 2)
    value(:paused, as: 3)
    value(:inreview, as: 4)
    value(:done, as: 5)
  end

  enum :match_level do
    value(:test, as: 0)
    value(:practice, as: 1)
    value(:qualification, as: 2)
    value(:playoff, as: 3)
  end

  object :field_queries do
    field :field_state, :field_state do
      resolve(fn _, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.unpause_field()
          state = Nevermore.Field.get_state()

          team_num_to_alliance_station =
            Enum.reduce(state.team_num_to_alliance_station, [], fn {team, station}, list ->
              if team != nil do
                team_info = Nevermore.Repo.get(Nevermore.Team, team)
                team_info = if (team_info != nil), do: team_info, else: %{}
                list ++ [%{team: Map.merge(%{team_number: team}, team_info), station: station}]
              else
                list
              end
            end)

            team_num_to_state =
              Enum.reduce(state.team_num_to_state, [], fn {team, state}, list ->
                if team != nil do
                  team_info = Nevermore.Repo.get(Nevermore.Team, team)
                  team_info = if (team_info != nil), do: team_info, else: %{}
                  list ++ [%{team: Map.merge(%{team_number: team}, team_info), e_stopped: state.e_stopped, enabled: state.enabled}]
                else
                  list
                end
              end)

          state = Map.put(state, :ip, :inet.ntoa(state.ip))
          state = Map.put(state, :team_num_to_state, team_num_to_state)
          {:ok, Map.put(state, :team_num_to_alliance_station, team_num_to_alliance_station)}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end
  end

  object :field_mutations do
    field :start_field, :success do
      resolve(fn _, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.start_field()
          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :stop_field, :success do
      resolve(fn _, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.stop_field()
          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :pause_field, :success do
      resolve(fn _, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.pause_field()
          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :unpause_field, :success do
      resolve(fn _, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.unpause_field()
          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :setup_field, :success do
      arg(:match_num, non_null(:integer))
      arg(:tournament_level, non_null(:match_level))
      arg(:red1, :integer)
      arg(:red2, :integer)
      arg(:red3, :integer)
      arg(:blue1, :integer)
      arg(:blue2, :integer)
      arg(:blue3, :integer)

      resolve(fn args, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.setup_field(
            args.match_num,
            args.tournament_level,
            value_or_nil(args, :red1),
            value_or_nil(args, :red2),
            value_or_nil(args, :red3),
            value_or_nil(args, :blue1),
            value_or_nil(args, :blue2),
            value_or_nil(args, :blue3)
          )

          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end

    field :send_game_data, :success do
      arg(:station_side, non_null(:side))
      arg(:data, non_null(:string))

      resolve(fn args, res ->
        if Map.has_key?(res.context, :user) do
          Nevermore.Field.send_game_data_to_side(args.side, args.data)

          {:ok, %{successful: true}}
        else
          {:error, "Not Authenticated"}
        end
      end)
    end
  end

  object :field_subscriptions do
    field :field_state_update, :field_state do
      config(fn _, _ ->
        {:ok, topic: "field_state_update"}
      end)

      resolve(fn field_state, _, _ ->
        {:ok, field_state}
      end)
    end
  end

  defp value_or_nil(map, key) do
    if Map.has_key?(map, key) do
      map[key]
    else
      nil
    end
  end
end
