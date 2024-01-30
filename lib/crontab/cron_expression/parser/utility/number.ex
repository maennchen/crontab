defmodule Crontab.CronExpression.Parser.Utility.Number do
  @moduledoc false

  import NimbleParsec

  def to_number(rest, [number, :negative], context, line, offset, min, max),
    do: to_number(rest, [0 - number], context, line, offset, min, max)

  def to_number(_rest, [number], context, _line, _offset, min, max)
      when number >= min and number <= max,
      do: {[number], context}

  def to_number(_rest, [number], _context, _line, _offset, min, max),
    do: {:error, "number #{number} must be between #{min} and #{max}"}

  def number(min, max) do
    "-"
    |> string()
    |> replace(:negative)
    |> optional
    |> concat(integer(min: 1))
    |> post_traverse({__MODULE__, :to_number, [min, max]})
    |> label("number (#{min} - #{max})")
  end
end
