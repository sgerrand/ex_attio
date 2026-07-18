defmodule Attio.PaginatedTest do
  use ExUnit.Case, async: true

  alias Attio.Client

  # A minimal resource module that mixes in the generated stream/2 and
  # stream_all/2. Its list/2 pages "/v2/widgets" through the shared client, so
  # the generated functions are exercised directly against Attio.Paginated
  # rather than only via the concrete callers (Notes/Tasks/Meetings/Threads).
  defmodule Widgets do
    use Attio.Paginated, resource: "widgets"

    alias Attio.Client

    def list(%Client{} = client, params \\ []) do
      Client.request(client, :get, "/v2/widgets", params: params)
    end
  end

  @widget %{"id" => %{"widget_id" => "w1"}}

  setup do
    client = Client.new(api_key: "test-key", plug: {Req.Test, __MODULE__})
    %{client: client}
  end

  describe "stream/2" do
    test "emits all widgets across multiple pages", %{client: client} do
      widget2 = put_in(@widget, ["id", "widget_id"], "w2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@widget],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [widget2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      widgets = Widgets.stream(client) |> Enum.to_list()
      assert length(widgets) == 2
      assert Enum.map(widgets, &get_in(&1, ["id", "widget_id"])) == ["w1", "w2"]
    end

    test "throws attio_stream_error on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.json(%{
          "status_code" => 500,
          "type" => "api_error",
          "code" => "internal_server_error",
          "message" => "An unexpected error occurred."
        })
      end)

      assert {:attio_stream_error, %Attio.Error{status: 500}} =
               catch_throw(Widgets.stream(client) |> Enum.to_list())
    end
  end

  describe "stream_all/2" do
    test "returns {:ok, list} with all widgets across pages", %{client: client} do
      widget2 = put_in(@widget, ["id", "widget_id"], "w2")

      Req.Test.stub(__MODULE__, fn conn ->
        params = URI.decode_query(conn.query_string)

        case params["cursor"] do
          nil ->
            Req.Test.json(conn, %{
              "data" => [@widget],
              "pagination" => %{"next_cursor" => "cursor_page2"}
            })

          "cursor_page2" ->
            Req.Test.json(conn, %{
              "data" => [widget2],
              "pagination" => %{"next_cursor" => nil}
            })
        end
      end)

      assert {:ok, widgets} = Widgets.stream_all(client)
      assert length(widgets) == 2
      assert Enum.map(widgets, &get_in(&1, ["id", "widget_id"])) == ["w1", "w2"]
    end

    test "returns {:error, reason} on API failure mid-stream", %{client: client} do
      Req.Test.stub(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(500)
        |> Req.Test.json(%{
          "status_code" => 500,
          "type" => "api_error",
          "code" => "internal_server_error",
          "message" => "An unexpected error occurred."
        })
      end)

      assert {:error, %Attio.Error{status: 500}} = Widgets.stream_all(client)
    end
  end
end
