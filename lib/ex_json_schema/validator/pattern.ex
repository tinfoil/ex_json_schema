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

  defmodule RegexParsec do
    import NimbleParsec

    unicode_escape =
      string("u")
      |> ascii_string([?0..?9, ?a..?z, ?A..?Z], 4)
      |> reduce({:to_pcre, []})

    escape_sequence =
      string("\\")
      |> choice([
        unicode_escape,
        utf8_char([])
      ])

    non_escape_sequence = ascii_string([{:not, ?\\}], min: 1)

    defp to_pcre(["u", bytes]) do
      "x{#{bytes}}"
    end

    defparsec(
      :from_emcascript_regex,
      repeat(choice([escape_sequence, non_escape_sequence])) |> reduce({List, :to_string, []})
    )
  end

  @doc """
  Converts ECMAScript style regexes to PCRE (for BEAM compatibility).
  Currently supports `\\u` with 4 byte hex codes.
  """
  def convert_regex(r) do
    {:ok, [result], _, _, _, _} = RegexParsec.from_emcascript_regex(r)

    result
  end
end
