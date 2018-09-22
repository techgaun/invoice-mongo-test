defmodule InvoiceWeb.Router do
  use InvoiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", InvoiceWeb do
    pipe_through :api
  end
end
