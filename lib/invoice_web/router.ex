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

  scope "/apidocs" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :invoice, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "0.1",
        title: "Invoice Api",
      },
      basePath: "/api"
    }
  end
end
