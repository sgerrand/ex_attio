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

  @doc """
  Lists entries in a list. Returns one page.

  ## Options

    * `:limit` - Number of entries per page (1–1000, default 500).
    * `:cursor` - Opaque pagination cursor from a previous response.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, list_id, params \\ []) do
    Client.request(client, :get, "/v2/lists/#{list_id}/entries", params: params)
  end

  @doc """
  Returns a lazy stream of all entries in a list across all pages.
  """
  @spec stream(Client.t(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, list_id, params \\ []) do
    Stream.resource(
      fn -> {params, nil, false} end,
      fn
        {_params, _cursor, :done} ->
          {:halt, nil}

        {params, cursor, false} ->
          req_params = if cursor, do: Keyword.put(params, :cursor, cursor), else: params

          case list(client, list_id, req_params) do
            {:ok, %{"data" => data, "pagination" => %{"next_cursor" => nil}}} ->
              {data, {params, nil, :done}}

            {:ok, %{"data" => data, "pagination" => %{"next_cursor" => next}}} ->
              {data, {params, next, false}}

            {:error, err} ->
              throw({:attio_stream_error, err})
          end
      end,
      fn _ -> :ok end
    )
  end

  @doc """
  Gets a single entry by its ID.
  """
  @spec get(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, list_id, entry_id) do
    Client.request(client, :get, "/v2/lists/#{list_id}/entries/#{entry_id}")
  end

  @doc """
  Creates an entry in a list.

  ## Required attributes

    * `"record_id"` - ID of the record to add.

  """
  @spec create(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, list_id, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/lists/#{list_id}/entries", json: %{"data" => attrs})
  end

  @doc """
  Updates an entry's attribute values.
  """
  @spec update(Client.t(), String.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, list_id, entry_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/lists/#{list_id}/entries/#{entry_id}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes an entry from a list.
  """
  @spec delete(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, list_id, entry_id) do
    Client.request(client, :delete, "/v2/lists/#{list_id}/entries/#{entry_id}")
  end
end
