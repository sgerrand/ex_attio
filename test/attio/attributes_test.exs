defmodule Attio.AttributesTest do
  use ExUnit.Case, async: true

  @attribute %{
    "api_slug" => "linkedin_url",
    "title" => "LinkedIn URL",
    "type" => "text"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "list/4" do
    test "returns attributes for an object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => [
            %{"api_slug" => "email_addresses", "type" => "email-address"},
            %{"api_slug" => "name", "type" => "personal-name"}
          ]
        })
      end)

      assert {:ok, %{"data" => attributes}} = Attio.Attributes.list(client, :objects, "people")
      assert length(attributes) == 2
    end

    test "returns attributes for a list", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [%{"api_slug" => "stage", "type" => "status"}]})
      end)

      assert {:ok, %{"data" => [%{"api_slug" => "stage"}]}} =
               Attio.Attributes.list(client, :lists, "pipeline")
    end
  end

  describe "create/4" do
    test "creates an attribute on an object", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @attribute})
      end)

      assert {:ok, %{"data" => %{"api_slug" => "linkedin_url"}}} =
               Attio.Attributes.create(client, :objects, "people", %{
                 "api_slug" => "linkedin_url",
                 "title" => "LinkedIn URL",
                 "type" => "text"
               })
    end
  end

  describe "get/4" do
    test "returns a single attribute by slug", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @attribute})
      end)

      assert {:ok, %{"data" => %{"api_slug" => "linkedin_url"}}} =
               Attio.Attributes.get(client, :objects, "people", "linkedin_url")
    end

    test "returns error for unknown attribute", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "status_code" => 404,
          "type" => "invalid_request_error",
          "code" => "not_found",
          "message" => "Attribute not found."
        })
      end)

      assert {:error, %Attio.Error{status: 404, code: "not_found"}} =
               Attio.Attributes.get(client, :objects, "people", "missing_attr")
    end
  end

  describe "update/5" do
    test "updates an attribute on an object", %{client: client} do
      updated = Map.put(@attribute, "title", "LinkedIn Profile")

      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => updated})
      end)

      assert {:ok, %{"data" => %{"title" => "LinkedIn Profile"}}} =
               Attio.Attributes.update(client, :objects, "people", "linkedin_url", %{
                 "title" => "LinkedIn Profile"
               })
    end
  end

  describe "delete/4" do
    test "deletes a custom attribute", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
      end)

      assert {:ok, _} = Attio.Attributes.delete(client, :objects, "people", "linkedin_url")
    end

    test "returns error when deleting a system attribute", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(403)
        |> Req.Test.json(%{
          "status_code" => 403,
          "type" => "authentication_error",
          "code" => "forbidden",
          "message" => "System attributes cannot be deleted."
        })
      end)

      assert {:error, %Attio.Error{status: 403, code: "forbidden"}} =
               Attio.Attributes.delete(client, :objects, "people", "email_addresses")
    end
  end
end
