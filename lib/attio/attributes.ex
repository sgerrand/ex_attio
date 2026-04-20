defmodule Attio.Attributes do
  @moduledoc """
  Functions for managing attributes on objects and lists.

  Attributes are the typed properties that define the shape of records and list
  entries. Both system-defined (e.g. `email_addresses` on people) and user-defined
  attributes are accessible through these functions.

  ## Targets

  Attributes belong to either an object or a list, identified by the `target`
  parameter:

    * `:objects` – attributes on an object (e.g. `people`, `companies`)
    * `:lists` – attributes on a list

  ## Scopes

  Requires `object_configuration:read` or `list_configuration:read` for reads,
  and their `:read-write` counterparts for mutations.
  """

  alias Attio.Client

  @type target :: :objects | :lists

  @doc """
  Lists attributes on an object or list.

  ## Options

    * `:limit` - Maximum number of attributes to return.
    * `:offset` - Number of attributes to skip (offset-based pagination).

  ## Example

      Attio.Attributes.list(client, :objects, "people")

  """
  @spec list(Client.t(), target(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, target, identifier, params \\ []) do
    Client.request(client, :get, "/v2/#{target}/#{Client.encode(identifier)}/attributes",
      params: params
    )
  end

  @doc """
  Creates an attribute on an object or list.

  ## Required attributes

    * `"api_slug"` - URL-safe identifier for the attribute.
    * `"title"` - Human-readable name.
    * `"type"` - Attribute type. One of: `"text"`, `"number"`, `"checkbox"`,
      `"currency"`, `"date"`, `"timestamp"`, `"rating"`, `"status"`, `"select"`,
      `"record-reference"`, `"actor-reference"`, `"location"`, `"domain"`,
      `"email-address"`, `"phone-number"`.

  ## Example

      Attio.Attributes.create(client, :objects, "people", %{
        "api_slug" => "linkedin_url",
        "title" => "LinkedIn URL",
        "type" => "text"
      })

  """
  @spec create(Client.t(), target(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, target, identifier, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/#{target}/#{Client.encode(identifier)}/attributes",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Gets a single attribute by its ID or slug.

  ## Example

      Attio.Attributes.get(client, :objects, "people", "email_addresses")

  """
  @spec get(Client.t(), target(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, target, identifier, attribute_id) do
    Client.request(
      client,
      :get,
      "/v2/#{target}/#{Client.encode(identifier)}/attributes/#{Client.encode(attribute_id)}"
    )
  end

  @doc """
  Updates an attribute's configuration.

  Only the supplied fields are changed; others are left untouched.

  ## Example

      Attio.Attributes.update(client, :objects, "people", "linkedin_url", %{
        "title" => "LinkedIn Profile"
      })

  """
  @spec update(Client.t(), target(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, term()}
  def update(%Client{} = client, target, identifier, attribute_id, attrs) when is_map(attrs) do
    Client.request(
      client,
      :patch,
      "/v2/#{target}/#{Client.encode(identifier)}/attributes/#{Client.encode(attribute_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes a custom attribute.

  System-defined attributes cannot be deleted and will return a `403` error.

  ## Example

      Attio.Attributes.delete(client, :objects, "people", "linkedin_url")

  """
  @spec delete(Client.t(), target(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, target, identifier, attribute_id) do
    Client.request(
      client,
      :delete,
      "/v2/#{target}/#{Client.encode(identifier)}/attributes/#{Client.encode(attribute_id)}"
    )
  end
end
