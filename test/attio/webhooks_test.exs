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

  describe "list/1" do
    test "returns all webhooks", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [@webhook]})
      end)

      assert {:ok, %{"data" => [%{"target_url" => "https://example.com/hooks"}]}} =
               Attio.Webhooks.list(client)
    end
  end

  describe "get/2" do
    test "returns a single webhook", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @webhook})
      end)

      assert {:ok, %{"data" => %{"id" => %{"webhook_id" => "wh1"}}}} =
               Attio.Webhooks.get(client, "wh1")
    end

    test "returns an error when the webhook does not exist", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "not_found",
          "code" => "webhook_not_found",
          "message" => "Webhook not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404, code: "webhook_not_found"}} =
               Attio.Webhooks.get(client, "nonexistent")
    end
  end

  describe "create/2" do
    test "creates a webhook", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @webhook})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Webhooks.create(client, %{
                 "target_url" => "https://example.com/hooks",
                 "subscriptions" => [%{"event_type" => "record.created"}]
               })
    end
  end

  describe "update/3" do
    test "updates a webhook", %{client: client} do
      updated = Map.put(@webhook, "target_url", "https://example.com/new-hooks")

      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => updated})
      end)

      assert {:ok, %{"data" => %{"target_url" => "https://example.com/new-hooks"}}} =
               Attio.Webhooks.update(client, "wh1", %{
                 "target_url" => "https://example.com/new-hooks"
               })
    end
  end

  describe "delete/2" do
    test "deletes a webhook", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Webhooks.delete(client, "wh1")
    end
  end
end
