defmodule Attio.ThreadsTest do
  use ExUnit.Case, async: true

  @thread %{
    "id" => %{"workspace_id" => "ws1", "thread_id" => "th1"},
    "comments" => []
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "stream/2" do
    test "emits all threads across multiple pages", %{client: client} do
      thread2 = put_in(@thread, ["id", "thread_id"], "th2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@thread],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [thread2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      threads = Attio.Threads.stream(client) |> Enum.to_list()
      assert length(threads) == 2
      assert Enum.map(threads, &get_in(&1, ["id", "thread_id"])) == ["th1", "th2"]
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@thread],
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
               catch_throw(Attio.Threads.stream(client) |> Enum.to_list())
    end
  end

  test "list/2 returns a page of threads", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@thread], "pagination" => %{"next_cursor" => nil}})
    end)

    assert {:ok, %{"data" => [%{"id" => %{"thread_id" => "th1"}}]}} =
             Attio.Threads.list(client)
  end

  test "get/2 returns a single thread", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @thread})
    end)

    assert {:ok, %{"data" => %{"id" => %{"thread_id" => "th1"}}}} =
             Attio.Threads.get(client, "th1")
  end

  test "create/2 creates a thread", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @thread})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Threads.create(client, %{
               "record_id" => "r1",
               "format" => "plaintext",
               "content" => "First comment"
             })
  end
end
