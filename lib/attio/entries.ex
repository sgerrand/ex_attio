defmodule Attio.Entries do
  @moduledoc """
  Functions for managing entries within Attio lists.

  Entries are elements within a list. Each entry references a parent record and
  can carry list-specific attribute values (e.g. pipeline stage, deal owner).

  Requires the `list_entry:read` scope for read operations and
  `list_entry:read-write` for mutations.

  ## Pagination

  `list/3` returns a single page. Use `stream/3` to lazily consume all entries:

      client
      |> Attio.Entries.stream("pipeline")
      |> Stream.filter(fn e -> e["values"]["stage"] == "qualified" end)
      |> Enum.to_list()

  """

  alias Attio.Client

  defp encode(id), do: URI.encode(id, &URI.char_unreserved?/1)

  @doc """
  Lists entries in a list. Returns one page.

  ## Options

    * `:limit` - Number of entries per page (1–1000, default 500).
    * `:cursor` - Opaque pagination cursor from a previous response.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, list_id, params \\ []) do
    Client.request(client, :get, "/v2/lists/#{encode(list_id)}/entries", params: params)
  end

  @doc """
  Returns a lazy stream of all entries in a list across all pages.

  Accepts the same options as `list/3`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream.
  """
  @spec stream(Client.t(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, list_id, params \\ []) do
    Client.paginate(client, &list(client, list_id, &1), params)
  end

  @doc """
  Gets a single entry by its ID.
  """
  @spec get(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, list_id, entry_id) do
    Client.request(client, :get, "/v2/lists/#{encode(list_id)}/entries/#{encode(entry_id)}")
  end

  @doc """
  Creates an entry in a list.

  ## Required attributes

    * `"record_id"` - ID of the record to add.

  """
  @spec create(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, list_id, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/lists/#{encode(list_id)}/entries",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Updates an entry's attribute values.
  """
  @spec update(Client.t(), String.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, list_id, entry_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/lists/#{encode(list_id)}/entries/#{encode(entry_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes an entry from a list.
  """
  @spec delete(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, list_id, entry_id) do
    Client.request(client, :delete, "/v2/lists/#{encode(list_id)}/entries/#{encode(entry_id)}")
  end
end
