defmodule Goodbot.Templates do
  @moduledoc """
  In this module, a couple of functions are defined 
  to build the template objects that we need for the Facebook Send API
  """
  
  @doc """
  This function builds a basic attachment map
  """
  def build(:attachment, attachment = %{type: _, payload: _}), do: %{attachment: attachment}

  @doc """
  With this function, we can build an attachment of type "template" with a given payload.
  """
  def build(:template_attachment, payload) do
  	build(:attachment, %{type: "template", payload: payload})
  end

  @doc """
  With this function, we can build the template for a "generic" template using the given elements.
  """
  def build(:generic_template, elements) do
  	payload = %{template_type: "generic", elements: elements}
  	build(:template_attachment, payload)
  end

  @doc """
  This functions helps to build a generic element that will be used for the generic template.
  """
  def build(:generic_element, options) do
  	%{
	  	title: nil,
	  	image_url: nil,
	  	subtitle: nil,
	  	buttons: []
	  }	|> Map.merge(options)
  end

  @doc """
  This functions helps to build a button of the type "web_url".
  """
  def build(:web_url_button, options = %{url: _, title: _}) do
  	%{
	  	type: "web_url",
	  	url: nil,
	  	title: nil
	  }	|> Map.merge(options)
  end

end