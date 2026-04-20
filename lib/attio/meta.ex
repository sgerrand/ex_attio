defmodule Attio.Meta do
  @moduledoc """
  Functions for retrieving API token metadata.

  Useful for verifying a token's identity, the workspace it belongs to, and
  the scopes it has been granted.
  """

  alias Attio.Client

  @doc """
  Returns information about the current API token, including its scopes and
  the workspace it belongs to.
  """
  @spec get_token(Client.t()) :: {:ok, map()} | {:error, term()}
  def get_token(%Client{} = client) do
    Client.request(client, :get, "/v2/meta/token")
  end
end
