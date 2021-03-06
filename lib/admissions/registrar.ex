defmodule Admissions.Registrar do
  @moduledoc """
  The Office of Registrar is where prospective applicants are reviewed to determine their eligibility.
  """

  alias Admissions.Slack
  alias Tentacat.Client
  alias Tentacat.Repositories.Contributors

  defdelegate invite(email), to: Slack

  @doc """
  Check if the provided GitHub nickname is an Elixir School contributor.
  """

  @spec eligible?(String.t(), String.t()) :: boolean()
  def eligible?(nickname, token) do
    client = Client.new(%{access_token: token})
    Enum.any?(organizations(), &org_contributor?(client, nickname, &1))
  end

  defp contributor?(client, nickname, org, repo) do
    with contributors when is_list(contributors) <- Contributors.list(client, org, repo)
    do
      Enum.any?(contributors, &(Map.get(&1, "login") == nickname))
    else
      _ -> false
    end
  end

  defp org_contributor?(client, nickname, {org, repos}) do
    Enum.any?(repos, &contributor?(client, nickname, org, &1))
  end

  def organizations, do: Application.get_env(:admissions, :repositories)
end
