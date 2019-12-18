defmodule Crontab.CronExpression.Parser.Weekday do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.DayOfTheWeek
  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.Last
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range

  defp weekday_range_base,
    do:
      choice([
        range(
          choice([
            string("MON") |> replace(1),
            string("TUE") |> replace(2),
            string("WED") |> replace(3),
            string("THU") |> replace(4),
            string("FRI") |> replace(5),
            string("SAT") |> replace(6),
            string("SUN") |> replace(7),
            number(0, 7)
          ])
        ),
        everything()
      ])

  defp weekday_base,
    do:
      choice([
        weekday_range_base(),
        string("MON") |> replace(1),
        string("TUE") |> replace(2),
        string("WED") |> replace(3),
        string("THU") |> replace(4),
        string("FRI") |> replace(5),
        string("SAT") |> replace(6),
        string("SUN") |> replace(7),
        number(0, 7)
      ])

  defp weekday,
    do:
      choice([
        divider(weekday_range_base(), number(1, 7)),
        last(weekday_base()),
        day_of_the_week(weekday_base()),
        weekday_base()
      ])

  def parser, do: list(weekday())
end
