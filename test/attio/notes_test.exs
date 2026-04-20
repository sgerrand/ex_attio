defmodule Attio.NotesTest do
  use ExUnit.Case, async: true

  @note %{
    "id" => %{"workspace_id" => "ws1", "note_id" => "n1"},
    "title" => "Meeting recap"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  test "list/2 returns a page of notes", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@note], "pagination" => %{"next_cursor" => nil}})
    end)

    assert {:ok, %{"data" => [%{"title" => "Meeting recap"}]}} = Attio.Notes.list(client)
  end

  test "get/2 returns a single note", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @note})
    end)

    assert {:ok, %{"data" => %{"id" => %{"note_id" => "n1"}}}} = Attio.Notes.get(client, "n1")
  end

  test "create/2 creates a note", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @note})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Notes.create(client, %{
               "parent_object" => "people",
               "parent_record_id" => "r1",
               "title" => "Meeting recap",
               "content" => %{"type" => "doc", "content" => []}
             })
  end

  test "update/3 updates a note", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => Map.put(@note, "title", "Updated title")})
    end)

    assert {:ok, %{"data" => %{"title" => "Updated title"}}} =
             Attio.Notes.update(client, "n1", %{"title" => "Updated title"})
  end

  test "delete/2 deletes a note", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{})
    end)

    assert {:ok, _} = Attio.Notes.delete(client, "n1")
  end
end
