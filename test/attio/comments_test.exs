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

  describe "get/2" do
    test "returns a single comment", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @comment})
      end)

      assert {:ok, %{"data" => %{"id" => %{"comment_id" => "c1"}}}} =
               Attio.Comments.get(client, "c1")
    end

    test "returns an error when the comment does not exist", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "not_found",
          "code" => "comment_not_found",
          "message" => "Comment not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404, code: "comment_not_found"}} =
               Attio.Comments.get(client, "nonexistent")
    end
  end

  describe "update/3" do
    test "updates a comment", %{client: client} do
      updated = Map.put(@comment, "content", [%{"type" => "text", "text" => "Updated!"}])

      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => updated})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Comments.update(client, "c1", %{
                 "content" => [%{"type" => "text", "text" => "Updated!"}]
               })
    end
  end

  describe "delete/2" do
    test "deletes a comment", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Comments.delete(client, "c1")
    end
  end
end
