defmodule Attio.WebhooksTest do
  use ExUnit.Case, async: true

  @webhook %{
    "id" => %{"workspace_id" => "ws1", "webhook_id" => "wh1"},
    "target_url" => "https://example.com/hooks"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  test "list/1 returns all webhooks", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@webhook]})
    end)

    assert {:ok, %{"data" => [%{"target_url" => "https://example.com/hooks"}]}} =
             Attio.Webhooks.list(client)
  end

  test "get/2 returns a single webhook", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @webhook})
    end)

    assert {:ok, %{"data" => %{"id" => %{"webhook_id" => "wh1"}}}} =
             Attio.Webhooks.get(client, "wh1")
  end

  test "create/2 creates a webhook", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @webhook})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Webhooks.create(client, %{
               "target_url" => "https://example.com/hooks",
               "subscriptions" => [%{"event_type" => "record.created"}]
             })
  end

  test "update/3 updates a webhook", %{client: client} do
    updated = Map.put(@webhook, "target_url", "https://example.com/new-hooks")

    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => updated})
    end)

    assert {:ok, %{"data" => %{"target_url" => "https://example.com/new-hooks"}}} =
             Attio.Webhooks.update(client, "wh1", %{
               "target_url" => "https://example.com/new-hooks"
             })
  end

  test "delete/2 deletes a webhook", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{})
    end)

    assert {:ok, _} = Attio.Webhooks.delete(client, "wh1")
  end
end
