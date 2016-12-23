defmodule Crontab.CronFormatWriter do
  @moduledoc """
  Genrate from `%Crontab.CronInterval{}` or `%Crontab.ExtendedCronInterval{}`
  to `* * * * * *`
  """

  @doc """
  Genrate from `%Crontab.CronInterval{}` or `%Crontab.ExtendedCronInterval{}`
  to `* * * * * *`

  ### Examples

      iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{}
      "* * * * * *"

      iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
      "9,4-6,*/9 * * * * *"

      iex> Crontab.CronFormatWriter.write %Crontab.ExtendedCronInterval{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
      "* 9,4-6,*/9 * * * * *"

  """
  @spec write(Crontab.ExtendedCronInterval.all_t) :: binary
  def write(cron_interval = %Crontab.CronInterval{}) do
    cron_interval
      |> Crontab.CronInterval.to_condition_list
      |> write_interval
      |> Enum.join(" ")
  end
  def write(cron_interval = %Crontab.ExtendedCronInterval{}) do
    cron_interval
      |> Crontab.ExtendedCronInterval.to_condition_list
      |> write_interval
      |> Enum.join(" ")
  end

  @spec write_interval(Crontab.ExtendedCronInterval.condition_list) :: [binary]
  defp write_interval([{_, conditions} | tail]) do
    part = Enum.map(conditions, fn(condition) -> write_condition(condition) end)
      |> Enum.join(",")
    [part | write_interval tail]
  end
  defp write_interval([]), do: []

  @spec write_condition(Crontab.CronInterval.value) :: binary
  defp write_condition(:*), do: "*"
  defp write_condition(:L), do: "L"
  defp write_condition({:L, base}), do: write_condition(base) <> "L"
  defp write_condition({:"#", weekday, n}), do: write_condition(weekday) <> "#" <> write_condition(n)
  defp write_condition({:/, base, divider}), do: write_condition(base) <> "/" <> Integer.to_string(divider)
  defp write_condition({:-, min, max}), do: Integer.to_string(min) <> "-" <> Integer.to_string(max)
  defp write_condition(number) when is_number(number), do: Integer.to_string(number)
end
