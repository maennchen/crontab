defmodule Crontab.CronExpression do
  @moduledoc """
  The `Crontab.CronExpression` module / struct.
  """

  alias Crontab.CronExpression.Parser

  @type t :: %Crontab.CronExpression{
          extended: boolean,
          reboot: boolean,
          on_ambiguity: [ambiguity_opt],
          second: [value(second)],
          minute: [value(minute)],
          hour: [value(hour)],
          day: [value(day)],
          month: [value(month)],
          weekday: [value(weekday)],
          year: [value(year)]
        }

  @type ambiguity_opt :: :earlier | :later

  @type interval :: :second | :minute | :hour | :day | :month | :weekday | :year

  @typedoc deprecated: "Use Crontab.CronExpression.min_max/1 instead"
  @type min_max :: {:-, time_unit, time_unit}
  @type min_max(time_unit) :: {:-, time_unit, time_unit}

  @type value ::
          value(Calendar.second())
          | value(Calendar.minute())
          | value(Calendar.hour())
          | value(Calendar.day())
          | value(Calendar.month())
          | value(Calendar.day_of_week())
          | value(Calendar.year())

  @type value(time_unit) ::
          time_unit
          | :*
          | :L
          | {:L, value(time_unit)}
          | {:/,
             time_unit
             | :*
             | min_max(time_unit), pos_integer}
          | min_max(time_unit)
          | {:W, time_unit | :L}
          | {:"#", time_unit, pos_integer}

  @typedoc deprecated: "Use Calendar.second/0 instead"
  @type second :: Calendar.second()
  @typedoc deprecated: "Use Calendar.minute/0 instead"
  @type minute :: Calendar.minute()
  @typedoc deprecated: "Use Calendar.hour/0 instead"
  @type hour :: Calendar.hour()
  @typedoc deprecated: "Use Calendar.day/0 instead"
  @type day :: Calendar.day()
  @typedoc deprecated: "Use Calendar.month/0 instead"
  @type month :: Calendar.month()
  @typedoc deprecated: "Use Calendar.day_of_week/0 instead"
  @type weekday :: Calendar.day_of_week()
  @typedoc deprecated: "Use Calendar.year/0 instead"
  @type year :: Calendar.year()

  @typedoc deprecated: "Use Calendar.[second|minute|hour|day|month|day_of_week|year]/0 instead"
  @type time_unit :: second | minute | hour | day | month | weekday | year

  @type condition(name, time_unit) :: {name, [value(time_unit)]}
  @type condition ::
          condition(:second, Calendar.second())
          | condition(:minute, Calendar.minute())
          | condition(:hour, Calendar.hour())
          | condition(:day, Calendar.day())
          | condition(:month, Calendar.month())
          | condition(:weekday, Calendar.day_of_week())
          | condition(:year, Calendar.year())

  @type condition_list :: [condition]

  @doc """
  Defines the Cron interval.

      * * * * * * *
      | | | | | | |
      | | | | | | +-- :year Year                 (range: 1900-3000)
      | | | | | +---- :weekday Day of the Week   (range: 1-7, 1 standing for Monday)
      | | | | +------ :month Month of the Year   (range: 1-12)
      | | | +-------- :day Day of the Month      (range: 1-31)
      | | +---------- :hour Hour                 (range: 0-23)
      | +------------ :minute Minute             (range: 0-59)
      +-------------- :second Second             (range: 0-59)

  The `:extended` attribute defines if the second is taken into account.
  When using localized DateTime, the `:on_ambiguity` attribute defines
  whether the scheduler should return the earlier or later time when
  the next run DateTime is ambiguous. `:on_ambiguity` defaults to `[:later]`.
  To run on both, set it as `[:earlier, :later]`.
  """
  defstruct extended: false,
            reboot: false,
            on_ambiguity: [:later],
            second: [:*],
            minute: [:*],
            hour: [:*],
            day: [:*],
            month: [:*],
            weekday: [:*],
            year: [:*]

  @doc """
  Create a `%Crontab.CronExpression{}` via sigil.

  ## Examples

      iex> ~e[*]
      %Crontab.CronExpression{
        extended: false,
        on_ambiguity: [:later],
        second: [:*],
        minute: [:*],
        hour: [:*],
        day: [:*],
        month: [:*],
        weekday: [:*],
        year: [:*]}

      iex> ~e[*]ea
      %Crontab.CronExpression{
        extended: true,
        on_ambiguity: [:earlier],
        second: [:*],
        minute: [:*],
        hour: [:*],
        day: [:*],
        month: [:*],
        weekday: [:*],
        year: [:*]}

      iex> ~e[1 2 3 4 5 6 7]ale
      %Crontab.CronExpression{
        extended: true,
        on_ambiguity: [:earlier, :later],
        second: [1],
        minute: [2],
        hour: [3],
        day: [4],
        month: [5],
        weekday: [6],
        year: [7]}
  """
  @spec sigil_e(binary, charlist) :: t
  def sigil_e(cron_expression, options \\ [?l]) do
    Parser.parse!(
      cron_expression,
      ?e in options,
      cond do
        ?a in options and ?l in options -> [:earlier, :later]
        ?a in options -> [:earlier]
        true -> [:later]
      end
    )
  end

  @doc """
  Convert `Crontab.CronExpression` struct to tuple List.

  ## Examples

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
  def to_condition_list(interval = %__MODULE__{extended: false}) do
    [
      {:minute, interval.minute},
      {:hour, interval.hour},
      {:day, interval.day},
      {:month, interval.month},
      {:weekday, interval.weekday},
      {:year, interval.year}
    ]
  end

  def to_condition_list(interval = %__MODULE__{}) do
    [{:second, interval.second} | to_condition_list(%{interval | extended: false})]
  end

  defimpl Inspect do
    alias Crontab.CronExpression
    alias Crontab.CronExpression.Composer

    @doc """
    Pretty print Cron expressions.

    ## Examples

        iex> IO.inspect %Crontab.CronExpression{}
        ~e[* * * * * *]l

        iex> import Crontab.CronExpression
        iex> IO.inspect %Crontab.CronExpression{extended: true}
        ~e[* * * * * * *]le

        iex> import Crontab.CronExpression
        iex> IO.inspect %Crontab.CronExpression{extended: true, on_ambiguity: [:earlier, :later]}
        ~e[* * * * * * *]ale
    """
    @spec inspect(CronExpression.t(), any) :: String.t()
    def inspect(cron_expression = %CronExpression{}, _options) do
      earlier = if(:earlier in cron_expression.on_ambiguity, do: "a", else: "")
      later = if(:later in cron_expression.on_ambiguity, do: "l", else: "")
      extended = if(cron_expression.extended, do: "e", else: "")
      "~e[" <> Composer.compose(cron_expression) <> "]#{earlier}#{later}#{extended}"
    end
  end
end
