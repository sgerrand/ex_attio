defmodule Attio.Notes do
  @moduledoc """
  Functions for managing notes linked to records.

  Notes are rich-text documents attached to parent records. Requires the
  `note:read` scope for read operations and `note:read-write` for mutations.

  ## Pagination

  `list/2` returns a single page. `stream/2` lazily pages through all notes
  without buffering them in memory:

      client
      |> Attio.Notes.stream(limit: 100)
      |> Stream.filter(fn n -> n["title"] =~ "recap" end)
      |> Enum.to_list()

  If you want a plain `{:ok, list}` result rather than a lazy stream, use
  `stream_all/2`:

      {:ok, notes} = Attio.Notes.stream_all(client)

  """

  alias Attio.Client

  @doc """
  Lists notes. Returns one page.

  ## Options

    * `:limit` - Number of notes per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/notes", params: params)
  end

  @doc """
  Returns a lazy stream of all notes across all pages.

  Accepts the same options as `list/2`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/2` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ []) do
    Client.paginate(client, &list(client, &1), params)
  end

  @doc """
  Fetches all notes across all pages and returns them as a list.

  Accepts the same options as `list/2`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/2`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, notes} = Attio.Notes.stream_all(client)

  """
  @spec stream_all(Client.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, params \\ []) do
    {:ok, stream(client, params) |> Enum.to_list()}
  catch
    {:attio_stream_error, err} -> {:error, err}
  end

  @doc """
  Gets a single note by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, note_id) do
    Client.request(client, :get, "/v2/notes/#{Client.encode(note_id)}")
  end

  @doc """
  Creates a note linked to a record.

  ## Required attributes

    * `"parent_object"` - The object slug of the parent record (e.g. `"people"`).
    * `"parent_record_id"` - The record ID to attach this note to.
    * `"title"` - Note title.
    * `"content"` - Note body as a document object.

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/notes", json: %{"data" => attrs})
  end

  @doc """
  Updates a note.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, note_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/notes/#{Client.encode(note_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes a note.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, note_id) do
    Client.request(client, :delete, "/v2/notes/#{Client.encode(note_id)}")
  end
end
