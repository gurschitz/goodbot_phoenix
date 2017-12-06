defmodule GoodbotWeb.Parsers.JSON_WITH_VALIDATION do
  @moduledoc """
  This module will read the body from request connection, validate the request using the given options if applicable
  and decode the body using Poison, transforming the JSON to an elixir map.

  This module implements the Plug.Parsers behaviour. 
  See https://github.com/elixir-plug/plug/blob/master/lib/plug/parsers.ex 
  """

  @behaviour Plug.Parsers
  import Plug.Conn

  @doc """
  This function implements the parse function following the Plug.Parsers behaviour.
  It takes 5 arguments and in this case, the clause signature is pattern matching 
  the type argument to "application" and subtype argument to "json".
  """
  def parse(conn, "application", "json", _headers, opts) do
    # We need to extract the validate_request_path from the options
    # This will be the path that we validate the request for.
    validate_request_path = opts[:validate_request_path]

    case read_body(conn, opts) do

      {:ok, body, %Plug.Conn{request_path: ^validate_request_path}} ->
        # First we extract the passed signature from the signature header field
        passed_signature = extract_passed_signature(conn, opts)

        # Then we check if the raw body is validated with the passed signature
        # Note that valid will be ALWAYS false if the passed_signature is nil 
        valid = signature_valid?(body, passed_signature, opts)

        # We need to put the result of the validation into the private field of conn
        # so we can use that later in the controller. put_priate is a function of
        # Plug.Conn and it returns the modified conn, which we can pipe to the decode function
        put_private(conn, :valid, valid)
        |> decode(body)
      {:ok, body, conn} -> decode(conn, body)
      # If read_body returnes more, it means that the passed body is too large
      # In this case we return this error
      {:more, _body, conn} -> {:error, :too_large, conn}
    end
  end

  @doc """
  This fallback function will return {:next, conn} so that the next parser is invoked.
  """
  def parse(conn, _type, _subtype, _headers, _opts), do: {:next, conn}

  @doc """
  In this function, the body is simply decoded using Poison and the result put in a tagged tuple 
  according to the Plug.Parsers behaviour specification.
  """
  defp decode(conn, body), do: {:ok, Poison.decode!(body), conn}

  @doc """
  This function extracts the passed signature from the x-hub-signature header
  """
  defp extract_passed_signature(conn, opts) do
    # we need to get the header out of the conn using the Plug.Conn function get_req_header
    # and the given signature_header_field, which can be passed when plugging the Plug.Parsers module in endpoint.ex
    case get_req_header(conn, opts[:signature_header_field]) do
      # Using list pattern matching we can extract the head (= first element) of the header list
      [passed_signature | _] -> passed_signature

      # if there's no match, we return nil
      _ -> nil
    end
  end

  @doc """
  This function checks if the signature of the body is validated with the given passed_signature and 
  according to the secret and prefix that are passed in the options.
  The secret and the prefix options are set when plugging Plug.Parsers in in endpoint.ex
  """
  defp signature_valid?(body, passed_signature, opts) do

    # then we calculate the signature based on the conn and on the secret that was passed to the option
    calculated_signature = hmac_sha1_body(body, opts[:secret])

    # we check if there's any prefix to append to the string
    # (Facebook always has "sha1=" - this should be passed as an option to this plug)
    prefix = cond do
      Keyword.has_key?(opts, :prefix) -> opts[:prefix]
      true -> ""
    end

    # Finally we check if the calculated_signature including the prefix equals the passed signature
    case ~s(#{prefix}#{calculated_signature})  do

      # We need to pin the passed_signature variable as otherwise 
      # the case value would be bound to it
      ^passed_signature ->
        true

      # If there's no match, we just return false
      _ -> 
        false
    end
  end

  @doc """
  This helper function actually does the hmac hashing by taking the raw body
  as well as a given secret, calculating the sha1 hmac using the :crypto library of erlang,
  then Base encoding and downcasing the result
  """
  defp hmac_sha1_body(body, secret) do
    :crypto.hmac(:sha, secret, body) 
    |> Base.encode16 
    |> String.downcase
  end 
end