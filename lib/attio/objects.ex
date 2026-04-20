defmodule Attio.Objects do
  @moduledoc """
  Functions for managing Attio objects.

  Objects are the core data models in Attio. Standard objects (people, companies,
  deals) are provided by the workspace; custom objects can be created via `create/2`.

  Requires the `object_configuration:read` scope for read operations and
  `object_configuration:read-write` for mutations.
  """

  alias Attio.Client

  @doc """
  Lists all objects in the workspace.
  """
  @spec list(Client.t()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client) do
    Client.request(client, :get, "/v2/objects")
  end

  @doc """
  Gets a single object by its ID or slug.

  ## Example

      Attio.Objects.get(client, "people")
      Attio.Objects.get(client, "97052eb9-e65e-443f-a297-f2d9a4a7f795")

  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, object) do
    Client.request(client, :get, "/v2/objects/#{object}")
  end

  @doc """
  Creates a new custom object.

  ## Required attributes

    * `"api_slug"` - URL-safe identifier (e.g. `"my_object"`)
    * `"singular_noun"` - Display name for a single record (e.g. `"Deal"`)
    * `"plural_noun"` - Display name for multiple records (e.g. `"Deals"`)

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/objects", json: %{"data" => attrs})
  end

  @doc """
  Updates an object's configuration.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, object, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/objects/#{object}", json: %{"data" => attrs})
  end

  @doc """
  Lists saved views for an object.
  """
  @spec list_views(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def list_views(%Client{} = client, object) do
    Client.request(client, :get, "/v2/objects/#{object}/views")
  end
end
