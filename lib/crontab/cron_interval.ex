defmodule Crontab.CronInterval do
  @moduledoc """
  This is the Crontab.CronInterval module / struct.
  """

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
  defstruct extended: false, second: [:*], minute: [:*], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]

  @type t :: %Crontab.CronInterval{}
  @type interval :: :minute | :hour | :day | :month | :weekday | :year
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
  Convert Crontab.CronInterval struct to Tuple List

  ### Examples

      iex> Crontab.CronInterval.to_condition_list %Crontab.CronInterval{
      ...> minute: [1], hour: [2], day: [3], month: [4], weekday: [5], year: [6]}
      [ {:minute, [1]},
        {:hour, [2]},
        {:day, [3]},
        {:month, [4]},
        {:weekday, [5]},
        {:year, [6]}]

      iex> Crontab.CronInterval.to_condition_list %Crontab.CronInterval{
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
  def to_condition_list(interval = %Crontab.CronInterval{extended: false}) do
    [{:minute, interval.minute},
     {:hour, interval.hour},
     {:day, interval.day},
     {:month, interval.month},
     {:weekday, interval.weekday},
     {:year, interval.year}]
  end
  def to_condition_list(interval = %Crontab.CronInterval{}) do
    [{:second, interval.second} | to_condition_list(%{interval | extended: false})]
  end
end
