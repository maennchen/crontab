defmodule Crontab.CronExpression.Parser.Utility.Divider do
  @moduledoc false

  import NimbleParsec

  def to_divider(_rest, [divider: [base, divider]], context, _line, _offset),
    do: {[{:/, base, divider}], context}

  def divider(base, dividend \\ integer(min: 1)) do
    base
    |> ignore(string("/"))
    |> concat(dividend)
    |> tag(:divider)
    |> label("divider (X/Y)")
    |> post_traverse({__MODULE__, :to_divider, []})
  end
end
