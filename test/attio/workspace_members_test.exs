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

  describe "list/1" do
    test "returns all workspace members", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [@member]})
      end)

      assert {:ok, %{"data" => [%{"name" => "Alice Smith"}]}} =
               Attio.WorkspaceMembers.list(client)
    end
  end

  describe "get/2" do
    test "returns a single workspace member", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @member})
      end)

      assert {:ok, %{"data" => %{"email_address" => "alice@example.com"}}} =
               Attio.WorkspaceMembers.get(client, "wm1")
    end

    test "returns an error when the member does not exist", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "not_found",
          "code" => "workspace_member_not_found",
          "message" => "Workspace member not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404, code: "workspace_member_not_found"}} =
               Attio.WorkspaceMembers.get(client, "nonexistent")
    end
  end
end
