defmodule Crontab.CronExpression.Parser.Minute do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range

  defp minute_range_base,
    do:
      choice([
        range(number(0, 59)),
        everything()
      ])

  defp minute_base,
    do:
      choice([
        minute_range_base(),
        number(0, 59)
      ])

  defp minute,
    do:
      choice([
        divider(minute_range_base(), number(1, 60)),
        minute_base()
      ])

  def parser, do: list(minute())
end
