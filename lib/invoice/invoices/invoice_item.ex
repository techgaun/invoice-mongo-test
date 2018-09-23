defmodule Invoice.Invoices.InvoiceItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :item_name, :string
    field :quantity, :integer
    field :price, :float
  end

  @fields ~w(item_name quantity price)a

  def changeset(invoice_item, attrs) do
    invoice_item
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
