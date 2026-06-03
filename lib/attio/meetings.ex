defmodule Attio.Meetings do
  @moduledoc """
  Functions for managing meetings linked to records.

  Meetings represent calendar events — either synced from connected calendars
  or created manually. Requires the `meeting:read` scope for read operations
  and `meeting:read-write` for mutations.

  ## Pagination

  `list/2` returns a single page. `stream/2` lazily pages through all meetings;
  `stream_all/2` collects them into `{:ok, list}`. See `Attio` for an overview.

      client
      |> Attio.Meetings.stream()
      |> Stream.filter(fn m -> m["title"] =~ "intro" end)
      |> Enum.to_list()

  """

  use Attio.Paginated, resource: "meetings"

  alias Attio.Client

  @doc """
  Lists meetings. Returns one page.

  ## Options

    * `:limit` - Number of meetings per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: Client.response()
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/meetings", params: params)
  end

  @doc """
  Gets a single meeting by its ID.
  """
  @spec get(Client.t(), String.t()) :: Client.response()
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
  @spec create(Client.t(), map()) :: Client.response()
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/meetings", json: %{"data" => attrs})
  end

  @doc """
  Updates a meeting.
  """
  @spec update(Client.t(), String.t(), map()) :: Client.response()
  def update(%Client{} = client, meeting_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/meetings/#{Client.encode(meeting_id)}",
      json: %{"data" => attrs}
    )
  end

  @doc """
  Deletes a meeting.
  """
  @spec delete(Client.t(), String.t()) :: Client.response()
  def delete(%Client{} = client, meeting_id) do
    Client.request(client, :delete, "/v2/meetings/#{Client.encode(meeting_id)}")
  end
end
