defmodule Attio.Notes do
  @moduledoc """
  Functions for managing notes linked to records.

  Notes are rich-text documents attached to parent records. Requires the
  `note:read` scope for read operations and `note:read-write` for mutations.
  """

  alias Attio.Client

  @doc """
  Lists notes. Returns one page.

  ## Options

    * `:limit` - Number of notes per page.
    * `:cursor` - Pagination cursor from a previous response.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, params \\ []) do
    Client.request(client, :get, "/v2/notes", params: params)
  end

  @doc """
  Gets a single note by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, note_id) do
    Client.request(client, :get, "/v2/notes/#{note_id}")
  end

  @doc """
  Creates a note linked to a record.

  ## Required attributes

    * `"parent_object"` - The object slug of the parent record (e.g. `"people"`).
    * `"parent_record_id"` - The record ID to attach this note to.
    * `"title"` - Note title.
    * `"content"` - Note body as a document object.

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Client.request(client, :post, "/v2/notes", json: %{"data" => attrs})
  end

  @doc """
  Updates a note.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, note_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/notes/#{note_id}", json: %{"data" => attrs})
  end

  @doc """
  Deletes a note.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, note_id) do
    Client.request(client, :delete, "/v2/notes/#{note_id}")
  end
end
