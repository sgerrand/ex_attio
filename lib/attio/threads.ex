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
