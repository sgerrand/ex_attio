defmodule Attio.WorkspaceMembers do
  @moduledoc """
  Functions for listing workspace members.

  Workspace members are users with access to the workspace. This resource is
  read-only through the API. Requires the `user_management:read` scope.
  """

  alias Attio.Client

  @doc """
  Lists all workspace members.
  """
  @spec list(Client.t()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client) do
    Client.request(client, :get, "/v2/workspace-members")
  end

  @doc """
  Gets a single workspace member by their ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, member_id) do
    Client.request(client, :get, "/v2/workspace-members/#{member_id}")
  end
end
