defmodule Goodbot.Templates.Attachment do
  @moduledoc """
  This module defines an attachment struct with the fields 
  type and payload, which are required.
  """
  @enforce_keys [:type, :payload]
  defstruct [:type, :payload]
end