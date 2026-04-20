# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`ex_attio` is an Elixir client library for the [Attio REST API](https://developers.attio.com).
Published to Hex as the `:attio` package. Targets Elixir ~> 1.17, no runtime dependencies
beyond `req` (HTTP client built on Finch).

## Common Commands

```bash
mix test                        # Run all tests
mix test test/attio/records_test.exs  # Run a single test file
mix test test/attio/records_test.exs:42  # Run a single test by line number
mix format                      # Format code
mix format --check-formatted    # Check formatting (used by pre-commit hook)
mix docs                        # Generate ExDoc documentation
mix deps.get                    # Fetch dependencies
```

## Architecture

### Module layout

```text
lib/attio.ex              # Top-level moduledoc and resource reference table
lib/attio/client.ex       # Attio.Client — Req wrapper, auth, error normalisation
lib/attio/error.ex        # Attio.Error struct (status, type, code, message)
lib/attio/objects.ex      # Object schema CRUD
lib/attio/attributes.ex   # Attribute CRUD on objects/lists
lib/attio/records.ex      # Record CRUD + stream/3 + assert/3
lib/attio/lists.ex        # List CRUD
lib/attio/entries.ex      # Entry CRUD + stream/3
lib/attio/notes.ex        # Note CRUD
lib/attio/tasks.ex        # Task CRUD
lib/attio/meetings.ex     # Meeting CRUD
lib/attio/webhooks.ex     # Webhook CRUD
lib/attio/workspace_members.ex  # WorkspaceMember list/get (read-only)
lib/attio/comments.ex     # Comment get/update/delete
lib/attio/threads.ex      # Thread list/get/create
lib/attio/meta.ex         # Meta.get_token/1
```

### Key patterns

- **Client**: `Attio.Client.new/1` accepts `:api_key`, `:base_url`, and any extra
  `Req.new/1` options (e.g. `plug: {Req.Test, __MODULE__}` in tests). Retries are
  disabled by default — leave retry strategy to the caller.

- **Request/response**: all functions return `{:ok, map()} | {:error, Attio.Error.t() | Exception.t()}`.
  Response bodies are decoded JSON with **string keys** (not atoms).

- **Pagination**: cursor-based. `list/2-3` returns one page. `stream/2-3` on
  `Records` and `Entries` wraps `Stream.resource/3` for lazy multi-page iteration.

- **Attribute values**: passed and returned as plain maps keyed by attribute slug.
  Responses include an `"attribute_type"` discriminator field.

### Testing

Tests use `Req.Test` stubs (requires `plug` test dependency). Each test module
creates its own client with `plug: {Req.Test, __MODULE__}` and stubs the
expected response:

```elixir
setup do
  client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
  %{client: client}
end

test "list/1", %{client: client} do
  Req.Test.stub(__MODULE__, fn conn ->
    Req.Test.json(conn, %{"data" => [...]})
  end)
  assert {:ok, _} = Attio.Records.list(client, "people")
end
```

For multi-page stream tests, inspect `conn.query_string` to branch on the
`cursor` parameter.
