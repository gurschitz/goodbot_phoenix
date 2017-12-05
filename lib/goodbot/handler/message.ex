defmodule Goodbot.Handler.Message do
	@moduledoc """
  The attachments handler takes care of handling a message object.
  """
  
  require Goodbot.Handler.DefaultHandler  
	@before_compile Goodbot.Handler.DefaultHandler
	alias Goodbot.Handler.Attachments

	# We set a default message with an empty attachments array, to make sure
	# that we always have an attachment, even if the message that will be handled
	# doesn't contain one
	@default_message %{"attachments" => []}

	@doc """
	This is the entry point for the message handler.
  ere, the message gets decomposed and based on what the message includes, the respective subroutines can be called.
  """
	def handle(message, state) do
		# We decompose the message into attachments and a text
		# Since the default_message contains an attachment porperty, 
		# the left side will always match the right side
  	%{"attachments" => attachments} = Enum.into(message, @default_message)

  	# We know call the respective subroutine that will handle the attachments array for us
  	Attachments.handle(attachments, state)

  	# This example currently doesn't handle text or quick reply input, 
  	# but it could be handled in a similar fashion as the attachments, i.e. the following way:
  	# 
  	# QuickReply.handle(quick_reply, state)
  	# Text.handle(text, state)
  	# 
  	# Note that the quick_reply as well as the text data would need to be extracted 
  	# as well out of the message map above and the respective handlers would need to be created
	end
end