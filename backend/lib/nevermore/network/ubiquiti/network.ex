defmodule Nevermore.Network.Ubiquiti.Network do
  @behaviour Nevermore.Network.NetworkBehaviour

  @header ["Content-Type": "application/json"]

  alias CookieJar.HTTPoison, as: HTTPoison

  def router_prestart!(router_password, teams) do
    {:ok, conn} = SSHEx.connect ip: '10.0.100.254', user: 'nevermore', password: router_password
    teams
    |> Enum.with_index
    |> Enum.each(fn({team, index}) ->
      case SSHEx.run conn, get_router_command(index, team) do
        {:ok, _, 0} -> :ok
        {:ok, res, _} -> :ok
        {:error, res} -> raise res
        _ -> raise "Unknown Error"
      end
    end)
  end

  def configure_wifi!(controller_username, controller_password, stations) do
    {:ok, jar} = CookieJar.new()
    controller_login(jar, controller_username, controller_password)

    {:ok, response} = HTTPoison.get(jar, "https://fms.nevermore:8443/api/s/default/rest/wlangroup", hackney: [:insecure])
    json_response = Jason.decode!(response.body)

    field_wlang_id = get_wlang_id_by_name(json_response.data, "Field")

    if field_wlang_id != nil do
      {:ok, response} = HTTPoison.get(jar, "https://fms.nevermore:8443/api/s/default/rest/wlanconf", hackney: [:insecure])
      json_response = Jason.decode!(response.body)

      wlans = get_wlans_in_group(json_response.data, field_wlang_id)
      for wlan <- wlans do
        _ = HTTPoison.delete(jar, "https://fms.nevermore:8443/api/s/default/rest/wlanconf/#{wlan["_id"]}", hackney: [:insecure])
      end

      for {_, ssid, wpa, vlan} <- stations do
        create_ssid(jar, field_wlang_id, ssid, wpa, vlan)
      end
    else
      throw :no_field_wlang
    end
  end

  defp get_router_command(station, team_num) do
    ip_middle = to_string(div(team_num, 100)) <> "." <> to_string(rem(team_num, 100))
    vlan = station * 10
    station_name = if station <= 3 do
      "RED#{station}"
    else
      "BLUE#{station - 3}"
    end

    EEx.eval_string(
"
<%= cw %> begin
<%= cw %> delete interfaces ethernet eth0 vif <%= vlan %>
<%= cw %> set interfaces ethernet eth0 vif <%= vlan %> description <%= station_name %>
<%= cw %> set interfaces ethernet eth0 vif <%= vlan %> address 10.<%= ip_middle %>.254/24
<%= cw %> set interfaces ethernet eth0 vif <%= vlan %> firewall in name TEAM_TO_FMS
<%= cw %> set interfaces ethernet eth0 vif <%= vlan %> firewall out name FMS_TO_TEAM
<%= cw %> set interfaces ethernet eth0 vif <%= vlan %> firewall local name TEAM_ROUTER
<%= cw %> delete service dhcp-server shared-network-name <%= station_name %>
<%= cw %> set service dhcp-server shared-network-name <%= station_name %> subnet 10.<%= ip_middle %>.0/24 start 10.<%= ip_middle %>.50 stop 10.<%= ip_middle %>.150
<%= cw %> set service dhcp-server shared-network-name <%= station_name %> subnet 10.<%= ip_middle %>.0/24 default-router 10.<%= ip_middle %>.254
<%= cw %> set service dhcp-server shared-network-name <%= station_name %> authoritative enable
<%= cw %> commit
<%= cw %> end
", cw: "/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper", ip_middle: ip_middle, vlan: vlan, station_name: station_name)
  end

  defp controller_login(jar, username, password) do
    {:ok, response} =
      HTTPoison.post(jar, "https://fms.nevermore:8443/api/login", Jason.encode!(%{"username" => username, "password" => password}), @header, hackney: [:insecure])

    response_json = Jason.decode!(response.body)

    if response_json.meta.rc == "ok" do
      :ok
    else
      {:error, "Invalid login"}
    end
  end

  defp get_wlans_in_group(wlans, group_id) do
    get_wlans_in_group_iter(wlans, 0, group_id, [])
  end

  defp get_wlans_in_group_iter(wlans, current_index, group_id, current_wlans) do
    if length(wlans) >= current_index do
      current_wlans
    else
      current_wlan = Enum.at(wlans, current_index)
      if current_wlan.wlangroup_id == group_id do
        get_wlans_in_group_iter(wlans, current_index + 1, group_id, current_wlans ++ [current_wlan])
      else
        get_wlans_in_group_iter(wlans, current_index + 1, group_id, current_wlans)
      end
    end
  end

  defp get_wlang_id_by_name(wlangs, name) do
    get_wlang_id_by_name_iter(wlangs, 0, name)
  end

  defp get_wlang_id_by_name_iter(wlangs, current_index, name) do
    if length(wlangs) >= current_index do
      nil
    else
      current_wlang = Enum.at(wlangs, current_index)
      if current_wlang.name == name do
        current_wlang["_id"]
      else
        get_wlang_id_by_name_iter(wlangs, current_index + 1, name)
      end
    end
  end

  defp create_ssid(jar, field_id, ssid, wpa, vlan) do
    body = """
    {
      "bc_filter_enabled":false,
      "dtim_mode":"default",
      "group_rekey":3600,
      "mac_filter_enabled":false,
      "minrate_ng_enabled":false,
      "minrate_ng_data_rate_kbps":1000,
      "minrate_ng_advertising_rates":false,
      "minrate_ng_cck_rates_enabled":true,
      "minrate_ng_beacon_rate_kbps":1000,
      "minrate_ng_mgmt_rate_kbps":1000,
      "minrate_na_enabled":false,
      "minrate_na_data_rate_kbps":6000,
      "minrate_na_advertising_rates":false,
      "minrate_na_beacon_rate_kbps":6000,
      "minrate_na_mgmt_rate_kbps":6000,
      "security":"wpapsk",
      "wpa_mode":"wpa2",
      "name":"#{ssid}",
      "enabled":true,
      "mcastenhance_enabled":false,
      "fast_roaming_enabled":false,
      "vlan_enabled":true,
      "vlan":#{vlan},
      "hide_ssid":true,
      "x_passphrase":#{wpa},
      "is_guest":false,
      "uapsd_enabled":false,
      "name_combine_enabled":true,
      "name_combine_suffix":"",
      "no2ghz_oui":false,
      "radius_mac_auth_enabled":false,
      "radius_macacl_format":"none_lower",
      "radius_macacl_empty_password":false,
      "wlangroup_id":#{field_id},
      "radius_das_enabled":false,
      "wpa_enc":"ccmp"
   }
   """

   _ = HTTPoison.post(jar, "https://fms.nevermore:8443/api/s/default/rest/wlangroup", body, @header, hackney: [:insecure])
  end
end
