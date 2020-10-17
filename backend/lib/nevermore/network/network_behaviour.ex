defmodule Nevermore.Network.NetworkBehaviour do
  @callback router_prestart!(String.t, {integer(), integer(), integer(), integer(), integer(), integer()}) :: :ok
  @callback configure_wifi!(String.t, String.t, [
    {integer(), String.t, String.t, integer()}
  ]) :: :ok
end
