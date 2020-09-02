defmodule NevermoreWeb.Schema.Network do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic

  object :network_status_packet do
    field :log_message, :string
    field :status, :network_status
  end

  object :prestart_status_packet do
    field :log_message, :string
    field :status, :prestart_status
  end

  enum :network_status do
    value(:success, as: 0)
    value(:unknown_error, as: 1)
    value(:cant_ping, as: 11)
    value(:cant_login, as: 12)
  end

  enum :prestart_status do
    value(:success, as: 0)
    value(:unknown_error, as: 1)
    value(:ssh_error, as: 11)
  end

  enum :router_type do
    value(:normal, as: "normal")
    value(:factory, as: "factory")
  end

  object :network_mutations do

    field :network_ping_router, :success do
      resolve fn _, _, _ ->
        spawn fn ->
          # First check that router is not already configured.
          {logs, exit_code} = System.cmd("sh", ["fms-hardware-control/01-ROUTER-SCAN.sh", "normal"], env: [{"ROUTER_PASSWORD", Application.get_env(:nevermore, :router_password)}]) # Password is same as Phoenix secret.
          Absinthe.Subscription.publish(
            NevermoreWeb.Endpoint,
            %{log_message: logs, status: exit_code},
            network_ping_router: "network_ping_router_update"
          )
        
          if exit_code != 0 do
            # Then check if it is factory reset.
            {logs, exit_code} = System.cmd("sh", ["fms-hardware-control/01-ROUTER-SCAN.sh", "factory"], env: [{"ROUTER_PASSWORD", Application.get_env(:nevermore, :router_password)}]) # Password is same as Phoenix secret.
            Absinthe.Subscription.publish(
              NevermoreWeb.Endpoint,
              %{log_message: logs, status: exit_code},
              network_ping_router: "network_ping_router_update"
            )
          end
        end
        {:ok, %{successful: true}}
      end
    end

    field :network_init_router, :success do
      arg(:router_type, non_null(:router_type))
      resolve fn _, args, _ ->
        spawn fn ->
          # First check that router is not already configured.
          {logs, exit_code} = System.cmd("sh", ["fms-hardware-control/01A-ROUTER-INIT.sh", args.router_type], env: [{"ROUTER_PASSWORD", Application.get_env(:nevermore, :router_password)}]) # Password is same as Phoenix secret.
          Process.sleep(1000)
          Absinthe.Subscription.publish(
            NevermoreWeb.Endpoint,
            %{log_message: logs, status: exit_code},
            network_init_router: "network_init_router_update"
          )
        end
        {:ok, %{successful: true}}
      end
    end

    field :network_init_router, :success do
      arg(:router_type, non_null(:router_type))
      resolve fn _, args, _ ->
        spawn fn ->
          # First check that router is not already configured.
          {logs, exit_code} = System.cmd("sh", ["fms-hardware-control/01A-ROUTER-INIT.sh", args.router_type], env: [{"ROUTER_PASSWORD", Application.get_env(:nevermore, :router_password)}]) # Password is same as Phoenix secret.
          Process.sleep(1000)
          Absinthe.Subscription.publish(
            NevermoreWeb.Endpoint,
            %{log_message: logs, status: exit_code},
            network_init_router: "network_init_router_update"
          )
        end
        {:ok, %{successful: true}}
      end
    end

  end

  object :network_subscriptions do

    field :network_ping_router, :network_status_packet do
      config(fn _, _ ->
        {:ok, topic: "network_ping_router_update"}
      end)

      resolve(fn state, _, _ ->
        {:ok, state}
      end)
    end

    field :network_init_router, :network_status_packet do
      config(fn _, _ ->
        {:ok, topic: "network_init_router_update"}
      end)

      resolve(fn state, _, _ ->
        {:ok, state}
      end)
    end

    field :network_prestart_router, :prestart_status_packet do
      config(fn _, _ ->
        {:ok, topic: "network_prestart_router_update"}
      end)

      resolve(fn state, _, _ ->
        {:ok, state}
      end)
    end

    field :network_prestart_wifi, :prestart_status_packet do
      config(fn _, _ ->
        {:ok, topic: "network_prestart_wifi_update"}
      end)

      resolve(fn state, _, _ ->
        {:ok, state}
      end)
    end
  end

end
