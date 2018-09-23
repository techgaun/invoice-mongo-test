defmodule InvoiceWeb.InvoiceController do
  use InvoiceWeb, :controller
  use PhoenixSwagger

  alias PhoenixSwagger.JsonApi
  alias Invoice.Invoices
  alias Invoice.Invoices.Invoice

  action_fallback InvoiceWeb.FallbackController

  def swagger_definitions do
    %{
      Item: swagger_schema do
        title "Invoice Item"
        description "An Item"
        properties do
          item_name :string, "Item Name", required: true
          quantity :integer, "Quantity of item", required: true
          price :number, "Price per unit of item", required: true
        end
        example %{
          name: "Mouse",
          quantity: 20,
          price: 20.50
        }
      end,
      Items: swagger_schema do
        title "Invoice Items"
        description "List of Invoice Items"
        type :array
        items Schema.ref(:Item)
      end,
      InvoiceResource: JsonApi.resource do
        description "An invoice object."
        attributes do
          order_id :string, "Order ID for Invoice"
          customer_name :string, "Customer Name", required: true
          customer_mobile :string, "Customer Mobile Phone"
          payment_due_date :string, "Payment Due Date in ISO8601 Format"
          payment_date :string, "Payment Due Date in ISO8601 Format"
          status :string, "One of pending and paid"
          items Schema.ref(:Items), "List of items the invoice is for"
        end
        link :self, "The link to invoice resource"
      end,
      Invoices: JsonApi.page(:InvoiceResource),
      Invoice: JsonApi.single(:InvoiceResource)
    }
  end

  swagger_path :index do
    get "/invoices"
    description "List invoices"
    produces "application/json"
    tag "Invoices"
    operation_id "list_invoices"
    response 200, "OK", Schema.ref(:Invoices)
  end

  def index(conn, _params) do
    invoices = Invoices.list_invoices()
    render(conn, "index.json", invoices: invoices)
  end

  swagger_path :create do
    post "/invoices"
    description "Create invoices"
    produces "application/json"
    tag "Invoices"
    operation_id "create_invoices"
    response 200, "OK", Schema.ref(:Invoices)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    with {:ok, %Invoice{} = invoice} <- Invoices.create_invoice(invoice_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", invoice_path(conn, :show, invoice))
      |> render("show.json", invoice: invoice)
    end
  end

  swagger_path :show do
    get "/invoices/{id}"
    description "Get Single Invoice"
    produces "application/json"
    parameters do
      id :path, :string, "Order ID for Invoice"
    end
    tag "Invoices"
    operation_id "get_invoice"
    response 200, "OK", Schema.ref(:Invoice)
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    render(conn, "show.json", invoice: invoice)
  end

  swagger_path :update do
    put "/invoices/{id}"
    description "Update Invoice"
    produces "application/json"
    parameters do
      id :path, :string, "Order ID for Invoice"
    end
    tag "Invoices"
    operation_id "update_invoice"
    response 200, "OK", Schema.ref(:Invoice)
  end

  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Invoices.get_invoice!(id)

    with {:ok, %Invoice{} = invoice} <- Invoices.update_invoice(invoice, invoice_params) do
      render(conn, "show.json", invoice: invoice)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/invoices/{id}"
    description "Delete Invoice"
    produces "application/json"
    parameters do
      id :path, :string, "Order ID for Invoice"
    end
    tag "Invoices"
    operation_id "delete_invoice"
    response 204, "No Content"
  end

  def delete(conn, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id)
    with {:ok, %Invoice{}} <- Invoices.delete_invoice(invoice) do
      send_resp(conn, :no_content, "")
    end
  end

  swagger_path :make_payment do
    post "/invoices/{id}/make-payment"
    description "Make Payment for Invoice"
    produces "application/json"
    parameters do
      id :path, :string, "Order ID for Invoice"
      amount :body, :number, "Amount to pay", required: true
      payment_date :body, :string, "Payment Date", format: "date-time", example: "2018-09-23T15:33:22.000Z"
    end
    tag "Invoices"
    operation_id "pay_invoice"
    response 200, "OK", Schema.ref(:Invoices)
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
