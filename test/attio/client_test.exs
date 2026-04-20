defmodule Attio.ClientTest do
  use ExUnit.Case, async: true

  describe "new/1" do
    test "builds a client from api_key" do
      client = Attio.Client.new(api_key: "key123")
      assert %Attio.Client{req: %Req.Request{}} = client
    end

    test "raises when api_key is missing" do
      assert_raise KeyError, fn -> Attio.Client.new([]) end
    end
  end

  describe "request/4" do
    setup do
      client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
      %{client: client}
    end

    test "returns decoded body on 2xx", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"id" => "abc"}})
      end)

      assert {:ok, %{"data" => %{"id" => "abc"}}} =
               Attio.Client.request(client, :get, "/v2/meta/token")
    end

    test "returns Attio.Error on API error response", %{client: client} do
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

      assert {:error, %Attio.Error{status: 404, code: "not_found", type: "invalid_request_error"}} =
               Attio.Client.request(client, :get, "/v2/objects/missing")
    end

    test "returns Attio.Error with unknown type for non-standard error body", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.json(%{"error" => "internal server error"})
      end)

      assert {:error, %Attio.Error{status: 500, type: "unknown_error"}} =
               Attio.Client.request(client, :get, "/v2/meta/token")
    end
  end
end
