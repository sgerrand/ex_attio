defmodule Attio.Paginated do
  @moduledoc false

  # Injects `stream/2` and `stream_all/2` for cursor-paginated resources whose
  # `list/2` takes only a client and a params keyword (Notes, Tasks, Meetings,
  # Threads). The generated functions are identical bar the resource noun, so
  # defining them here keeps the streaming contract in a single place.
  #
  # Records and Entries page a sub-collection, so their `stream/3` and
  # `stream_all/3` carry an extra leading path segment and stay hand-written.
  #
  # Pass `:resource` (the plural noun) to interpolate into the generated docs:
  #
  #     use Attio.Paginated, resource: "notes"

  defmacro __using__(opts) do
    resource = Keyword.fetch!(opts, :resource)
    module = inspect(__CALLER__.module)

    stream_doc = """
    Returns a lazy stream of all #{resource} across all pages.

    Accepts the same options as `list/2`. Raises `{:attio_stream_error, error}`
    on API failure mid-stream. Use `stream_all/2` if you prefer a standard
    `{:ok, list} | {:error, term()}` return value.
    """

    stream_all_doc = """
    Fetches all #{resource} across all pages and returns them as a list.

    Accepts the same options as `list/2`. Returns `{:ok, [map()]}` on success
    or `{:error, term()}` if any page request fails. Unlike `stream/2`, the
    entire result set is loaded into memory.

    ## Example

        {:ok, #{resource}} = #{module}.stream_all(client)

    """

    quote do
      @doc unquote(stream_doc)
      @spec stream(Attio.Client.t(), keyword()) :: Enumerable.t()
      def stream(%Attio.Client{} = client, params \\ []) do
        Attio.Client.paginate(client, &list(client, &1), params)
      end

      @doc unquote(stream_all_doc)
      @spec stream_all(Attio.Client.t(), keyword()) :: Attio.Client.list_response()
      def stream_all(%Attio.Client{} = client, params \\ []) do
        client |> stream(params) |> Attio.Client.collect()
      end
    end
  end
end
