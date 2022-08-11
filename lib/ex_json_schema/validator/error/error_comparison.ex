defmodule ExJsonSchema.Validator.Error.ErrorComparison do
  alias ExJsonSchema.Validator.Error

  @spec closest_match([{[Error.t()], integer()}]) :: Error.t()
  def closest_match(errors_with_index) do
    {_, {errors, index}} =
      Enum.reduce(errors_with_index, {0, nil}, fn {errors, index}, {score, closest_match} ->
        current_score =
          Enum.reduce(errors, 0, fn error, acc ->
            case error do
              %Error.Required{missing: missing} ->
                acc - Enum.count(missing)

              %Error.Dependencies{missing: missing} ->
                acc - Enum.count(missing)

              _ ->
                acc - 1
            end
          end)

        if current_score < score do
          {current_score, {errors, index}}
        else
          {score, closest_match}
        end
      end)

    {errors, index}
  end
end
