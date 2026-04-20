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

  test "list/2 returns a page of tasks", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => [@task], "pagination" => %{"next_cursor" => nil}})
    end)

    assert {:ok, %{"data" => [%{"content" => "Follow up with Alice"}]}} = Attio.Tasks.list(client)
  end

  test "get/2 returns a single task", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @task})
    end)

    assert {:ok, %{"data" => %{"id" => %{"task_id" => "t1"}}}} = Attio.Tasks.get(client, "t1")
  end

  test "create/2 creates a task", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => @task})
    end)

    assert {:ok, %{"data" => _}} =
             Attio.Tasks.create(client, %{
               "content" => "Follow up with Alice",
               "deadline_at" => nil
             })
  end

  test "update/3 updates a task", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{"data" => Map.put(@task, "is_completed", true)})
    end)

    assert {:ok, %{"data" => %{"is_completed" => true}}} =
             Attio.Tasks.update(client, "t1", %{"is_completed" => true})
  end

  test "delete/2 deletes a task", %{client: client} do
    Req.Test.stub(__MODULE__, fn conn ->
      Req.Test.json(conn, %{})
    end)

    assert {:ok, _} = Attio.Tasks.delete(client, "t1")
  end
end
