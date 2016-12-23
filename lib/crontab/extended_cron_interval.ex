defmodule Crontab.ExtendedCronInterval do
  @moduledoc """
  This is the Crontab.ExtendedCronInterval module / struct.
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
  """
  defstruct second: [:*], minute: [:*], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]

  @type t :: %Crontab.ExtendedCronInterval{}
  @type all_t :: %Crontab.ExtendedCronInterval{} | Crontab.CronInterval.t
  @type interval :: :second | Crontab.CronInterval.interval
  @type condition :: {interval, [Crontab.CronInterval.value]}
  @type condition_list :: [condition]

  @doc """
  Convert Crontab.ExtendedCronInterval struct to Tuple List

  ### Examples
      iex> Crontab.ExtendedCronInterval.to_condition_list %Crontab.ExtendedCronInterval{second: [0], minute: [1], hour: [2], day: [3], month: [4], weekday: [5], year: [6]}
      [ {:second, [0]},
        {:minute, [1]},
        {:hour, [2]},
        {:day, [3]},
        {:month, [4]},
        {:weekday, [5]},
        {:year, [6]}]
  """
  @spec to_condition_list(t) :: condition_list
  def to_condition_list(%Crontab.ExtendedCronInterval{second: second, minute: minute, hour: hour, day: day, month: month, weekday: weekday, year: year}) do
    [ {:second, second},
      {:minute, minute},
      {:hour, hour},
      {:day, day},
      {:month, month},
      {:weekday, weekday},
      {:year, year}]
  end
end
