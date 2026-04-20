defmodule Attio.Tasks do
  @moduledoc """
  Functions for managing tasks with linked records.

  Tasks are actionable items that can reference records and be assigned to
  workspace members. Requires the `task:read` scope for read operations and
  `task:read-write` for mutations.
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
