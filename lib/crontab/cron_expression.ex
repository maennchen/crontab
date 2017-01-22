defmodule Crontab.CronExpression do
  @moduledoc """
  This is the Crontab.CronExpression module / struct.
  """

  alias Crontab.CronExpression.Parser

  @type t :: %Crontab.CronExpression{
    extended: boolean,
    reboot: boolean,
    second: [value],
    minute: [value],
    hour: [value],
    day: [value],
    month: [value],
    weekday: [value],
    year: [value]
  }
  @type interval :: :second | :minute | :hour | :day | :month | :weekday | :year
  @type min_max :: {:-, time_unit, time_unit}
  @type value :: time_unit | :* | :L | {:L, value} | {:/, time_unit | :*
    | min_max, pos_integer} | min_max | {:W, time_unit | :L}
  @type minute :: 0..59
  @type hour :: 0..23
  @type day :: 0..31
  @type month :: 1..12
  @type weekday :: 0..7
  @type year :: integer
  @type time_unit :: minute | hour | day | month | weekday | year
  @type condition :: {interval, [value]}
  @type condition_list :: [condition]

  @doc """
  Defines the Cron Interval

      * * * * * * *
      | | | | | | |
      | | | | | | +-- :year Year                 (range: 1900-3000)
      | | | | | +---- :weekday Day of the Week   (range: 1-7, 1 standing for Monday)
      | | | | +------ :month Month of the Year   (range: 1-12)
      | | | +-------- :day Day of the Month      (range: 1-31)
      | | +---------- :hour Hour                 (range: 0-23)
      | +------------ :minute Minute             (range: 0-59)
      +-------------- :second Second             (range: 0-59)

  The :extended attribute defines if the second is taken into account.
  """
  defstruct extended: false, reboot: false, second: [:*], minute: [:*], hour: [:*], day: [:*], month: [:*],
    weekday: [:*], year: [:*]

  @doc """
  Create a `%Crontab.CronExpression{}` via sigil.

  ### Examples

      iex> ~e[*]
      %Crontab.CronExpression{
        extended: false,
        second: [:*],
        minute: [:*],
        hour: [:*],
        day: [:*],
        month: [:*],
        weekday: [:*],
        year: [:*]}

      iex> ~e[*]e
      %Crontab.CronExpression{
        extended: true,
        second: [:*],
        minute: [:*],
        hour: [:*],
        day: [:*],
        month: [:*],
        weekday: [:*],
        year: [:*]}

      iex> ~e[1 2 3 4 5 6 7]e
      %Crontab.CronExpression{
        extended: true,
        second: [1],
        minute: [2],
        hour: [3],
        day: [4],
        month: [5],
        weekday: [6],
        year: [7]}
  """
  @spec sigil_e(binary, charlist) :: t
  def sigil_e(cron_expression, options)
  def sigil_e(cron_expression, [?e]), do: Parser.parse!(cron_expression, true)
  def sigil_e(cron_expression, _options), do: Parser.parse!(cron_expression, false)

  @doc """
  Convert Crontab.CronExpression struct to Tuple List

  ### Examples

      iex> Crontab.CronExpression.to_condition_list %Crontab.CronExpression{
      ...> minute: [1], hour: [2], day: [3], month: [4], weekday: [5], year: [6]}
      [ {:minute, [1]},
        {:hour, [2]},
        {:day, [3]},
        {:month, [4]},
        {:weekday, [5]},
        {:year, [6]}]

      iex> Crontab.CronExpression.to_condition_list %Crontab.CronExpression{
      ...> extended: true, second: [0], minute: [1], hour: [2], day: [3], month: [4], weekday: [5], year: [6]}
      [ {:second, [0]},
        {:minute, [1]},
        {:hour, [2]},
        {:day, [3]},
        {:month, [4]},
        {:weekday, [5]},
        {:year, [6]}]
  """
  @spec to_condition_list(t) :: condition_list
  def to_condition_list(interval = %__struct__{extended: false}) do
    [{:minute, interval.minute},
     {:hour, interval.hour},
     {:day, interval.day},
     {:month, interval.month},
     {:weekday, interval.weekday},
     {:year, interval.year}]
  end
  def to_condition_list(interval = %__struct__{}) do
    [{:second, interval.second} | to_condition_list(%{interval | extended: false})]
  end

  defimpl Inspect do
    alias Crontab.CronExpression.Composer
    alias Crontab.CronExpression

    @doc """
    Pretty Print Cron Expressions

    ### Examples:

        iex> IO.inspect %Crontab.CronExpression{}
        ~e[* * * * * *]

        iex> import Crontab.CronExpression
        iex> IO.inspect %Crontab.CronExpression{extended: true}
        ~e[* * * * * * *]e

    """
    @spec inspect(CronExpression.t, any) :: String.t
    def inspect(cron_expression = %__struct__{extended: false}, _options) do
      "~e[" <> Composer.compose(cron_expression) <> "]"
    end
    def inspect(cron_expression = %__struct__{extended: true}, _options) do
      "~e[" <> Composer.compose(cron_expression) <> "]e"
    end
  end
end
