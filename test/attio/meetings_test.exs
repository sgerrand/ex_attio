defmodule Attio.MeetingsTest do
  use ExUnit.Case, async: true

  @meeting %{
    "id" => %{"workspace_id" => "ws1", "meeting_id" => "m1"},
    "title" => "Intro call"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "stream/2" do
    test "emits all meetings across multiple pages", %{client: client} do
      meeting2 = put_in(@meeting, ["id", "meeting_id"], "m2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@meeting],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [meeting2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      meetings = Attio.Meetings.stream(client) |> Enum.to_list()
      assert length(meetings) == 2
      assert Enum.map(meetings, &get_in(&1, ["id", "meeting_id"])) == ["m1", "m2"]
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@meeting],
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
               catch_throw(Attio.Meetings.stream(client) |> Enum.to_list())
    end
  end

  describe "stream_all/2" do
    test "returns {:ok, list} with all meetings across pages", %{client: client} do
      meeting2 = put_in(@meeting, ["id", "meeting_id"], "m2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@meeting],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [meeting2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      assert {:ok, meetings} = Attio.Meetings.stream_all(client)
      assert length(meetings) == 2
      assert Enum.map(meetings, &get_in(&1, ["id", "meeting_id"])) == ["m1", "m2"]
    end

    test "returns {:error, reason} on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@meeting],
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

      assert {:error, %Attio.Error{status: 500}} = Attio.Meetings.stream_all(client)
    end
  end

  test "list/2 returns a page of meetings", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@meeting], "pagination" => %{"next_cursor" => nil}})
    end)

    assert {:ok, %{"data" => [%{"title" => "Intro call"}]}} = Attio.Meetings.list(client)
  end

  test "get/2 returns a single meeting", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @meeting})
    end)

    assert {:ok, %{"data" => %{"id" => %{"meeting_id" => "m1"}}}} =
             Attio.Meetings.get(client, "m1")
  end

  test "create/2 creates a meeting", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @meeting})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Meetings.create(client, %{
               "title" => "Intro call",
               "start_time" => "2026-05-01T10:00:00Z",
               "end_time" => "2026-05-01T11:00:00Z"
             })
  end

  test "update/3 updates a meeting", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => Map.put(@meeting, "title", "Discovery call")})
    end)

    assert {:ok, %{"data" => %{"title" => "Discovery call"}}} =
             Attio.Meetings.update(client, "m1", %{"title" => "Discovery call"})
  end

  test "delete/2 deletes a meeting", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{})
    end)

    assert {:ok, _} = Attio.Meetings.delete(client, "m1")
  end
end
