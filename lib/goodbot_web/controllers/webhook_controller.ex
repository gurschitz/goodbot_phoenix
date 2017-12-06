defmodule GoodbotWeb.WebhookController do
  @moduledoc """
  This module is our Controller that takes care of handling the requests to our webhook.
  """
  
  use GoodbotWeb, :controller
  alias Goodbot.Worker

  # We're setting the verify_token as a constant
  @verify_token Application.get_env(:goodbot, :facebook)[:verify_token]

  @doc """
  This method decomposes the params into hub.mode, hub.verify_token and hub.challenge.
  Verification happens because we pattern match the hub.verify_token onto the verify_token that we defined as a constant
  """
  def verify(conn, %{"hub.mode" => "subscribe", "hub.verify_token" => @verify_token, "hub.challenge" => challenge}) do
  	conn 
    |> put_status(200)
    |> text(challenge)	
  end

  @doc """
  Fallback for everything else. In this case, we will return forbidden.
  """
  def verify(conn, _), do: forbidden conn

  @doc """
  This method pattern matches the params to have the object of type page 
  and it extracts the entry into the entries variable
  """
  def handle_message_connection(conn = %Plug.Conn{private: %{verified: true}}, %{"object" => "page", "entry" => entries}) do
  	# We need to iterate over the entries (there might be more, facebook does batch requests)
  	entries
    |> Enum.each(&(handle_entry(&1)))

    text conn, "OK"
  end

  @doc """
  Fallback for everything else. In this case, we will return forbidden.
  """
  def handle_message_connection(conn, _), do: forbidden conn

  @doc """
  This method pattern matches the messsaging array and extracts the first element.
  According to facebook's documentation, the list will only ever have one element,
  so we can safely pattern match the first element out of it and discard the rest 
  """
  defp handle_entry(%{"messaging" => [event | _rest]}) do
  	# We initialize our worker with the event
  	{:ok, worker_pid} = Worker.start_link(event)

    # We need to run the run method of the Worker module and pass the worker_pid
    # that we got above when we initialized the worker. This will make the 
    # respective cast call to our GenServer and effectively run the code that handles our event
  	Worker.run(worker_pid)
  end

  @doc """
  This method helps us to send 403 "Forbidden" to the client
  """
  defp forbidden(conn) do
	  conn
	  |> send_resp(403, "Forbidden")
	  |> halt()
  end
end
