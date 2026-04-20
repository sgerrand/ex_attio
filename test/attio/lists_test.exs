defmodule Attio.ListsTest do
  use ExUnit.Case, async: true

  @list_data %{
    "id" => %{"workspace_id" => "ws1", "list_id" => "l1"},
    "title" => "Pipeline",
    "api_slug" => "pipeline"
  }

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "list/1" do
    test "returns all lists", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [@list_data]})
      end)

      assert {:ok, %{"data" => [%{"api_slug" => "pipeline"}]}} = Attio.Lists.list(client)
    end
  end

  describe "get/2" do
    test "returns a single list", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @list_data})
      end)

      assert {:ok, %{"data" => %{"api_slug" => "pipeline"}}} = Attio.Lists.get(client, "pipeline")
    end
  end

  describe "create/2" do
    test "creates a list", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => @list_data})
      end)

      assert {:ok, %{"data" => %{"api_slug" => "pipeline"}}} =
               Attio.Lists.create(client, %{"title" => "Pipeline", "object_slug" => "companies"})
    end
  end

  describe "update/3" do
    test "updates a list", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => Map.put(@list_data, "title", "Sales Pipeline")})
      end)

      assert {:ok, %{"data" => %{"title" => "Sales Pipeline"}}} =
               Attio.Lists.update(client, "pipeline", %{"title" => "Sales Pipeline"})
    end
  end

  describe "list_views/2" do
    test "returns views for a list", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => [%{"id" => %{"view_id" => "v1"}, "name" => "All"}]})
      end)

      assert {:ok, %{"data" => [%{"name" => "All"}]}} = Attio.Lists.list_views(client, "pipeline")
    end
  end
end
