defmodule GoodbotWeb.WebhookController do
  @moduledoc """
  This module is our Controller that takes care of handling the requests to our webhook.
  """
  
  use GoodbotWeb, :controller
  alias Goodbot.Worker

  # Setting the verify_token as a constant.
  @verify_token Application.get_env(:goodbot, :facebook)[:verify_token]

  @doc """
  This function destructures the params into hub.mode, hub.verify_token and hub.challenge.
  Verification happens because the params are pattern matched so that they
  include the correct hub.verify_token and hub.mode. Furthermore, using pattern matching 
  the hub.challenge parameter is being bound to the challenge variable.
  """
  def verify(conn, 
    %{
      "hub.mode" => "subscribe", 
      "hub.verify_token" => @verify_token, 
      "hub.challenge" => challenge
      }) do
  	conn 
    |> put_status(200)
    |> text(challenge)	
  end

  @doc """
  Fallback for everything else. In this case, it should return forbidden.
  """
  def verify(conn, _), do: forbidden conn

  @doc """
  This function pattern matches the params to have the object of type page 
  and it extracts the entry into the entries variable
  """
  def handle_event(conn = %Plug.Conn{private: %{facebook_request_valid: true}}, %{"object" => "page", "entry" => entries}) do
    
    # Iterating over the entries, as there might be more, 
    # since Facebook eventually does batch requests.
  	entries
    |> Enum.each(&(handle_entry(&1)))

    text conn, "OK"
  end

  @doc """
  Fallback for everything else. In this case, we will return forbidden.
  """
  def handle_event(conn, _), do: forbidden conn

  @doc """
  This function pattern matches the messsaging array and extracts the first element.
  According to facebook's documentation, the list will only ever have one element,
  so we can safely pattern match the first element out of it and discard the rest 
  """
  defp handle_entry(%{"messaging" => [event | _rest]}) do
  	# We initialize our worker with the event
  	{:ok, worker_pid} = Worker.start_link(event)

    # We need to run the run function of the Worker module and pass the worker_pid
    # that we got above when we initialized the worker. This will make the 
    # respective cast call to our GenServer and effectively run the code that handles our event
  	Worker.run(worker_pid)
  end

  @doc """
  This function helps us to send 403 "Forbidden" to the client
  """
  defp forbidden(conn) do
	  conn
	  |> send_resp(403, "Forbidden")
	  |> halt()
  end
end
