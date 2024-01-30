defmodule Crontab.CronExpression.Parser.Month do
  @moduledoc false

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.Divider
  import Crontab.CronExpression.Parser.Utility.Everything
  import Crontab.CronExpression.Parser.Utility.Last
  import Crontab.CronExpression.Parser.Utility.List
  import Crontab.CronExpression.Parser.Utility.Number
  import Crontab.CronExpression.Parser.Utility.Range

  defp month_range_base,
    do:
      choice([
        range(
          choice([
            string("JAN") |> replace(1),
            string("FEB") |> replace(2),
            string("MAR") |> replace(3),
            string("APR") |> replace(4),
            string("MAY") |> replace(5),
            string("JUN") |> replace(6),
            string("JUL") |> replace(7),
            string("AUG") |> replace(8),
            string("SEP") |> replace(9),
            string("OCT") |> replace(10),
            string("NOV") |> replace(11),
            string("DEC") |> replace(12),
            number(1, 12)
          ])
        ),
        everything()
      ])

  defp month_base,
    do:
      choice([
        month_range_base(),
        string("JAN") |> replace(1),
        string("FEB") |> replace(2),
        string("MAR") |> replace(3),
        string("APR") |> replace(4),
        string("MAY") |> replace(5),
        string("JUN") |> replace(6),
        string("JUL") |> replace(7),
        string("AUG") |> replace(8),
        string("SEP") |> replace(9),
        string("OCT") |> replace(10),
        string("NOV") |> replace(11),
        string("DEC") |> replace(12),
        number(1, 12)
      ])

  defp month,
    do:
      choice([
        divider(month_range_base(), number(1, 12)),
        last(month_base()),
        month_base()
      ])

  def parser, do: list(month())
end
