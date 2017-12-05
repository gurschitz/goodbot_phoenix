defmodule GoodbotWeb.Parsers.JSON_WITH_VERIFICATION do
  @moduledoc """
  This module will read the body from request connection, verify the request using the given options if applicable
  and decode the body using Poison, transforming the JSON to an elixir map.

  This module implements the Plug.Parsers behaviour. 
  See https://github.com/elixir-plug/plug/blob/master/lib/plug/parsers.ex 
  """

  @behaviour Plug.Parsers
  import Plug.Conn

  @doc """
  This method implements the parse method following the Plug.Parsers behaviour.
  It takes 5 arguments and in this case we're pattern matching type "application" and subtype "json".
  """
  def parse(conn, "application", "json", _headers, opts) do

    # We need to extract the verify_request_path from the options
    # This will be the path that we verify the request for.
    verify_request_path = opts[:verify_request_path]

    case read_body(conn, opts) do

      {:ok, body, %Plug.Conn{request_path: ^verify_request_path}} ->
        # First we extract the passed signature from the signature header field
        passed_signature = extract_passed_signature(conn, opts)

        # Then we check if the raw body is verified with the passed signature
        # Note that verified will be ALWAYS false if the passed_signature is nil 
        verified = signature_verified?(body, passed_signature, opts)

        # We need to put the result of the verification into the private field of conn
        # so we can use that later in the controller. put_priate is a method of
        # Plug.Conn and it returns the modified conn, which we can pipe to the decode method
        put_private(conn, :verified, verified)
        |> decode(body)
      {:ok, body, conn} -> decode(conn, body)
      # If read_body returnes more, it means that the passed body is too large
      # In this case we return this error
      {:more, _body, conn} -> {:error, :too_large, conn}
    end
  end

  @doc """
  This fallback method will return {:next, conn} so that the next parser is invoked.
  """
  def parse(conn, _type, _subtype, _headers, _opts), do: {:next, conn}

  @doc """
  In this method, the body is simply decoded using Poison and the result put in a tagged tuple 
  according to the Plug.Parsers behaviour specification.
  """
  defp decode(conn, body), do: {:ok, Poison.decode!(body), conn}

  @doc """
  This method extracts the passed signature from the x-hub-signature header
  """
  defp extract_passed_signature(conn, opts) do
    # we need to get the header out of the conn using the Plug.Conn method get_req_header
    # and the given signature_header_field, which can be passed when plugging the Plug.Parsers module in endpoint.ex
    case get_req_header(conn, opts[:signature_header_field]) do
      # Using list pattern matching we can extract the head (= first element) of the header list
      [passed_signature | _] -> passed_signature

      # if there's no match, we return nil
      _ -> nil
    end
  end

  @doc """
  This method checks if the signature of the body is verified with the given passed_signature and 
  according to the secret and prefix that are passed in the options.
  The secret and the prefix options are set when plugging Plug.Parsers in in endpoint.ex
  """
  defp signature_verified?(body, passed_signature, opts) do

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
  This helper method actually does the hmac hashing by taking the raw body
  as well as a given secret, calculating the sha1 hmac using the :crypto library of erlang,
  then Base encoding and downcasing the result
  """
  defp hmac_sha1_body(body, secret) do
    :crypto.hmac(:sha, secret, body) 
    |> Base.encode16 
    |> String.downcase
  end 
end