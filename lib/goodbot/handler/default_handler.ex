defmodule Goodbot.Handler.DefaultHandler do
	@moduledoc """
  This module defines a macro for defining a hanlder fallback.
  """

	@doc """
	This macro defines a fallback function that will be called if we get any input that we don't handle yet.
	It can be included using @before_compile in any handler module, so that it will be defined at the very end
	of the module and therefore act as a fallback function in the respective module
  """
	defmacro __before_compile__(_opts) do
    quote do
			def handle(arg,_) do
				IO.puts "handler not implemented for the following:"
				IO.inspect arg
			end
    end
  end

end