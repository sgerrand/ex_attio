defmodule Attio.TasksTest do
  use ExUnit.Case, async: true

  @task %{
    "id" => %{"workspace_id" => "ws1", "task_id" => "t1"},
    "content" => "Follow up with Alice",
    "is_completed" => false
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "stream/2" do
    test "emits all tasks across multiple pages", %{client: client} do
      task2 = put_in(@task, ["id", "task_id"], "t2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@task],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [task2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      tasks = Attio.Tasks.stream(client) |> Enum.to_list()
      assert length(tasks) == 2
      assert Enum.map(tasks, &get_in(&1, ["id", "task_id"])) == ["t1", "t2"]
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@task],
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
               catch_throw(Attio.Tasks.stream(client) |> Enum.to_list())
    end
  end

  describe "stream_all/2" do
    test "returns {:ok, list} with all tasks across pages", %{client: client} do
      task2 = put_in(@task, ["id", "task_id"], "t2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@task],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [task2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      assert {:ok, tasks} = Attio.Tasks.stream_all(client)
      assert length(tasks) == 2
      assert Enum.map(tasks, &get_in(&1, ["id", "task_id"])) == ["t1", "t2"]
    end

    test "returns {:error, reason} on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@task],
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

      assert {:error, %Attio.Error{status: 500}} = Attio.Tasks.stream_all(client)
    end
  end

  describe "list/2" do
    test "returns a page of tasks", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [@task], "pagination" => %{"next_cursor" => nil}})
      end)

      assert {:ok, %{"data" => [%{"content" => "Follow up with Alice"}]}} =
               Attio.Tasks.list(client)
    end
  end

  describe "get/2" do
    test "returns a single task", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @task})
      end)

      assert {:ok, %{"data" => %{"id" => %{"task_id" => "t1"}}}} = Attio.Tasks.get(client, "t1")
    end
  end

  describe "create/2" do
    test "creates a task", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @task})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Tasks.create(client, %{
                 "content" => "Follow up with Alice",
                 "deadline_at" => nil
               })
    end
  end

  describe "update/3" do
    test "updates a task", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => Map.put(@task, "is_completed", true)})
      end)

      assert {:ok, %{"data" => %{"is_completed" => true}}} =
               Attio.Tasks.update(client, "t1", %{"is_completed" => true})
    end
  end

  describe "delete/2" do
    test "deletes a task", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Tasks.delete(client, "t1")
    end
  end
end
