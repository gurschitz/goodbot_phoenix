defmodule GoodbotWeb.Router do
  use GoodbotWeb, :router
 
  # This defines the browser pipeline, which is setup from phoenix by default
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # This defines the API Pipeline which
  # doesn't need all the default plugs from phoenix for rendering views
  # simply because we only render to json
  pipeline :api do
    plug :accepts, ["json"]
  end

  # everything that matches "/" will fall into this, 
  # if it doesn't match somewhere else
  scope "/", GoodbotWeb do
    # Use the default browser stack
    pipe_through :browser 

    # Here we define the path for displaying a single shop 
    # the :id of the shop is parameterized and can be replaced by an arbitrary value when calling the path,
    # i.e. /shops/1
    get "/shops/:id", ShopController, :show
  end

  scope "/api", GoodbotWeb do
    # Use the API Pipeline
    pipe_through :api 

    # In order to fulfill facebooks requirements we need a
    # get endpoint for verifying a call as well as a post endpoint
    # to handle actual messages. 
    # The name of the endpoint doesn't matter, as it can be set in the 
    # app settings under https://developers.facebook.com, but we'll stick to /webhook
    get "/webhook", WebhookController, :verify
    post "/webhook", WebhookController, :handle_event
  end
end
