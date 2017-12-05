# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :goodbot, GoodbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "46yTSV2wf3cf3CAUdB/jm9KUJEm7Ckk44iFicg5IEjVRIU/EyNJu4KmuyjskgAjg",
  render_errors: [view: GoodbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Goodbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :goodbot, :goodbag, public_url: "https://www.goodbag.io"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
