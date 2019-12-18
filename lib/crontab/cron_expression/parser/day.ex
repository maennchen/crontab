defmodule Crontab.CronExpression.Parser.Day do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.Last
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range
  import Crontab.CronExpression.Parser.Utility.Weekday

  defp day_range_base,
    do:
      choice([
        range(number(1, 31)),
        everything()
      ])

  defp day_base,
    do:
      choice([
        day_range_base(),
        number(1, 31)
      ])

  defp day,
    do:
      choice([
        divider(day_range_base(), number(1, 31)),
        weekday(
          choice([
            last(day_base()),
            day_base()
          ])
        ),
        last(day_base()),
        day_base()
      ])

  def parser, do: list(day())
end
