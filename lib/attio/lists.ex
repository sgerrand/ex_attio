defmodule Attio.Lists do
  @moduledoc """
  Functions for managing Attio lists.

  Lists are process models that contain entries — records of a single object type
  enriched with list-specific attributes (e.g. pipeline stage, owner).

  Requires the `list_configuration:read` scope for read operations and
  `list_configuration:read-write` for mutations.
  """

  alias Attio.Client

  defp encode(id), do: URI.encode(id, &URI.char_unreserved?/1)

  @doc """
  Lists all lists in the workspace.
  """
  @spec list(Client.t()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client) do
    Client.request(client, :get, "/v2/lists")
  end

  @doc """
  Gets a single list by its ID or slug.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, list_id) do
    Client.request(client, :get, "/v2/lists/#{encode(list_id)}")
  end

  @doc """
  Creates a new list.

  ## Required attributes

    * `"title"` - Display name for the list.
    * `"object_slug"` - The slug of the object type this list tracks (e.g. `"people"`).

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/lists", json: %{"data" => attrs})
  end

  @doc """
  Updates a list's configuration.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, list_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/lists/#{encode(list_id)}", json: %{"data" => attrs})
  end

  @doc """
  Lists saved views for a list.
  """
  @spec list_views(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def list_views(%Client{} = client, list_id) do
    Client.request(client, :get, "/v2/lists/#{encode(list_id)}/views")
  end
end
