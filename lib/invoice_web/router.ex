defmodule InvoiceWeb.Router do
  use InvoiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", InvoiceWeb do
    pipe_through :api

    resources "/invoices", InvoiceController, except: [:new, :edit]
    post "/invoices/:id/make-payment", InvoiceController, :make_payment
  end
end
