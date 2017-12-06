defmodule Goodbot.Apis.Goodbag.Branches do
	@moduledoc """
  This module wraps the Goodbag Branches API Endpoint.
  """

  # Setting the goodbag public url as a constant
  @goodbag_public_url Application.get_env(:goodbot, :goodbag)[:public_url]

	@doc """
	This function allows to get all shop near given lat and long coordinates
	with an optional limit parameter, that defaults to 10.
  """
	def get_all(lat, long, limit \\ 10), do: get "#{base_url()}?lat=#{lat}&long=#{long}&limit=#{limit}" 

	@doc """
	This function allows to retrieve one shop using the given id.
  """
	def get_one(id), do: get "#{base_url()}/#{id}" 

	@doc """
	This helper function takes a url, executes the get! function from HTTPoison on it and decodes the response.
  """
	defp get(url) do
		# Error handling with HTTPoison is really simple:
		# We just execute the request and pattern match the tagged response
		case HTTPoison.get(url) do
			# In case the tag is :ok and the response is a HTTPoison.Response map with status_code set to 200, 
			# this matches and we can directly extract the body and inspect it
			{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
				# resp.status_code |> IO.inspect
				body |> Poison.decode!

			# In case the tag is :error and the response is a HTTPoison.Error map,
			# this matches and we simply extract the reason and inspect it
			{:error, %HTTPoison.Error{reason: reason}} ->
				reason |> IO.inspect
		end
	end

	defp base_url, do: "#{@goodbag_public_url}/public/v1/branches"

end