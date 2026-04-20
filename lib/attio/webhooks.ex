defmodule Attio.Webhooks do
  @moduledoc """
  Functions for managing webhook subscriptions.

  Webhooks allow your application to receive real-time notifications when data
  changes in Attio. Requires the `webhook:read` scope for read operations and
  `webhook:read-write` for mutations.
  """

  alias Attio.Client

  @doc """
  Lists all webhooks in the workspace.
  """
  @spec list(Client.t()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client) do
    Client.request(client, :get, "/v2/webhooks")
  end

  @doc """
  Gets a single webhook by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, webhook_id) do
    Client.request(client, :get, "/v2/webhooks/#{webhook_id}")
  end

  @doc """
  Creates a webhook.

  ## Required attributes

    * `"target_url"` - The HTTPS URL that will receive event payloads.
    * `"subscriptions"` - List of event subscription objects, each with an
      `"event_type"` field.

  ## Example

      Attio.Webhooks.create(client, %{
        "target_url" => "https://my-app.example.com/webhooks/attio",
        "subscriptions" => [
          %{"event_type" => "record.created"},
          %{"event_type" => "record.updated"}
        ]
      })

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/webhooks", json: %{"data" => attrs})
  end

  @doc """
  Updates a webhook (e.g. to change its target URL or subscriptions).
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, webhook_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/webhooks/#{webhook_id}", json: %{"data" => attrs})
  end

  @doc """
  Deletes a webhook.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, webhook_id) do
    Client.request(client, :delete, "/v2/webhooks/#{webhook_id}")
  end
end
