defmodule Attio.Records do
  @moduledoc """
  Functions for managing records within Attio objects.

  Records are individual instances of an object — a specific person, company,
  or deal. Attribute values are passed and returned as plain maps keyed by
  attribute slug.

  ## Authentication

  Requires the `record_permission:read` scope for read operations and
  `record_permission:read-write` for mutations.

  ## Pagination

  `list/3` returns a single page. `stream/3` lazily pages through all records
  without buffering them in memory — compose it with `Stream` functions before
  calling `Enum.to_list/1` or similar to collect results:

      client
      |> Attio.Records.stream("people", limit: 100)
      |> Stream.filter(fn r -> r["values"]["email_addresses"] != [] end)
      |> Enum.to_list()

  If you want a plain `{:ok, list}` result rather than a lazy stream, use
  `stream_all/3`:

      {:ok, records} = Attio.Records.stream_all(client, "people")

  ## Attribute values

  Attribute values in create/update requests are maps keyed by attribute slug.
  The structure of each value depends on the attribute type. For example:

      %{
        "name" => [%{"first_name" => "Alice", "last_name" => "Smith"}],
        "email_addresses" => [%{"email_address" => "alice@example.com"}]
      }

  Responses include an `"attribute_type"` field in each value that identifies
  the type discriminator.
  """

  alias Attio.Client

  @doc """
  Lists records for an object. Returns one page.

  ## Options

    * `:limit` - Number of records per page (1–1000, default 500).
    * `:cursor` - Opaque pagination cursor from a previous response.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, object, params \\ []) do
    Client.request(client, :get, "/v2/objects/#{Client.encode(object)}/records", params: params)
  end

  @doc """
  Returns a lazy stream of all records across all pages.

  Accepts the same options as `list/3`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/3` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, object, params \\ []) do
    Client.paginate(client, &list(client, object, &1), params)
  end

  @doc """
  Fetches all records across all pages and returns them as a list.

  Accepts the same options as `list/3`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/3`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, records} = Attio.Records.stream_all(client, "people")

  """
  @spec stream_all(Client.t(), String.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, object, params \\ []) do
    try do
      {:ok, stream(client, object, params) |> Enum.to_list()}
    catch
      {:attio_stream_error, err} -> {:error, err}
    end
  end

  @doc """
  Gets a single record by its ID.
  """
  @spec get(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, object, record) do
    Client.request(
      client,
      :get,
      "/v2/objects/#{Client.encode(object)}/records/#{Client.encode(record)}"
    )
  end

  @doc """
  Creates a new record with the given attribute values.

  ## Example

      Attio.Records.create(client, "people", %{
        "name" => [%{"first_name" => "Alice", "last_name" => "Smith"}],
        "email_addresses" => [%{"email_address" => "alice@example.com"}]
      })

  """
  @spec create(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, object, values) when is_map(values) do
    Client.request(client, :post, "/v2/objects/#{Client.encode(object)}/records",
      json: %{"data" => %{"values" => values}}
    )
  end

  @doc """
  Updates attribute values on an existing record.

  Only the supplied attributes are changed; others are left untouched.
  """
  @spec update(Client.t(), String.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, object, record, values) when is_map(values) do
    Client.request(
      client,
      :patch,
      "/v2/objects/#{Client.encode(object)}/records/#{Client.encode(record)}",
      json: %{"data" => %{"values" => values}}
    )
  end

  @doc """
  Deletes a record.
  """
  @spec delete(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, object, record) do
    Client.request(
      client,
      :delete,
      "/v2/objects/#{Client.encode(object)}/records/#{Client.encode(record)}"
    )
  end

  @doc """
  Creates a record if no match is found, or returns the existing matching record.

  The supplied `values` are used as matching criteria. If exactly one record
  matches, it is returned. If multiple records match, a `409 Conflict` error is
  returned. If no records match, a new record is created.

  The response includes an `"action"` field: `"created"` or `"updated"`.

  ## Example

      Attio.Records.assert(client, "people", %{
        "email_addresses" => [%{"email_address" => "alice@example.com"}]
      })

  """
  @spec assert(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def assert(%Client{} = client, object, values) when is_map(values) do
    Client.request(client, :post, "/v2/objects/#{Client.encode(object)}/records/assert",
      json: %{"data" => %{"values" => values}}
    )
  end
end
