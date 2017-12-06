defmodule Goodbot.Handler.Event do
	@moduledoc """
  This module is the entry point for any event that is being sent to the bot.
  """

  require Goodbot.Handler.DefaultHandler  
	@before_compile Goodbot.Handler.DefaultHandler
	alias Goodbot.Handler.Message

	@doc """
	This method is called if the messaging_object includes a message field.
	We can handle it using the message handler.
  """
	def handle(%{"message" => message}, state), do: Message.handle(message, state)

	# Other type of events could be handled in a similar fashion, 
	# for example the following way

	# def handle(%{"postback" => postback}, state) do
	# 	Handler.Postback.handle(postback, state)
	# end

end