defmodule InvoiceWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use InvoiceWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(InvoiceWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(InvoiceWeb.ErrorView, :"404")
  end

  def call(conn, {:error, msg}) do
    send_response(conn, msg, 422)
  end

  defp send_response(conn, msg, status) do
    msg = format_msg(msg)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, msg)
    |> halt
  end

  def format_msg(msg) when is_map(msg), do: Poison.encode!(msg)
  def format_msg(msg) when is_binary(msg) do
    msg = %{
      success: false,
      errors: %{
        detail: msg
      }
    }

    format_msg(msg)
  end
  def format_msg(msg), do: msg
end
