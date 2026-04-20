defmodule Attio.Tasks do
  @moduledoc """
  Functions for managing tasks with linked records.

  Tasks are actionable items that can reference records and be assigned to
  workspace members. Requires the `task:read` scope for read operations and
  `task:read-write` for mutations.

  ## Pagination

  `list/2` returns a single page. `stream/2` lazily pages through all tasks
  without buffering them in memory:

      client
      |> Attio.Tasks.stream()
      |> Stream.reject(fn t -> t["is_completed"] end)
      |> Enum.to_list()

  If you want a plain `{:ok, list}` result rather than a lazy stream, use
  `stream_all/2`:

      {:ok, tasks} = Attio.Tasks.stream_all(client)

  """

  alias Attio.Client

  @doc """
  Lists tasks. Returns one page.

  ## Options

    * `:limit` - Number of tasks per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/tasks", params: params)
  end

  @doc """
  Returns a lazy stream of all tasks across all pages.

  Accepts the same options as `list/2`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/2` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ []) do
    Client.paginate(client, &list(client, &1), params)
  end

  @doc """
  Fetches all tasks across all pages and returns them as a list.

  Accepts the same options as `list/2`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/2`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, tasks} = Attio.Tasks.stream_all(client)

  """
  @spec stream_all(Client.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, params \\ []) do
    {:ok, stream(client, params) |> Enum.to_list()}
  catch
    {:attio_stream_error, err} -> {:error, err}
  end

  @doc """
  Gets a single task by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, task_id) do
    Client.request(client, :get, "/v2/tasks/#{Client.encode(task_id)}")
  end

  @doc """
  Creates a task.

  ## Required attributes

    * `"content"` - Task description text.
    * `"deadline_at"` - ISO 8601 deadline timestamp, or `nil`.

  ## Optional attributes

    * `"linked_records"` - List of `%{"target_object" => slug, "target_record_id" => id}` maps.
    * `"assignees"` - List of `%{"referenced_actor_type" => "workspace-member", "referenced_actor_id" => id}` maps.

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/tasks", json: %{"data" => attrs})
  end

  @doc """
  Updates a task.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, task_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/tasks/#{Client.encode(task_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes a task.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, task_id) do
    Client.request(client, :delete, "/v2/tasks/#{Client.encode(task_id)}")
  end
end
