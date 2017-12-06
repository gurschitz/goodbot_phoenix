defmodule GoodbotWeb.ShopView do
  use GoodbotWeb, :view
  @moduledoc """
  The functions in this module simply extract the variables that 
  we want to render out of the corresponding shop.
  """ 

  @doc """
	This function extracts the url of the logo_url of the shop.
  """
  def logo_url(shop), do: shop["logo_url"]["url"]

  @doc """
	This function extracts the name of the shop.
  """
  def name(shop), do: shop["name"]

  @doc """
	This function extracts the discount of the shop.
  """
  def discount(shop), do: shop["discount_en"]

end
