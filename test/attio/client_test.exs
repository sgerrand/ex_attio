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

  describe "encode/1" do
    test "leaves unreserved identifiers untouched" do
      assert Attio.Client.encode("people") == "people"
    end

    test "percent-encodes reserved characters in path segments" do
      assert Attio.Client.encode("a/b c?d") == "a%2Fb%20c%3Fd"
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

    test "fills defaults for a partial Attio error body", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(429)
        |> Req.Test.json(%{"status_code" => 429, "type" => "rate_limit_error"})
      end)

      assert {:error,
              %Attio.Error{status: 429, type: "rate_limit_error", code: "unknown"} = error} =
               Attio.Client.request(client, :get, "/v2/meta/token")

      assert is_binary(error.message)
    end

    test "returns transport exception on connection error" do
      error = %Req.TransportError{reason: :econnrefused}

      req =
        Req.new(base_url: "http://localhost", retry: false)
        |> Req.Request.prepend_request_steps(inject_error: fn req -> {req, error} end)

      client = %Attio.Client{req: req}

      assert {:error, ^error} = Attio.Client.request(client, :get, "/v2/meta/token")
    end
  end

  describe "Attio.Error as an exception" do
    test "Exception.message/1 summarises status, type, code, and message" do
      error = %Attio.Error{
        status: 404,
        type: "invalid_request_error",
        code: "not_found",
        message: "Object not found."
      }

      assert Exception.message(error) ==
               "Attio API error (HTTP 404, invalid_request_error/not_found): Object not found."
    end

    test "can be raised" do
      error = %Attio.Error{
        status: 500,
        type: "api_error",
        code: "internal_server_error",
        message: "boom"
      }

      assert_raise Attio.Error, ~r/HTTP 500/, fn -> raise error end
    end
  end
end
