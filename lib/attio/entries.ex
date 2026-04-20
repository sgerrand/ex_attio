defmodule Attio.Entries do
  @moduledoc """
  Functions for managing entries within Attio lists.

  Entries are elements within a list. Each entry references a parent record and
  can carry list-specific attribute values (e.g. pipeline stage, deal owner).

  Requires the `list_entry:read` scope for read operations and
  `list_entry:read-write` for mutations.

  ## Pagination

  `list/3` returns a single page. `stream/3` lazily pages through all entries
  without buffering them in memory:

      client
      |> Attio.Entries.stream("pipeline")
      |> Stream.filter(fn e -> e["values"]["stage"] == "qualified" end)
      |> Enum.to_list()

  If you want a plain `{:ok, list}` result rather than a lazy stream, use
  `stream_all/3`:

      {:ok, entries} = Attio.Entries.stream_all(client, "pipeline")

  """

  alias Attio.Client

  @doc """
  Lists entries in a list. Returns one page.

  ## Options

    * `:limit` - Number of entries per page (1–1000, default 500).
    * `:cursor` - Opaque pagination cursor from a previous response.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, list_id, params \\ []) do
    Client.request(client, :get, "/v2/lists/#{Client.encode(list_id)}/entries", params: params)
  end

  @doc """
  Returns a lazy stream of all entries in a list across all pages.

  Accepts the same options as `list/3`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/3` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, list_id, params \\ []) do
    Client.paginate(client, &list(client, list_id, &1), params)
  end

  @doc """
  Fetches all entries in a list across all pages and returns them as a list.

  Accepts the same options as `list/3`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/3`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, entries} = Attio.Entries.stream_all(client, "pipeline")

  """
  @spec stream_all(Client.t(), String.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, list_id, params \\ []) do
    {:ok, stream(client, list_id, params) |> Enum.to_list()}
  catch
    {:attio_stream_error, err} -> {:error, err}
  end

  @doc """
  Gets a single entry by its ID.
  """
  @spec get(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, list_id, entry_id) do
    Client.request(
      client,
      :get,
      "/v2/lists/#{Client.encode(list_id)}/entries/#{Client.encode(entry_id)}"
    )
  end

  @doc """
  Creates an entry in a list.

  ## Required attributes

    * `"record_id"` - ID of the record to add.

  """
  @spec create(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, list_id, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/lists/#{Client.encode(list_id)}/entries",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Updates an entry's attribute values.
  """
  @spec update(Client.t(), String.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, list_id, entry_id, attrs) when is_map(attrs) do
    Client.request(
      client,
      :patch,
      "/v2/lists/#{Client.encode(list_id)}/entries/#{Client.encode(entry_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes an entry from a list.
  """
  @spec delete(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, list_id, entry_id) do
    Client.request(
      client,
      :delete,
      "/v2/lists/#{Client.encode(list_id)}/entries/#{Client.encode(entry_id)}"
    )
  end
end
