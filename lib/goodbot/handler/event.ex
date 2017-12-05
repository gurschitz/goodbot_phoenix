defmodule Goodbot.Handler.Event do
	@moduledoc """
  This module is the entry point for any event that is being sent to the bot.
  It's implemented using the GenServer behaviour, so that it can be scaled easily
  """

	# This makes our module a GenServer
	use GenServer
	alias Goodbot.Handler
 
	@doc """
	A wrapper method that will start and initialize the GenServer. 
	The passed messaging_object is passed on as a initalization object.
  """
	def start_link(messaging_object) when is_map(messaging_object) do
		GenServer.start_link(__MODULE__, messaging_object, [])
	end

	@doc """
	We initialize the Scenario Handler with a psid from the sender
	and a message object that contains all the necessary info from what the user sent.
  """
	def init(messaging_object) do
		# We decompose the messaging object and extract psid
		%{"sender" => %{"id" => psid}} = messaging_object

		# we set the initial state with the psid from the sender and the message
		initial_state = %{psid: psid, messaging_object: messaging_object}

		# we return the inital state of the app with a tagged response
		{:ok, initial_state}
	end

	@doc """
	This method just wraps the GenServer.cast call. We could use the same code outside of this module.
	We use a cast in this case instead of a call, since we don't expect a return value from the GenServer. 
	We simply want "inform" GenServer of the event that has happened.
  """
	def handle(event), do: GenServer.cast(event, {:run})

	# The following method is the callback that needs to be implemented
	# in order to understand cast calls . Te callback itself called by the GenServer module
	#
	# All we do here is to extract the messaging object from the state (that was initially set in the init method)
	# and pass it into the handle_event method that will decide what to do with it
  def handle_cast({:run}, state = %{messaging_object: messaging_object}) do
  	handle_event(messaging_object, state)

  	# we don't change the state of the messaging_object
    {:noreply, state}
	end

	@doc """
	This method is called if the messaging_object includes a message field.
	We can handle it using the message handler.
  """
	defp handle_event(%{"message" => message}, state), do: Handler.Message.handle(message, state)

	# Other type of events could be handled in a similar fashion, 
	# for example the following way

	# def handle_event(%{"postback" => postback}, state) do
	# 	Handler.Postback.handle(postback, state)
	# end

	@doc """
	At last there's a fallback method if we receive events that we don't use yet.
  """
	defp handle_event(_messaging_object,_), do: IO.puts "NOT IMPLEMENTED"
	
end