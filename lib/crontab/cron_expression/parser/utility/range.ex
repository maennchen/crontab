defmodule Crontab.CronExpression.Parser.Utility.Range do
  @moduledoc false

  import NimbleParsec

  def to_range(_rest, [range: [from, to]], context, _line, _offset),
    do: {[{:-, from, to}], context}

  def range(base) do
    base
    |> ignore(string("-"))
    |> concat(base)
    |> tag(:range)
    |> label("range (X-Y)")
    |> post_traverse({__MODULE__, :to_range, []})
  end
end
