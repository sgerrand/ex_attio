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

  describe "stream/2" do
    test "emits all notes across multiple pages", %{client: client} do
      note2 = put_in(@note, ["id", "note_id"], "n2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@note],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [note2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      notes = Attio.Notes.stream(client) |> Enum.to_list()
      assert length(notes) == 2
      assert Enum.map(notes, &get_in(&1, ["id", "note_id"])) == ["n1", "n2"]
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@note],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            conn
            |> Plug.Conn.put_status(500)
            |> Req.Test.json(%{
              "status_code" => 500,
              "type" => "api_error",
              "code" => "internal_server_error",
              "message" => "An unexpected error occurred."
            })
        end
      end)

      assert {:attio_stream_error, %Attio.Error{status: 500}} =
               catch_throw(Attio.Notes.stream(client) |> Enum.to_list())
    end
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
