defmodule Attio.MetaTest do
  use ExUnit.Case, async: true

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  test "get_token/1 returns token metadata", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{
        "data" => %{
          "workspace" => %{"workspace_id" => "ws1", "name" => "Acme Corp"},
          "scopes" => ["record_permission:read", "note:read"]
        }
      })
    end)

    assert {:ok, %{"data" => %{"workspace" => %{"name" => "Acme Corp"}, "scopes" => [_ | _]}}} =
             Attio.Meta.get_token(client)
  end
end
