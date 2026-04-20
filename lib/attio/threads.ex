defmodule Attio.Threads do
  @moduledoc """
  Functions for managing comment threads on records and list entries.

  A thread groups one or more comments and is attached to a parent record or
  list entry. Creating a thread also creates its first comment. Use
  `Attio.Comments` to manage individual comments within a thread.

  Threads are immutable after creation: the API provides no update or delete
  operations on threads themselves. To add further comments to an existing
  thread, use `Attio.Comments`.

  Requires the `comment:read` scope for read operations and
  `comment:read-write` for mutations.

  ## Pagination

  `list/2` returns a single page. `stream/2` lazily pages through all threads;
  `stream_all/2` collects them into `{:ok, list}`. See `Attio` for an overview.

      client
      |> Attio.Threads.stream()
      |> Enum.to_list()

  """

  alias Attio.Client

  @doc """
  Lists threads. Returns one page.

  ## Options

    * `:limit` - Number of threads per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/threads", params: params)
  end

  @doc """
  Returns a lazy stream of all threads across all pages.

  Accepts the same options as `list/2`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/2` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ []) do
    Client.paginate(client, &list(client, &1), params)
  end

  @doc """
  Fetches all threads across all pages and returns them as a list.

  Accepts the same options as `list/2`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/2`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, threads} = Attio.Threads.stream_all(client)

  """
  @spec stream_all(Client.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, params \\ []) do
    {:ok, stream(client, params) |> Enum.to_list()}
  catch
    {:attio_stream_error, err} -> {:error, err}
  end

  @doc """
  Gets a single thread by its ID, including all comments.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, thread_id) do
    Client.request(client, :get, "/v2/threads/#{Client.encode(thread_id)}")
  end

  @doc """
  Creates a new thread with an initial comment.

  ## Required attributes

    * `"record_id"` - ID of the record to attach the thread to.
    * `"format"` - Content format: `"plaintext"` or `"markdown"`.
    * `"content"` - Initial comment content.

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/threads", json: %{"data" => attrs})
  end
end
