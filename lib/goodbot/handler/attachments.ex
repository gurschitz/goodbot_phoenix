defmodule Goodbot.Handler.Attachments do
	@moduledoc """
  The attachments handler takes care of handling attachments (like location attachments) that are sent to the bot. 
  """

  require Goodbot.Handler.DefaultHandler
	@before_compile Goodbot.Handler.DefaultHandler
	alias Goodbot.Scenarios.FindShops

	@doc """
	This is the handle method of the attachments handler.
  If the attachments array is a list and is not empty, this method will match.
  The list is decomposed into the first attachment (head) and the rest (tail) of the attachment list.
  """
	def handle(attachments = [attachment | rest], state) when is_list(attachments) and length(attachments) > 0 do
		# We call the subroutine to handle a single attachment
		handle_attachment(attachment, state)

		# Only if we still have attachments in the rest, we will call 
		unless Enum.empty?(rest), do: handle(rest, state)
	end

	@doc """
	If we're dealing with a location attachment, then this method will match the attachment map.
	we extract the coordinates out of the attachment and run the FindShops Scenario
  """
	defp handle_attachment(%{"payload" => %{"coordinates" => coordinates}, "type" => "location"}, state) do
		FindShops.run(coordinates, state)
	end
	
end