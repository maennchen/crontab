defmodule Crontab.CronExpression.Parser do
  @moduledoc """
  Parse string like `* * * * * *` to a `%Crontab.CronExpression{}`.
  """

  import NimbleParsec

  import Crontab.CronExpression.Parser.Utility.List

  alias Crontab.CronExpression

  defmodule ParseError do
    @moduledoc """
    Parsing of cron expression failed
    """

    defexception [:message, :rest, :column]
  end

  @type result :: {:ok, CronExpression.t()} | {:error, binary}

  defcombinatorp(:second_expression, __MODULE__.Second.parser())
  defcombinatorp(:minute_expression, __MODULE__.Minute.parser())
  defcombinatorp(:hour_expression, __MODULE__.Hour.parser())
  defcombinatorp(:day_expression, __MODULE__.Day.parser())
  defcombinatorp(:month_expression, __MODULE__.Month.parser())
  defcombinatorp(:weekday_expression, __MODULE__.Weekday.parser())
  defcombinatorp(:year_expression, __MODULE__.Year.parser())

  defcombinatorp(
    :special,
    string("@")
    |> ignore()
    |> concat(
      choice([
        string("reboot") |> replace(:reboot),
        string("REBOOT") |> replace(:reboot),
        string("yearly") |> replace(:yearly),
        string("YEARLY") |> replace(:yearly),
        string("annually") |> replace(:annually),
        string("ANNUALLY") |> replace(:annually),
        string("monthly") |> replace(:monthly),
        string("MONTHLY") |> replace(:monthly),
        string("weekly") |> replace(:weekly),
        string("WEEKLY") |> replace(:weekly),
        string("daily") |> replace(:daily),
        string("DAILY") |> replace(:daily),
        string("midnight") |> replace(:midnight),
        string("MIDNIGHT") |> replace(:midnight),
        string("hourly") |> replace(:hourly),
        string("HOURLY") |> replace(:hourly),
        string("minutely") |> replace(:minutely),
        string("MINUTELY") |> replace(:minutely),
        string("secondly") |> replace(:secondly),
        string("SECONDLY") |> replace(:secondly)
      ])
    )
    |> concat(eos())
  )

  defcombinatorp(
    :cron_expression,
    concat(
      choice([
        parsec(:special),
        space_list([
          parsec(:minute_expression) |> tag(:minute),
          parsec(:hour_expression) |> tag(:hour),
          parsec(:day_expression) |> tag(:day),
          parsec(:month_expression) |> tag(:month),
          parsec(:weekday_expression) |> tag(:weekday),
          parsec(:year_expression) |> tag(:year)
        ])
      ]),
      eos()
    )
  )

  defcombinatorp(
    :extended_cron_expression,
    concat(
      choice([
        parsec(:special),
        space_list([
          parsec(:second_expression) |> tag(:second),
          parsec(:minute_expression) |> tag(:minute),
          parsec(:hour_expression) |> tag(:hour),
          parsec(:day_expression) |> tag(:day),
          parsec(:month_expression) |> tag(:month),
          parsec(:weekday_expression) |> tag(:weekday),
          parsec(:year_expression) |> tag(:year)
        ])
      ]),
      eos()
    )
  )

  defparsecp(:parse_expression, parsec(:cron_expression))

  defparsecp(:parse_extended_expression, parsec(:extended_cron_expression))

  def parse(string, extended \\ false)

  def parse(input, true) do
    input
    |> parse_extended_expression
    |> response(true)
  end

  def parse(input, false) do
    input
    |> parse_expression
    |> response(false)
  end

  def parse!(input, extended \\ false) do
    case parse(input, extended) do
      {:ok, cron_expression} -> cron_expression
      {:error, message} -> raise message
    end
  end

  defp response({:ok, parsed, "", _context, _line, _column}, extended),
    do: {:ok, CronExpression.from_parsec(parsed, extended)}

  defp response({:error, message, rest, _context, _line, column}, _extended),
    do: {:error, %ParseError{message: message, rest: rest, column: column}}
end
