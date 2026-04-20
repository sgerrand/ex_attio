# Attio

[![Test Status](https://github.com/sgerrand/ex_attio/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/sgerrand/ex_attio/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/sgerrand/ex_attio/badge.svg?branch=main)](https://coveralls.io/github/sgerrand/ex_attio?branch=main)
[![Hex Version](https://img.shields.io/hexpm/v/attio.svg)](https://hex.pm/packages/attio)
[![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/attio/)

An Elixir client for the [Attio REST API](https://developers.attio.com).

## Installation

Add `attio` to your dependencies in `mix.exs`:

<!-- x-release-please-start-version -->
```elixir
def deps do
  [
    {:attio, "~> 0.1.1"}
  ]
end
```
<!-- x-release-please-end -->

## Usage

```elixir
client = Attio.Client.new(api_key: System.fetch_env!("ATTIO_API_KEY"))

# List people
{:ok, response} = Attio.Records.list(client, "people")

# Stream all companies across pages
companies =
  client
  |> Attio.Records.stream("companies")
  |> Enum.to_list()

# Create a person record
{:ok, record} =
  Attio.Records.create(client, "people", %{
    "name" => [%{"first_name" => "Alice", "last_name" => "Smith"}],
    "email_addresses" => [%{"email_address" => "alice@example.com"}]
  })

# Upsert (assert) a record
{:ok, %{"action" => action}} =
  Attio.Records.assert(client, "people", %{
    "email_addresses" => [%{"email_address" => "alice@example.com"}]
  })
```

All functions return `{:ok, response}` or `{:error, %Attio.Error{}}`. See the
`Attio` module for a full resource reference and the [Attio API docs](https://developers.attio.com)
for attribute value formats.

## Documentation

```bash
mix docs
```

## Development

### Prerequisites

This project targets Elixir ~> 1.17 and OTP 25–28. The exact versions used for
development are pinned in `.tool-versions`:

- Erlang 28.4
- Elixir 1.19.4-otp-28

If you use [asdf](https://asdf-vm.com) or [mise](https://mise.jdx.dev), the
correct versions will be selected automatically.

### Getting started

```bash
mix deps.get        # fetch dependencies
mix test            # run the test suite
```

### Code quality

```bash
mix format                   # auto-format source files
mix format --check-formatted # check formatting (run by CI)
mix credo --strict           # static analysis
```

### Generating documentation

```bash
mix docs
```

Open `doc/index.html` in a browser to preview the generated site.
