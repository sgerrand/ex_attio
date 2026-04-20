defmodule Attio.Meetings do
  @moduledoc """
  Functions for managing meetings linked to records.

  Meetings represent calendar events — either synced from connected calendars
  or created manually. Requires the `meeting:read` scope for read operations
  and `meeting:read-write` for mutations.
  """

  alias Attio.Client

  @doc """
  Lists meetings. Returns one page.

  ## Options

    * `:limit` - Number of meetings per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/meetings", params: params)
  end

  @doc """
  Gets a single meeting by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, meeting_id) do
    Client.request(client, :get, "/v2/meetings/#{Client.encode(meeting_id)}")
  end

  @doc """
  Creates a meeting.

  ## Required attributes

    * `"title"` - Meeting title.
    * `"start_time"` - ISO 8601 start timestamp.
    * `"end_time"` - ISO 8601 end timestamp.

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/meetings", json: %{"data" => attrs})
  end

  @doc """
  Updates a meeting.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, meeting_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/meetings/#{Client.encode(meeting_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes a meeting.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, meeting_id) do
    Client.request(client, :delete, "/v2/meetings/#{Client.encode(meeting_id)}")
  end
end
