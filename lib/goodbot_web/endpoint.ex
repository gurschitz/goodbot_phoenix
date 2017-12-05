defmodule GoodbotWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :goodbot

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :goodbot, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, GoodbotWeb.Parsers.JSON_WITH_VERIFICATION],
    pass: ["*/*"],
    json_decoder: Poison,
    # Here we are passing custom options to the Plug.Parsers plug
    # These options will be passed to our custom JSON_WITH_VERIFICATION parser
    signature_header_field: "x-hub-signature",
    prefix: "sha1=",
    secret: Application.get_env(:goodbot, :facebook)[:app_secret],
    verify_request_path: "/api/webhook"

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_goodbot_key",
    signing_salt: "4m4nOuXm"

  plug GoodbotWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
