defmodule Goodbot.Worker do
	@moduledoc """
  This module defines the Worker process for an incoming event.

  It's implementing the GenServer behaviour which allows 
  us to effectively handle the request in the background.
  """

	# This makes our module a GenServer
	use GenServer
	alias Goodbot.Handler
 
	@doc """
	A wrapper method that will start and initialize the GenServer. 
	The passed event is passed on as a initalization object.
  """
	def start_link(event) when is_map(event) do
		GenServer.start_link(__MODULE__, event, [])
	end

	@doc """
	We initialize the Scenario Handler with a psid from the sender
	and a message object that contains all the necessary info from what the user sent.
  """
	def init(event) do
		# We decompose the messaging object and extract psid
		%{"sender" => %{"id" => psid}} = event

		# we set the initial state with the psid from the sender and the event
		initial_state = %{psid: psid, event: event}

		# we return the inital state of the app with a tagged response
		{:ok, initial_state}
	end

	@doc """
	This method just wraps the GenServer.cast call. We could use the same code outside of this module.
	We use a cast in this case instead of a call, since we don't expect a return value from the GenServer. 
	We simply want "inform" GenServer of the event that has happened.
  """
	def run(worker), do: GenServer.cast(worker, {:run})

	# The following method is the callback that needs to be implemented
	# in order to understand cast calls . Te callback itself called by the GenServer module
	#
	# All we do here is to extract the messaging object from the state (that was initially set in the init method)
	# and pass it into the event handler that will decide what to do with it.

	@doc """
	The following method is the callback that needs to be implemented in order to understand cast calls.
	The callback itself called by the GenServer module.

	All we do here is to extract the messaging object from the state (that was initially set in the init method) and pass it into the event handler that will decide what to do with it.
  """
  def handle_cast({:run}, state = %{event: event}) do
  	Goodbot.Handler.Event.handle(event, state)

  	# we don't change the state of the messaging_object
    {:noreply, state}
	end
	
end