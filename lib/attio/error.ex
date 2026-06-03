defmodule Attio.Error do
  @moduledoc """
  Represents an error response from the Attio API.

  All four fields are populated from the JSON error body returned by the API:

      %Attio.Error{
        status: 404,
        type: "invalid_request_error",
        code: "not_found",
        message: "Object 'foobar' not found."
      }

  When the body is missing some of these fields, `:type`/`:code` fall back to
  `"unknown_error"`/`"unknown"` and `:message` to an inspected copy of the body.

  `Attio.Error` is itself an exception, so it can be raised directly and works
  with `Exception.message/1`:

      {:error, %Attio.Error{} = error} = Attio.Objects.get(client, "missing")
      raise error
      # ** (Attio.Error) Attio API error (HTTP 404, invalid_request_error/not_found): ...

  Transport errors (connection failures, timeouts) are returned as the
  underlying exception (e.g. `Req.TransportError`) rather than `Attio.Error`.
  """

  @enforce_keys [:status, :type, :code, :message]
  defexception [:status, :type, :code, :message]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          type: String.t(),
          code: String.t(),
          message: String.t()
        }

  @impl true
  def message(%__MODULE__{status: status, type: type, code: code, message: message}) do
    "Attio API error (HTTP #{status}, #{type}/#{code}): #{message}"
  end
end
