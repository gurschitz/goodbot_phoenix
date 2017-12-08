defmodule Goodbot.Templates.WebUrlButton do
  @moduledoc """
  This module defines web url button struct with 
  the required fields title and url, as well 
  as a type field that is set to "web_url".
  """
  @enforce_keys [:title, :url]
  defstruct type: "web_url", title: nil, url: nil
end