defmodule NevermoreWeb.Utils.TBAImport do
  @moduledoc false

  def get_all_teams() do
    api_key = Application.get_env(:nevermore, :tba_key)

    headers = ["X-TBA-Auth-Key": api_key, Accept: "Application/json; Charset=utf-8"]

    get_page_teams(0, headers, [])
  end

  defp get_page_teams(page_num, headers, teams) do
    {:ok, response} =
      HTTPoison.get("https://www.thebluealliance.com/api/v3/teams/#{page_num}", headers)

    if response.status_code == 200 do
      decoded_teams = Jason.decode!(response.body)

      if length(decoded_teams) > 0 do
        get_page_teams(page_num + 1, headers, teams ++ decoded_teams)
      else
        teams
      end
    else
      IO.puts("Invalid response: #{inspect(response)}")
    end
  end
end
