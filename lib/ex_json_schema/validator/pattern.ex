defmodule ExJsonSchema.Validator.Pattern do
  @moduledoc """
  `ExJsonSchema.Validator` implementation for `"pattern"` attributes.

  See:

  """

  alias ExJsonSchema.Validator.Error

  @behaviour ExJsonSchema.Validator

  @impl ExJsonSchema.Validator
  def validate(_, _, {"pattern", pattern}, data, _) do
    do_validate(pattern, data)
  end

  def validate(_, _, _, _, _) do
    []
  end

  defp do_validate(pattern, data) when is_bitstring(data) do
    matches? =
      pattern
      |> convert_regex()
      |> Regex.compile!()
      |> Regex.match?(data)

    if matches? do
      []
    else
      [%Error{error: %Error.Pattern{expected: pattern}}]
    end
  end

  defp do_validate(_, _) do
    []
  end

  @doc """
  Converts ECMAScript style regexes to PCRE (for BEAM compatibility).
  Currently supports `\\u` with 4 byte hex codes.
  """
  def convert_regex(r) do
    r
    |> String.replace(~r/\\u([A-F0-9]{4})/, "\\x\{\\g{1}\}")
  end
end
