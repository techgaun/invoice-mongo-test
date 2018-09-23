defmodule InvoiceWeb.InvoiceControllerTest do
  use InvoiceWeb.ConnCase

  alias Invoice.{Invoices, Helpers, Repo}
  alias Invoice.Invoices.Invoice
  alias Faker.Name, as: FakeName
  alias Faker.Phone.EnUs, as: FakePhone

  @items [%{"item_name" => "Mouse", "quantity" => 1, "price" => 20.50}]
  @create_attrs %{customer_name: FakeName.name(), customer_mobile: FakePhone.phone(), payment_due_date: Helpers.iso_date_with_shift(days: 10), items: @items}
  @update_attrs %{}
  @invalid_attrs %{customer_name: 123}

  def fixture(:invoice) do
    {:ok, invoice} = Invoices.create_invoice(@create_attrs)
    invoice
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invoices", %{conn: conn} do
      Repo.delete_all(Invoice)
      conn = get conn, invoice_path(conn, :index)
      assert json_response(conn, 200) == []
    end
  end

  describe "create invoice" do
    test "renders invoice when data is valid", %{conn: conn} do
      conn = post conn, invoice_path(conn, :create), invoice: @create_attrs
      assert %{"order_id" => id} = json_response(conn, 201)

      conn = get conn, invoice_path(conn, :show, id)
      resp = json_response(conn, 200)
      assert resp["order_id"] === id
      assert resp["customer_mobile"] === @create_attrs.customer_mobile
      assert resp["customer_name"] === @create_attrs.customer_name
      assert resp["items"] === @items
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, invoice_path(conn, :create), invoice: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invoice" do
    setup [:create_invoice]

    test "renders invoice when data is valid", %{conn: conn, invoice: %Invoice{order_id: id} = invoice} do
      conn = put conn, invoice_path(conn, :update, invoice), invoice: @update_attrs
      assert %{"order_id" => ^id} = json_response(conn, 200)

      conn = get conn, invoice_path(conn, :show, id)

      resp = json_response(conn, 200)
      assert resp["order_id"] === id
      assert resp["customer_mobile"] === @create_attrs.customer_mobile
      assert resp["customer_name"] === @create_attrs.customer_name
      assert resp["items"] === @items
    end

    test "renders errors when data is invalid", %{conn: conn, invoice: invoice} do
      conn = put conn, invoice_path(conn, :update, invoice), invoice: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invoice" do
    setup [:create_invoice]

    test "deletes chosen invoice", %{conn: conn, invoice: invoice} do
      conn = delete conn, invoice_path(conn, :delete, invoice)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, invoice_path(conn, :show, invoice)
      end
    end
  end

  describe "make payment" do
    setup [:create_invoice]

    test "valid payment goes through", %{conn: conn, invoice: invoice} do
      invoice_amount = Helpers.calculate_items_amount(invoice.items)

      params = %{
        "amount" => invoice_amount,
        "payment_date" => Helpers.iso_date_with_shift(days: 2)
      }
      conn = post conn, invoice_path(conn, :make_payment, invoice.order_id), params
      resp = json_response(conn, 200)
      assert resp["status"] === "paid"
    end

    test "payment date fallsback to current date time and payment goes through as long as amount matches", %{conn: conn, invoice: invoice} do
      invoice_amount = Helpers.calculate_items_amount(invoice.items)
      conn = post conn, invoice_path(conn, :make_payment, invoice.order_id), %{"amount" => invoice_amount}
      resp = json_response(conn, 200)
      assert resp["status"] === "paid"
    end

    test "payment is rejected if amount does not match", %{conn: conn, invoice: invoice} do
      conn = post conn, invoice_path(conn, :make_payment, invoice.order_id), %{"amount" => 0.0}
      resp = json_response(conn, 422)
      assert resp["success"] === false
      assert resp["errors"]["detail"] =~ "Payment amount does not match"
    end

    test "payment is rejected if payment due date has been past", %{conn: conn, invoice: invoice} do
      invoice_amount = Helpers.calculate_items_amount(invoice.items)

      params = %{
        "amount" => invoice_amount,
        "payment_date" => Helpers.iso_date_with_shift(days: 22)
      }

      conn = post conn, invoice_path(conn, :make_payment, invoice.order_id), params
      resp = json_response(conn, 422)
      assert resp["success"] === false
      assert resp["errors"]["detail"] =~ "Payment due date has passed"
    end
  end

  defp create_invoice(_) do
    invoice = fixture(:invoice)
    {:ok, invoice: invoice}
  end
end
