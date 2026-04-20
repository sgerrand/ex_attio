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
