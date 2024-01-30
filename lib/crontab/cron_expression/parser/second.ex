defmodule Crontab.CronExpression.Parser.Second do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range

  defp second_range_base,
    do:
      choice([
        range(number(0, 59)),
        everything()
      ])

  defp second_base,
    do:
      choice([
        second_range_base(),
        number(0, 59)
      ])

  defp second,
    do:
      choice([
        divider(second_range_base(), number(1, 60)),
        second_base()
      ])

  def parser, do: list(second())
end
