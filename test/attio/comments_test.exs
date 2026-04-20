defmodule Attio.CommentsTest do
  use ExUnit.Case, async: true

  @comment %{
    "id" => %{"workspace_id" => "ws1", "comment_id" => "c1"},
    "content" => [%{"type" => "text", "text" => "Hello!"}]
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  test "get/2 returns a single comment", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @comment})
    end)

    assert {:ok, %{"data" => %{"id" => %{"comment_id" => "c1"}}}} =
             Attio.Comments.get(client, "c1")
  end

  test "update/3 updates a comment", %{client: client} do
    updated = Map.put(@comment, "content", [%{"type" => "text", "text" => "Updated!"}])

    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => updated})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Comments.update(client, "c1", %{
               "content" => [%{"type" => "text", "text" => "Updated!"}]
             })
  end

  test "delete/2 deletes a comment", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{})
    end)

    assert {:ok, _} = Attio.Comments.delete(client, "c1")
  end
end
