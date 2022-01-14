defmodule Crontab.CronExpression.Composer do
  @moduledoc """
  Generate from `%CronExpression{}` to `* * * * * *`.
  """

  alias Crontab.CronExpression

  @doc """
  Generate from `%Crontab.CronExpression{}` to `* * * * * *`.

  ## Examples

      iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{}
      "* * * * * *"

      iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
      "9,4-6,*/9 * * * * *"

      iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{reboot: true}
      "@reboot"

  """
  @spec compose(CronExpression.t()) :: binary
  def compose(%CronExpression{reboot: true}) do
    "@reboot"
  end

  def compose(cron_expression = %CronExpression{}) do
    cron_expression
    |> CronExpression.to_condition_list()
    |> compose_interval
    |> Enum.join(" ")
  end

  @spec compose_interval(CronExpression.condition_list()) :: [binary]
  defp compose_interval([{_, conditions} | tail]),
    do: [
      Enum.map_join(conditions, ",", fn condition -> compose_condition(condition) end)
      | compose_interval(tail)
    ]

  defp compose_interval([]), do: []

  @spec compose_condition(CronExpression.value()) :: binary
  defp compose_condition(:*), do: "*"
  defp compose_condition(:L), do: "L"
  defp compose_condition(:W), do: "W"
  defp compose_condition({:W, base}), do: compose_condition(base) <> "W"
  defp compose_condition({:L, base}), do: compose_condition(base) <> "L"

  defp compose_condition({:"#", weekday, n}),
    do: compose_condition(weekday) <> "#" <> compose_condition(n)

  defp compose_condition({:/, base, divider}),
    do: compose_condition(base) <> "/" <> Integer.to_string(divider)

  defp compose_condition({:-, min, max}),
    do: Integer.to_string(min) <> "-" <> Integer.to_string(max)

  defp compose_condition(number) when is_number(number), do: Integer.to_string(number)
end
