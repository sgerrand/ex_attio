defmodule Attio.EntriesTest do
  use ExUnit.Case, async: true

  @entry %{
    "id" => %{"workspace_id" => "ws1", "list_id" => "l1", "entry_id" => "e1"},
    "values" => %{}
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "list/3" do
    test "returns a page of entries", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => [@entry],
          "pagination" => %{"next_cursor" => nil}
        })
      end)

      assert {:ok, %{"data" => [%{"id" => %{"entry_id" => "e1"}}]}} =
               Attio.Entries.list(client, "pipeline")
    end
  end

  describe "stream/3" do
    test "emits all entries across multiple pages", %{client: client} do
      entry2 = put_in(@entry, ["id", "entry_id"], "e2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@entry],
              "pagination" => %{"next_cursor" => "next"}
            })

          "next" ->
            Req.Test.json(conn, %{
              "data" => [entry2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      entries = Attio.Entries.stream(client, "pipeline") |> Enum.to_list()
      assert length(entries) == 2
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@entry],
              "pagination" => %{"next_cursor" => "next"}
            })

          "next" ->
            conn
            |> Plug.Conn.put_status(403)
            |> Req.Test.json(%{
              "status_code" => 403,
              "type" => "authentication_error",
              "code" => "forbidden",
              "message" => "Insufficient permissions."
            })
        end
      end)

      assert {:attio_stream_error, %Attio.Error{status: 403, code: "forbidden"}} =
               catch_throw(Attio.Entries.stream(client, "pipeline") |> Enum.to_list())
    end
  end

  describe "get/3" do
    test "returns a single entry", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @entry})
      end)

      assert {:ok, %{"data" => %{"id" => %{"entry_id" => "e1"}}}} =
               Attio.Entries.get(client, "pipeline", "e1")
    end
  end

  describe "create/3" do
    test "creates an entry", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @entry})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Entries.create(client, "pipeline", %{"record_id" => "rec1"})
    end
  end

  describe "update/4" do
    test "updates an entry", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @entry})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Entries.update(client, "pipeline", "e1", %{"stage" => "closed"})
    end
  end

  describe "delete/3" do
    test "deletes an entry", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Entries.delete(client, "pipeline", "e1")
    end
  end
end
