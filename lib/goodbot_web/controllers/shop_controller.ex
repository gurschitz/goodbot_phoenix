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

 		# we pass the name of the shop as page_title as well as the shop itself
    render conn, page_title: shop["name"], shop: shop
  end
end
