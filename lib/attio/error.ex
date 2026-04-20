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

  Transport errors (connection failures, timeouts) are returned as the
  underlying exception rather than `Attio.Error`.
  """

  @enforce_keys [:status, :type, :code, :message]
  defstruct [:status, :type, :code, :message]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          type: String.t(),
          code: String.t(),
          message: String.t()
        }
end
