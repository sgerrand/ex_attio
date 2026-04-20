defmodule Attio.AttributesTest do
  use ExUnit.Case, async: true

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
        Req.Test.json(conn, %{
          "data" => %{"api_slug" => "linkedin_url", "title" => "LinkedIn URL", "type" => "text"}
        })
      end)

      assert {:ok, %{"data" => %{"api_slug" => "linkedin_url"}}} =
               Attio.Attributes.create(client, :objects, "people", %{
                 "api_slug" => "linkedin_url",
                 "title" => "LinkedIn URL",
                 "type" => "text"
               })
    end
  end
end
