# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :invoice,
  ecto_repos: [Invoice.Repo]

# Configures the endpoint
config :invoice, InvoiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rbP3LCLialL4gdXNXU1S3sXL+jC8F/6DZeH4fyeT7OHL34ig5NaOIShDc8j5Kaw3",
  render_errors: [view: InvoiceWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Invoice.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :invoice, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: InvoiceWeb.Router,
      endpoint: InvoiceWeb.Endpoint
    ]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
