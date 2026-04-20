defmodule Attio.ObjectsTest do
  use ExUnit.Case, async: true

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "list/1" do
    test "returns list of objects", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => [%{"id" => %{"object_id" => "abc"}, "api_slug" => "people"}]
        })
      end)

      assert {:ok, %{"data" => [%{"api_slug" => "people"}]}} = Attio.Objects.list(client)
    end
  end

  describe "get/2" do
    test "returns a single object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"api_slug" => "people", "singular_noun" => "Person"}})
      end)

      assert {:ok, %{"data" => %{"api_slug" => "people"}}} = Attio.Objects.get(client, "people")
    end

    test "returns error for unknown object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "invalid_request_error",
          "code" => "not_found",
          "message" => "Object 'foobar' not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404, code: "not_found"}} =
               Attio.Objects.get(client, "foobar")
    end
  end

  describe "create/2" do
    test "creates a custom object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "api_slug" => "widgets",
            "singular_noun" => "Widget",
            "plural_noun" => "Widgets"
          }
        })
      end)

      assert {:ok, %{"data" => %{"api_slug" => "widgets"}}} =
               Attio.Objects.create(client, %{
                 "api_slug" => "widgets",
                 "singular_noun" => "Widget",
                 "plural_noun" => "Widgets"
               })
    end
  end

  describe "update/3" do
    test "updates an object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"api_slug" => "people", "singular_noun" => "Human"}})
      end)

      assert {:ok, %{"data" => %{"singular_noun" => "Human"}}} =
               Attio.Objects.update(client, "people", %{"singular_noun" => "Human"})
    end
  end

  describe "list_views/2" do
    test "returns views for an object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [%{"id" => %{"view_id" => "v1"}}]})
      end)

      assert {:ok, %{"data" => [_]}} = Attio.Objects.list_views(client, "people")
    end
  end
end
