defmodule Crontab.CronExpression.Parser.Utility.DayOfTheWeek do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Number

  def to_day_of_the_week(_rest, [nth, :"#", base], context, _line, _offset),
    do: {[{:"#", base, nth}], context}

  def day_of_the_week(base) do
    base
    |> concat(string("#") |> replace(:"#"))
    |> concat(number(1, 5))
    |> label("day of week (X#Y)")
    |> post_traverse({__MODULE__, :to_day_of_the_week, []})
  end
end
