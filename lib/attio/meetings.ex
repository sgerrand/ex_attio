defmodule Attio.Meetings do
  @moduledoc """
  Functions for managing meetings linked to records.

  Meetings represent calendar events — either synced from connected calendars
  or created manually. Requires the `meeting:read` scope for read operations
  and `meeting:read-write` for mutations.

  ## Pagination

  `list/2` returns a single page. `stream/2` lazily pages through all meetings
  without buffering them in memory:

      client
      |> Attio.Meetings.stream()
      |> Stream.filter(fn m -> m["title"] =~ "intro" end)
      |> Enum.to_list()

  If you want a plain `{:ok, list}` result rather than a lazy stream, use
  `stream_all/2`:

      {:ok, meetings} = Attio.Meetings.stream_all(client)

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
  Returns a lazy stream of all meetings across all pages.

  Accepts the same options as `list/2`. Raises `{:attio_stream_error, error}`
  on API failure mid-stream. Use `stream_all/2` if you prefer a standard
  `{:ok, list} | {:error, term()}` return value.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ []) do
    Client.paginate(client, &list(client, &1), params)
  end

  @doc """
  Fetches all meetings across all pages and returns them as a list.

  Accepts the same options as `list/2`. Returns `{:ok, [map()]}` on success
  or `{:error, term()}` if any page request fails. Unlike `stream/2`, the
  entire result set is loaded into memory.

  ## Example

      {:ok, meetings} = Attio.Meetings.stream_all(client)

  """
  @spec stream_all(Client.t(), keyword()) ::
          {:ok, [map()]} | {:error, Attio.Error.t() | Exception.t()}
  def stream_all(%Client{} = client, params \\ []) do
    {:ok, stream(client, params) |> Enum.to_list()}
  catch
    {:attio_stream_error, err} -> {:error, err}
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
