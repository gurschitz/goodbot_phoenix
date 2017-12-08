defmodule GoodbotWeb.ShopController do
	@moduledoc """
  This controller takes care of retrieving and rendering a single shop to the view.
  """
  
  use GoodbotWeb, :controller
	alias Goodbot.Apis

	@doc """
  This function extracts the id out of the params using pattern matching,
  fetches the shop using this id and and calls render on the connection with the respective params
  """
  def show(conn, %{"id" => id}) do
  	# Using our Goodbag API Wrapper, we can get a single shop by passing the id
 		shop = Apis.Goodbag.Branches.get_one(id) 

    IO.inspect shop
 		# we pass the name of the shop as page_title as well as the shop itself
    render conn, page_title: shop["name"], shop: shop
  end

  def test(conn, _) do
    shop = %{
              "address" => "Wollzeile 4", "category" => "3", "city" => "Wien",
              "country" => "Österreich", "country_code" => "AT", "description_de" => nil,
              "description_en" => nil, "discount_de" => nil, "discount_en" => nil,
              "facebook" => "https://www.facebook.com/theehandlung.schoenbichler",
              "geo_lat" => "48.208942", "geo_lng" => "16.374571", "id" => 41,
              "instagram" => nil, "is_visible" => true,
              "logo_url" => %{
                "icon" => %{"url" => "https://www.goodbag.io/uploads/logos/71/icon_logo.png"},
                "url" => "https://www.goodbag.io/uploads/logos/71/logo.png"
              },
              "name" => "Theehandel Schönbichler",
              "opening_hours_de" => "Mo. – Fr.: 09:00 - 18:30 Uhr,\\n Sa.: 09:00 - 17:00 Uhr,\\n So.: geschlossen",
              "opening_hours_en" => "Mon - Fri: 09:00 - 18:30 \\n Sat: 09:00 - 17:00,\\n Sun: closed",
              "phone" => nil, "postcode" => "1010", "snapchat" => nil,
              "sponsored_trees_amount" => 15, "t_updated" => "2017-11-25T15:42:31Z",
              "twitter" => nil, "website" => "http://www.schoenbichler.at"
            }

    render conn, "show.html", page_title: shop["name"], shop: shop
  end

end
