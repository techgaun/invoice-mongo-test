defmodule Invoice.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Invoice.Invoices.InvoiceItem


  @primary_key {:order_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Phoenix.Param, key: :order_id}

  schema "invoices" do
    field :customer_name, :string
    field :customer_mobile, :string
    field :payment_due_date, Ecto.DateTime
    field :status, :string, default: "pending"
    field :payment_date, Ecto.DateTime

    embeds_many :items, InvoiceItem

    timestamps(usec: false)
  end

  @req_fields ~w(customer_name items payment_due_date)a
  @fields ~w(customer_name customer_mobile payment_due_date status payment_date)a

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, @fields)
    |> cast_embed(:items, required: true)
    |> validate_required(@req_fields)
  end
end
