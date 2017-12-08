defmodule Goodbot.Templates.GenericTemplateElement do
  @moduledoc """
  This module defines an generic template element struct with 
  the required field title and the optional field image_url,
  subtitle and buttons (which defaults to an empty array).
  """
  @enforce_keys [:title]
  defstruct title: nil, image_url: nil, subtitle: nil, buttons: []
end