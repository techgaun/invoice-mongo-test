defmodule InvoiceWeb.InvoiceView do
  use InvoiceWeb, :view
  alias InvoiceWeb.InvoiceView

  @render_fields [
    :order_id,
    :customer_mobile,
    :customer_name,
    :payment_date,
    :payment_due_date,
    :status,
    :items
  ]

  def render("index.json", %{invoices: invoices}) do
    render_many(invoices, InvoiceView, "invoice.json")
  end

  def render("show.json", %{invoice: invoice}) do
    render_one(invoice, InvoiceView, "invoice.json")
  end

  def render("invoice.json", %{invoice: invoice}) do
    invoice
    |> Map.from_struct()
    |> Map.take(@render_fields)
  end
end
