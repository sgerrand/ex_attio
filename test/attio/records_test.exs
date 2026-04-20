defmodule Attio.RecordsTest do
  use ExUnit.Case, async: true

  @record %{
    "id" => %{"workspace_id" => "ws1", "object_id" => "obj1", "record_id" => "r1"},
    "values" => %{}
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "list/3" do
    test "returns a page of records", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => [@record],
          "pagination" => %{"next_cursor" => nil}
        })
      end)

      assert {:ok, %{"data" => [%{"id" => %{"record_id" => "r1"}}]}} =
               Attio.Records.list(client, "people")
    end

    test "returns error for unknown object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "invalid_request_error",
          "code" => "not_found",
          "message" => "Object not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404}} = Attio.Records.list(client, "missing")
    end
  end

  describe "stream/3" do
    test "emits all records across multiple pages", %{client: client} do
      record2 = put_in(@record, ["id", "record_id"], "r2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@record],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [record2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      records = Attio.Records.stream(client, "people") |> Enum.to_list()
      assert length(records) == 2
      assert Enum.map(records, &get_in(&1, ["id", "record_id"])) == ["r1", "r2"]
    end

    test "emits nothing for empty result set", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [], "pagination" => %{"next_cursor" => nil}})
      end)

      assert [] = Attio.Records.stream(client, "people") |> Enum.to_list()
    end
  end

  describe "get/3" do
    test "returns a single record", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @record})
      end)

      assert {:ok, %{"data" => %{"id" => %{"record_id" => "r1"}}}} =
               Attio.Records.get(client, "people", "r1")
    end
  end

  describe "create/3" do
    test "creates a record", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @record})
      end)

      assert {:ok, %{"data" => %{"id" => %{"record_id" => "r1"}}}} =
               Attio.Records.create(client, "people", %{
                 "email_addresses" => [%{"email_address" => "alice@example.com"}]
               })
    end
  end

  describe "update/4" do
    test "updates a record", %{client: client} do
      updated = put_in(@record, ["values", "name"], [%{"first_name" => "Bob"}])

      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => updated})
      end)

      assert {:ok, %{"data" => _}} =
               Attio.Records.update(client, "people", "r1", %{
                 "name" => [%{"first_name" => "Bob"}]
               })
    end
  end

  describe "delete/3" do
    test "deletes a record", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Records.delete(client, "people", "r1")
    end
  end

  describe "assert/3" do
    test "returns existing record with action=updated when match found", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @record, "action" => "updated"})
      end)

      assert {:ok, %{"action" => "updated", "data" => _}} =
               Attio.Records.assert(client, "people", %{
                 "email_addresses" => [%{"email_address" => "alice@example.com"}]
               })
    end

    test "returns new record with action=created when no match found", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @record, "action" => "created"})
      end)

      assert {:ok, %{"action" => "created"}} =
               Attio.Records.assert(client, "people", %{
                 "email_addresses" => [%{"email_address" => "new@example.com"}]
               })
    end

    test "returns conflict error when multiple records match", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(409)
        |> Req.Test.json(%{
          "status_code" => 409,
          "type" => "invalid_request_error",
          "code" => "conflict",
          "message" => "Multiple records match the provided values."
        })
      end)

      assert {:error, %Attio.Error{status: 409, code: "conflict"}} =
               Attio.Records.assert(client, "people", %{
                 "email_addresses" => [%{"email_address" => "shared@example.com"}]
               })
    end
  end
end
