defmodule Goodbot.Apis.Facebook.Messages do
	@moduledoc """
  This module wraps the Facebook Messages API Endpoint.
  """

	# Here we define the endpoint from facebook including the API version
	@facebook_messages_endpoint "https://graph.facebook.com/v2.6/me/messages"

	# These are the default headers we're sending with every request
	@default_headers [{"Content-Type", "application/json"}]

	# Setting the page_access_token from the secrets configuration as a constant
	@access_token Application.get_env(:goodbot, :facebook)[:page_access_token]

	@doc """
	This is the method that will send a given message to the user with the given psid.
  """
	def send(message, psid) do
    # We build up the json structure 
    # using the psid and the message that we put inside a map
    # and finally encode it to json
		json = %{
			recipient: %{
				id: psid
			},
			message: message
		} |> Poison.encode!

		# Error handling with HTTPoison is really simple:
		# We just execute the request and pattern match the tagged response
		case HTTPoison.post(base_url(), json, @default_headers) do
			# In case the tag is :ok and the response is a HTTPoison.Response map with status_code set to 200, 
			# this matches and we can directly extract the body and inspect it
			{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
				body #|> IO.inspect

			# In case the tag is :error and the response is a HTTPoison.Error map,
			# this matches and we simply extract the reason and inspect it
			{:error, %HTTPoison.Error{reason: reason}} ->
				reason |> IO.inspect
		end

		# We wouldn't need to return anything but since elixir has implicit returns
		# and IO.inspect returns the inspected value, either the body or the error reason 
		# will be returned implicily
	end

	defp base_url, do: "#{@facebook_messages_endpoint}?access_token=#{@access_token}"
end