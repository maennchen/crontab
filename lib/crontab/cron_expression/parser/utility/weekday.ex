defmodule Crontab.CronExpression.Parser.Utility.Weekday do
  @moduledoc false

  import NimbleParsec

  def to_weekday(_rest, [:W], context, _line, _offset), do: {[:W], context}
  def to_weekday(_rest, [:W, base], context, _line, _offset), do: {[{:W, base}], context}

  def weekday(base) do
    base
    |> optional
    |> concat(string("W") |> replace(:W))
    |> label("weekday (W)")
    |> post_traverse({__MODULE__, :to_weekday, []})
  end
end
