defmodule Attio.Comments do
  @moduledoc """
  Functions for managing individual comments.

  Comments belong to threads, which are attached to records or list entries.
  Use `Attio.Threads` to create a new thread with an initial comment.

  Requires the `comment:read` scope for read operations and
  `comment:read-write` for mutations.
  """

  alias Attio.Client

  defp encode(id), do: URI.encode(id, &URI.char_unreserved?/1)

  @doc """
  Gets a single comment by its ID.
  """
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, comment_id) do
    Client.request(client, :get, "/v2/comments/#{encode(comment_id)}")
  end

  @doc """
  Updates a comment's content.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, comment_id, attrs) when is_map(attrs) do
    Client.request(client, :patch, "/v2/comments/#{encode(comment_id)}", json: %{"data" => attrs})
  end

  @doc """
  Deletes a comment.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, comment_id) do
    Client.request(client, :delete, "/v2/comments/#{encode(comment_id)}")
  end
end
