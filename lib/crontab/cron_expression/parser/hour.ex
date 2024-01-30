defmodule Crontab.CronExpression.Parser.Hour do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range

  defp hour_range_base,
    do:
      choice([
        range(number(0, 23)),
        everything()
      ])

  defp hour_base,
    do:
      choice([
        hour_range_base(),
        number(0, 23)
      ])

  defp hour,
    do:
      choice([
        divider(hour_range_base(), number(1, 24)),
        hour_base()
      ])

  def parser, do: list(hour())
end
