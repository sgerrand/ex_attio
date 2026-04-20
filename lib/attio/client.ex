defmodule Attio.Client do
  @moduledoc """
  HTTP client for the Attio API.

  Build a client once with `new/1` and pass it to resource functions:

      client = Attio.Client.new(api_key: System.fetch_env!("ATTIO_API_KEY"))
      {:ok, response} = Attio.Records.list(client, "people")

  ## Options for `new/1`

    * `:api_key` - Required. Your Attio API key (used as a Bearer token).
    * `:base_url` - Optional. Defaults to `https://api.attio.com`.

  Any additional keyword options are forwarded to `Req.new/1`, which allows
  test-time injection of a plug adapter:

      client = Attio.Client.new(api_key: "test", plug: {Req.Test, __MODULE__})

  """

  @enforce_keys [:req]
  defstruct [:req]

  @type t :: %__MODULE__{req: Req.Request.t()}

  @base_url "https://api.attio.com"

  @doc false
  @spec encode(String.t()) :: String.t()
  def encode(id), do: URI.encode(id, &URI.char_unreserved?/1)

  @doc """
  Creates a new client.

  Raises `KeyError` if `:api_key` is not provided.
  """
  @spec new(keyword()) :: t()
  def new(opts) do
    {client_opts, req_opts} = Keyword.split(opts, [:api_key, :base_url])
    api_key = Keyword.fetch!(client_opts, :api_key)
    base_url = Keyword.get(client_opts, :base_url, @base_url)

    req = Req.new([base_url: base_url, auth: {:bearer, api_key}, retry: false] ++ req_opts)
    %__MODULE__{req: req}
  end

  @doc false
  @spec paginate(t(), (keyword() -> {:ok, map()} | {:error, term()}), keyword()) ::
          Enumerable.t()
  def paginate(%__MODULE__{}, list_fn, params \\ []) do
    Stream.resource(
      fn -> {params, nil, false} end,
      fn
        {_params, _cursor, :done} ->
          {:halt, nil}

        {params, cursor, false} ->
          req_params = if cursor, do: Keyword.put(params, :cursor, cursor), else: params

          case list_fn.(req_params) do
            {:ok, %{"data" => data, "pagination" => %{"next_cursor" => nil}}} ->
              {data, {params, nil, :done}}

            {:ok, %{"data" => data, "pagination" => %{"next_cursor" => next}}} ->
              {data, {params, next, false}}

            {:error, err} ->
              throw({:attio_stream_error, err})
          end
      end,
      fn _ -> :ok end
    )
  end

  @doc false
  @spec request(t(), atom(), String.t(), keyword()) ::
          {:ok, term()} | {:error, Attio.Error.t() | Exception.t()}
  def request(%__MODULE__{req: req}, method, path, opts \\ []) do
    case Req.request(req, [method: method, url: path] ++ opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok,
       %{
         body: %{
           "status_code" => status,
           "type" => type,
           "code" => code,
           "message" => message
         }
       }} ->
        {:error, %Attio.Error{status: status, type: type, code: code, message: message}}

      {:ok, %{status: status, body: body}} ->
        {:error,
         %Attio.Error{
           status: status,
           type: "unknown_error",
           code: "unknown",
           message: inspect(body)
         }}

      {:error, exception} ->
        {:error, exception}
    end
  end
end
