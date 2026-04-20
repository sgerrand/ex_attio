defmodule Attio.WorkspaceMembersTest do
  use ExUnit.Case, async: true

  @member %{
    "id" => %{"workspace_id" => "ws1", "workspace_member_id" => "wm1"},
    "name" => "Alice Smith",
    "email_address" => "alice@example.com"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  test "list/1 returns all workspace members", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@member]})
    end)

    assert {:ok, %{"data" => [%{"name" => "Alice Smith"}]}} =
             Attio.WorkspaceMembers.list(client)
  end

  test "get/2 returns a single workspace member", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @member})
    end)

    assert {:ok, %{"data" => %{"email_address" => "alice@example.com"}}} =
             Attio.WorkspaceMembers.get(client, "wm1")
  end
end
