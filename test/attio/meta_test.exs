defmodule Attio.MetaTest do
  use ExUnit.Case, async: true

  setup do
    client = Attio.Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "get_token/1" do
    test "returns token metadata", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "workspace" => %{"workspace_id" => "ws1", "name" => "Acme Corp"},
            "scopes" => ["record_permission:read", "note:read"]
          }
        })
      end)

      assert {:ok, %{"data" => %{"workspace" => %{"name" => "Acme Corp"}, "scopes" => [_ | _]}}} =
               Attio.Meta.get_token(client)
    end

    test "returns an error on authentication failure", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(401)
        |> Req.Test.json(%{
          "status_code" => 401,
          "type" => "authentication_required",
          "code" => "invalid_api_key",
          "message" => "The API key provided is invalid."
        })
      end)

      assert {:error, %Attio.Error{status: 401, code: "invalid_api_key"}} =
               Attio.Meta.get_token(client)
    end
  end
end
