defmodule Crontab.CronExpression.Parser.Year do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Range

  defp year_range_base,
    do:
      choice([
        range(integer(min: 1)),
        everything()
      ])

  defp year_base,
    do:
      choice([
        year_range_base(),
        integer(min: 1)
      ])

  defp year,
    do:
      choice([
        divider(year_range_base()),
        year_base()
      ])

  def parser, do: list(year())
end
