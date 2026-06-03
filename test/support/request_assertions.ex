defmodule Attio.Test.RequestAssertions do
  @moduledoc false
  # Helpers for asserting the shape of an outgoing request from inside a
  # `Req.Test` stub. These verify that resource functions build the method,
  # path, and JSON envelope the API expects — not just that they decode a
  # canned response.

  import ExUnit.Assertions

  @doc """
  Asserts the request method and path, returning the (unchanged) conn so it can
  be threaded into the stub's response.
  """
  def assert_request(conn, method, path) do
    assert conn.method == method
    assert conn.request_path == path
    conn
  end

  @doc """
  Reads and JSON-decodes the request body, returning `{conn, decoded}`. The
  returned conn must be used for the response, as reading the body consumes it.
  """
  def read_json_body(conn) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    {conn, Jason.decode!(body)}
  end
end
