defmodule Crontab.CronFormatWriter do
  @moduledoc """
  Genrate from `%CronExpression{}`
  to `* * * * * *`
  """

  alias Crontab.CronExpression

  @doc """
  Genrate from `%Crontab.CronExpression{}`
  to `* * * * * *`

  ### Examples

      iex> Crontab.CronFormatWriter.write %Crontab.CronExpression{}
      "* * * * * *"

      iex> Crontab.CronFormatWriter.write %Crontab.CronExpression{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
      "9,4-6,*/9 * * * * *"

  """
  @spec write(CronExpression.t) :: binary
  def write(cron_interval = %CronExpression{}) do
    cron_interval
      |> CronExpression.to_condition_list
      |> write_interval
      |> Enum.join(" ")
  end
  @spec write_interval(CronExpression.condition_list) :: [binary]
  defp write_interval([{_, conditions} | tail]) do
    part = conditions
      |> Enum.map(fn(condition) -> write_condition(condition) end)
      |> Enum.join(",")
    [part | write_interval tail]
  end
  defp write_interval([]), do: []

  @spec write_condition(CronExpression.value) :: binary
  defp write_condition(:*), do: "*"
  defp write_condition(:L), do: "L"
  defp write_condition(:W), do: "W"
  defp write_condition({:W, base}), do: write_condition(base) <> "W"
  defp write_condition({:L, base}), do: write_condition(base) <> "L"
  defp write_condition({:"#", weekday, n}), do: write_condition(weekday) <> "#" <> write_condition(n)
  defp write_condition({:/, base, divider}), do: write_condition(base) <> "/" <> Integer.to_string(divider)
  defp write_condition({:-, min, max}), do: Integer.to_string(min) <> "-" <> Integer.to_string(max)
  defp write_condition(number) when is_number(number), do: Integer.to_string(number)
end
