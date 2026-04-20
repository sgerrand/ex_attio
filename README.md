# Attio

An Elixir client for the [Attio REST API](https://developers.attio.com).

## Installation

```elixir
def deps do
  [
    {:attio, "~> 0.1"}
  ]
end
```

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
