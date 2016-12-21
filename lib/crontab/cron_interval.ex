defmodule Crontab.CronInterval do
  @moduledoc """
  This is the Crontab.CronInterval module / struct.
  """

  @doc """
  Defines the Cron Interval

  \\* \\* \\* \\* \\* \\*\n
  | | | | | |\n
  | | | | | +-- :year Year                 (range: 1900-3000)\n
  | | | | +---- :weekday Day of the Week   (range: 1-7, 1 standing for Monday)\n
  | | | +------ :month Month of the Year   (range: 1-12)\n
  | | +-------- :day Day of the Month      (range: 1-31)\n
  | +---------- :hour Hour                 (range: 0-23)\n
  +------------ :minute Minute             (range: 0-59)\n
  """
  defstruct minute: [:*], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]

  @doc """
  Convert Crontab.CronInterval struct to Tuple List

  ### Examples
    iex> Crontab.CronInterval.to_condition_list %Crontab.CronInterval{minute: [1], hour: [2], day: [3], month: [4], weekday: [5], year: [6]}
    [ {:minute, [1]},
      {:hour, [2]},
      {:day, [3]},
      {:month, [4]},
      {:weekday, [5]},
      {:year, [6]}]
  """
  def to_condition_list(%Crontab.CronInterval{minute: minute, hour: hour, day: day, month: month, weekday: weekday, year: year}) do
    [ {:minute, minute},
      {:hour, hour},
      {:day, day},
      {:month, month},
      {:weekday, weekday},
      {:year, year}]
  end
end
