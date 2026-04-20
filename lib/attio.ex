defmodule Attio do
  @moduledoc """
  Elixir client for the [Attio REST API](https://developers.attio.com).

  ## Getting started

  Build a client with `Attio.Client.new/1` and pass it to the resource module
  that matches what you want to do:

      client = Attio.Client.new(api_key: System.fetch_env!("ATTIO_API_KEY"))

      # Fetch a page of people records
      {:ok, response} = Attio.Records.list(client, "people")

      # Lazily stream all companies across pages
      client
      |> Attio.Records.stream("companies")
      |> Stream.map(& &1["values"]["name"])
      |> Enum.to_list()

  ## Resources

  | Module | Attio resource | Required scope |
  |---|---|---|
  | `Attio.Objects` | Object schemas | `object_configuration:read` |
  | `Attio.Attributes` | Attributes on objects/lists | `object_configuration:read` |
  | `Attio.Records` | Records within objects | `record_permission:read` |
  | `Attio.Lists` | Process lists | `list_configuration:read` |
  | `Attio.Entries` | Entries within lists | `list_entry:read` |
  | `Attio.Notes` | Notes on records | `note:read` |
  | `Attio.Tasks` | Tasks with linked records | `task:read` |
  | `Attio.Meetings` | Calendar meetings | `meeting:read` |
  | `Attio.Webhooks` | Event subscriptions | `webhook:read` |
  | `Attio.WorkspaceMembers` | Workspace users | `user_management:read` |
  | `Attio.Threads` | Comment threads | `comment:read` |
  | `Attio.Comments` | Individual comments | `comment:read` |
  | `Attio.Meta` | API token metadata | _(any)_ |

  ## Error handling

  All resource functions return `{:ok, response}` or `{:error, reason}`:

    * `{:ok, map()}` – decoded JSON body of the successful response.
    * `{:error, %Attio.Error{}}` – an API-level error (4xx/5xx) with
      `:status`, `:type`, `:code`, and `:message` fields.
    * `{:error, exception}` – a transport-level error from the HTTP client.

  ## Pagination

  Resources that return lists support cursor-based pagination. All paginated
  modules expose a `stream` function that lazily consumes all pages without
  loading everything into memory at once:

  | Module | Lazy stream | Eager list |
  |---|---|---|
  | `Attio.Records` | `stream/3` | `stream_all/3` |
  | `Attio.Entries` | `stream/3` | `stream_all/3` |
  | `Attio.Notes` | `stream/2` | `stream_all/2` |
  | `Attio.Tasks` | `stream/2` | `stream_all/2` |
  | `Attio.Meetings` | `stream/2` | `stream_all/2` |
  | `Attio.Threads` | `stream/2` | `stream_all/2` |

  Use `stream` when composing with `Stream` functions or when you only need
  part of the result set. Use `stream_all` when you want all pages as a plain
  `{:ok, list}`:

      {:ok, records} = Attio.Records.stream_all(client, "people")

      Attio.Records.stream(client, "people", limit: 100)
      |> Stream.take(50)
      |> Enum.to_list()

  ## Attribute values

  Attribute values in create/update requests and API responses are plain maps
  keyed by attribute slug. The structure of each value depends on the
  attribute type. Responses include an `"attribute_type"` discriminator field
  on each value.

  See the [Attio attribute type reference](https://developers.attio.com/reference/attribute-types)
  for the full list of value shapes.
  """
end
