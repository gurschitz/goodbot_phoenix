defmodule Goodbot.Templates.GenericTemplate do
  @moduledoc """
  This module defines an generic template struct with the fields template_type 
  (that is set by default) and the elements.
  """
  @enforce_keys [:elements]
  defstruct template_type: "generic", elements: nil
end