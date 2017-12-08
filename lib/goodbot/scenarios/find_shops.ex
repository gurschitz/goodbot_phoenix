defmodule Goodbot.Scenarios.FindShops do
  @moduledoc """
  This module defines a scenario that basically sets the logic that 
  should happen given specific params
  """
  
  # We alias the Templates module as well as the Apis module, 
  # so that we don't have to write so much later
	alias Goodbot.Templates
	alias Goodbot.Apis

  @doc """
  This function runs the scenario by taking a Map with lat and long properties as well as the state
  It uses the latitude and the longitude then to call the Goodbag Branches API Wrapper 
  to get all branches near those coordinates. Finally, the result is turned into a 
  generic template and then sent using the Facebook Messages Api Endpoint
  """
	def run(%{"lat" => lat, "long" => long}, state) do
		case Apis.Goodbag.Branches.get_all(lat, long) do
      :connect_timeout -> IO.puts "A timeout is happening"
      :timeout -> IO.puts "A timeout is happening"
      result -> 
        result
        |> build_generic_template_message
        |> Apis.Facebook.Messages.send(state.psid)
    end
	end

  @doc """
  This helper function gets the goodbot public url and uses URI.parse on it so we get a URI Map
  """
  defp goodbot_public_uri, do: Application.get_env(:goodbot, :goodbot)[:public_url] |> URI.parse

  @doc """
  This function builds message containing a generic template with the shops
  """
  defp build_generic_template_message(shops) do
  	elements = shops
  	|> Enum.map(&(map_shop_to_generic_element(&1)))
    generic_template = %Templates.GenericTemplate{elements: elements}
  	attachment = %Templates.Attachment{type: "template", payload: generic_template}
    %{attachment: attachment}
  end

  @doc """
  This helper function builds an element for a generic template out of a single shop
  """
  defp map_shop_to_generic_element(%{"id" => id, "name" => title, "logo_url" => %{"url" => image_url}, "discount_en" => subtitle}) do
    button_url = GoodbotWeb.Router.Helpers.shop_url(goodbot_public_uri(), :show, id)
  	button = %Templates.WebUrlButton{title: "Show", url: button_url}

    %Templates.GenericTemplateElement{
      title: title,
      image_url: image_url,
      subtitle: subtitle,
      buttons: [button]
    }
  end

end