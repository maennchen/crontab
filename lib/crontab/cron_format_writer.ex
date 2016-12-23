defmodule Crontab.CronFormatWriter do
  import Crontab.CronInterval

  @moduledoc """
  Genrate from `%Crontab.CronInterval{}` to `* * * * * *`
  """

  @doc """
  Genrate from `%Crontab.CronInterval{}` to `* * * * * *`

  ### Examples
      iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{}
      "* * * * * *"
      iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
      "9,4-6,*/9 * * * * *"
  """
  def write(cron_interval = %Crontab.CronInterval{}) do
    cron_interval
      |> to_condition_list
      |> write
      |> Enum.join(" ")
  end
  def write([{_, conditions} | tail]) do
    part = Enum.map(conditions, fn(condition) -> write(condition) end)
      |> Enum.join(",")
    [part | write tail]
  end
  def write([]) do
    []
  end
  def write(:*), do: "*"
  def write(:L), do: "L"
  def write({:L, base}), do: write(base) <> "L"
  def write({:"#", weekday, n}), do: write(weekday) <> "#" <> write(n)
  def write(number) when is_number(number), do: Integer.to_string(number)
  def write({:/, base, divider}), do: write(base) <> "/" <> Integer.to_string(divider)
  def write({:-, min, max}), do: Integer.to_string(min) <> "-" <> Integer.to_string(max)
end
