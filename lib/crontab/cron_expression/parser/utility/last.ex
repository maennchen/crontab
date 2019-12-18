defmodule Crontab.CronExpression.Parser.Utility.Last do
  @moduledoc false

  import NimbleParsec

  def to_last(_rest, [:L], context, _line, _offset), do: {[:L], context}
  def to_last(_rest, [:L, base], context, _line, _offset), do: {[{:L, base}], context}

  def last(base) do
    base
    |> optional
    |> concat(string("L") |> replace(:L))
    |> label("last (L)")
    |> post_traverse({__MODULE__, :to_last, []})
  end
end
