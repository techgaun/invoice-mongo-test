defmodule Invoice.InvoicesTest do
  use Invoice.DataCase

  alias Faker.Name, as: FakeName
  alias Faker.Phone.EnUs, as: FakePhone
  alias Invoice.{Invoices, Helpers, Repo}

  describe "invoices" do
    alias Invoice.Invoices.Invoice

    @items [%{item_name: "Mouse", quantity: 1, price: 20.50}]
    @valid_attrs %{customer_name: FakeName.name(), customer_mobile: FakePhone.phone(), payment_due_date: Helpers.iso_date_with_shift(days: 10), items: @items}
    @update_attrs %{customer_name: FakeName.name()}
    @invalid_attrs %{customer_name: 123}

    def invoice_fixture(attrs \\ %{}) do
      {:ok, invoice} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Invoices.create_invoice()

      invoice
    end

    test "list_invoices/0 returns all invoices" do
      Repo.delete_all(Invoice)
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.order_id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(@valid_attrs)
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      assert {:ok, invoice} = Invoices.update_invoice(invoice, @update_attrs)
      assert %Invoice{} = invoice
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.order_id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.order_id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end
end
