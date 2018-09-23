defmodule InvoiceWeb.InvoiceController do
  use InvoiceWeb, :controller

  alias Invoice.Invoices
  alias Invoice.Invoices.Invoice

  action_fallback InvoiceWeb.FallbackController

  def index(conn, _params) do
    invoices = Invoices.list_invoices()
    render(conn, "index.json", invoices: invoices)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    with {:ok, %Invoice{} = invoice} <- Invoices.create_invoice(invoice_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", invoice_path(conn, :show, invoice))
      |> render("show.json", invoice: invoice)
    end
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    render(conn, "show.json", invoice: invoice)
  end

  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Invoices.get_invoice!(id)

    with {:ok, %Invoice{} = invoice} <- Invoices.update_invoice(invoice, invoice_params) do
      render(conn, "show.json", invoice: invoice)
    end
  end

  def delete(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    with {:ok, %Invoice{}} <- Invoices.delete_invoice(invoice) do
      send_resp(conn, :no_content, "")
    end
  end

  def make_payment(conn, %{"id" => id, "amount" => amount, "payment_date" => payment_date}) do
    with {:fetch_invoice, invoice} <- {:fetch_invoice, Invoices.get_invoice!(id)},
         {:payment_datetime, payment_date} <- {:payment_datetime, maybe_convert_datetime(payment_date)},
         {:validate, :ok} <- {:validate, Invoices.validate_payment(invoice, amount, payment_date)},
         {:commit_payment, {:ok, invoice}} <- {:commit_payment, Invoices.update_invoice(invoice, %{payment_date: payment_date, status: "paid"})} do
      render(conn, "show.json", invoice: invoice)
    else
      {:validate, {:error, msg}} -> {:error, msg}
    end
  end

  def make_payment(conn, params) do
    make_payment(
      conn,
      Map.put(params, "payment_date", DateTime.utc_now())
    )
  end

  defp maybe_convert_datetime(%DateTime{} = datetime), do: datetime
  defp maybe_convert_datetime(iso_datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(iso_datetime)

    datetime
  end
end
