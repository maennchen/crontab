defmodule Crontab.CronFormatParser do
  @moduledoc """
  Parse string like "* * * * * *" to a %Crontab.CronInterval{}.
  """

  @specials %{
    yearly: %Crontab.CronInterval{minute: [0], hour: [0], day: [1], month: [1]},
    annually: %Crontab.CronInterval{minute: [0], hour: [0], day: [1], month: [1]},
    monthly: %Crontab.CronInterval{minute: [0], hour: [0], day: [1]},
    weekly: %Crontab.CronInterval{minute: [0], hour: [0], weekday: [0]},
    daily: %Crontab.CronInterval{minute: [0], hour: [0]},
    midnight: %Crontab.CronInterval{minute: [0], hour: [0]},
    hourly: %Crontab.CronInterval{minute: [0]},
  }

  @intervals [
    :minute,
    :hour,
    :day,
    :month,
    :weekday,
    :year
  ]

  @weekday_values %{
    "MON": 1,
    "TUE": 2,
    "WED": 3,
    "THU": 4,
    "FRI": 5,
    "SAT": 6,
    "SUN": 7,
  }

  @month_values %{
    "JAN": 1,
    "FEB": 2,
    "MAR": 3,
    "APR": 4,
    "MAY": 5,
    "JUN": 6,
    "JUL": 7,
    "AUG": 8,
    "SEP": 9,
    "OCT": 10,
    "NOV": 11,
    "DEC": 12,
  }

  @doc """
  Parse string like "* * * * * *" to a %Crontab.CronInterval{}.

  ### Examples
    iex> Crontab.CronFormatParser.parse "* * * * *"
    {:ok,
      %Crontab.CronInterval{day: [:*], hour: [:*], minute: [:*],
      month: [:*], weekday: [:*], year: [:*]}}
    iex> Crontab.CronFormatParser.parse "fooo"
    {:error, "Can't parse fooo as interval minute."}
  """
  def parse("@" <> identifier) do
    special(String.to_atom(identifier))
  end
  def parse(cron_format) do
    interpret(String.split(cron_format, " "), @intervals, %Crontab.CronInterval{})
  end

  defp interpret([head_format | tail_format], [head_interval | tail_interval], cron_interval) do
    conditions = interpret head_interval, head_format
    case conditions do
      {:ok, ok_conditions} -> patched_cron_interval = Map.put(cron_interval, head_interval, ok_conditions)
        interpret(tail_format, tail_interval, patched_cron_interval)
      _ -> conditions
    end
  end
  defp interpret([], _, cron_interval), do: {:ok, cron_interval}
  defp interpret(_, [], _), do: {:error, "The Cron Format String contains to many parts."}
  defp interpret(interval, format) do
    parts = String.split(format, ",")
    tokens = Enum.map(parts, fn(part) -> tokenize interval, part end)
    if has_failed_tokens(tokens) do
      has_failed_tokens(tokens)
    else
      {:ok, Enum.map(tokens, fn({:ok, token}) -> token end)}
    end
  end
  defp has_failed_tokens(tokens) do
    Enum.find(tokens, fn(token) -> case token do
      {:error, _} -> true
      _ -> false
    end end)
  end

  defp tokenize(_, "*"), do: {:ok, :*}
  defp tokenize(interval, other) do
    cond do
      String.contains?(other, "/") -> tokenize interval, :complex_divider, other
      Regex.match?(~r/^.+-.+$/, other) -> tokenize interval, :-, other
      true -> tokenize interval, :single_value, other
    end
  end
  defp tokenize(interval, :-, whole_string) do
    [min, max] = String.split(whole_string, "-")
    case {clean_value(interval, min), clean_value(interval, max)} do
      {{:ok, min_value}, {:ok, max_value}} -> {:ok, {:-, min_value, max_value}}
      {error = {:error, _}, _} -> error
      {_, error = {:error, _}} -> error
    end
  end
  defp tokenize(interval, :single_value, value) do
    clean_value(interval, value)
  end
  defp tokenize(interval, :complex_divider, value) do
    [base, divider] = String.split value, "/"

    case {tokenize(interval, base), Integer.parse(divider, 10)} do
      {{:ok, clean_base}, {clean_divider, _}} -> {:ok, {:/, clean_base, clean_divider}}
      {_, :error} -> {:error, "Can't parse " <> value <> " as interval " <> Atom.to_string(interval) <> "."}
      {error = {:error}, _} -> error
    end
  end

  defp clean_value(:weekday, value) do
    case {Map.fetch(@weekday_values, String.to_atom(String.upcase(value))), Integer.parse(value, 10)} do
      {:error, :error} -> {:error, "Can't parse " <> value <> " as interval weekday."}
      {{:ok, number}, :error} -> {:ok, number}
      {:error, {number, _}} -> {:ok, number}
    end
  end
  defp clean_value(:month, value) do
    case {Map.fetch(@month_values, String.to_atom(String.upcase(value))), Integer.parse(value, 10)} do
      {:error, :error} -> {:error, "Can't parse " <> value <> " as interval month."}
      {{:ok, number}, :error} -> {:ok, number}
      {:error, {number, _}} -> {:ok, number}
    end
  end
  defp clean_value(interval, value) do
    case Integer.parse(value, 10) do
      {number, _} -> {:ok, number}
      :error -> {:error, "Can't parse " <> value <> " as interval " <> Atom.to_string(interval) <> "."}
    end
  end


  defp special(:reboot), do: {:error, "Special identifier @reboot is not supported."}
  defp special(identifier) do
    if Map.has_key?(@specials, identifier) do
      {:ok, Map.fetch!(@specials, identifier)}
    else
      {:error, "Special identifier @" <> Atom.to_string(identifier) <> " is undefined."}
    end
  end
end
