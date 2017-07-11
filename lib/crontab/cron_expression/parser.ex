defmodule Crontab.CronExpression.Parser do
  @moduledoc """
  Parse string like `* * * * * *` to a `%Crontab.CronExpression{}`.
  """

  alias Crontab.CronExpression

  @type result :: {:ok, CronExpression.t} | {:error, binary}

  @specials %{
    reboot: %CronExpression{reboot: true},
    yearly: %CronExpression{minute: [0], hour: [0], day: [1], month: [1]},
    annually: %CronExpression{minute: [0], hour: [0], day: [1], month: [1]},
    monthly: %CronExpression{minute: [0], hour: [0], day: [1]},
    weekly: %CronExpression{minute: [0], hour: [0], weekday: [0]},
    daily: %CronExpression{minute: [0], hour: [0]},
    midnight: %CronExpression{minute: [0], hour: [0]},
    hourly: %CronExpression{minute: [0]},
    minutely: %CronExpression{},
    secondly: %CronExpression{extended: true},
  }

  @intervals [
    :minute,
    :hour,
    :day,
    :month,
    :weekday,
    :year
  ]

  @extended_intervals [:second | @intervals]

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
  Parse string like `* * * * * *` to a `%CronExpression{}`.

  ### Examples

      iex> Crontab.CronExpression.Parser.parse "* * * * *"
      {:ok,
        %Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
        month: [:*], weekday: [:*], year: [:*]}}

      iex> Crontab.CronExpression.Parser.parse "* * * * *", true
      {:ok,
        %Crontab.CronExpression{extended: true, day: [:*], hour: [:*], minute: [:*],
        month: [:*], weekday: [:*], year: [:*], second: [:*]}}

      iex> Crontab.CronExpression.Parser.parse "fooo"
      {:error, "Can't parse fooo as interval minute."}

  """
  @spec parse(binary, boolean) :: result
  def parse(cron_expression, extended \\ false)
  def parse("@" <> identifier, _) do
    special(String.to_atom(String.downcase(identifier)))
  end
  def parse(cron_expression, true) do
    interpret(String.split(cron_expression, " "), @extended_intervals, %CronExpression{extended: true})
  end
  def parse(cron_expression, false) do
    interpret(String.split(cron_expression, " "), @intervals, %CronExpression{})
  end

  @doc """
  Parse string like `* * * * * *` to a `%CronExpression{}`.

  ### Examples

      iex> Crontab.CronExpression.Parser.parse! "* * * * *"
      %Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
        month: [:*], weekday: [:*], year: [:*]}

      iex> Crontab.CronExpression.Parser.parse! "* * * * *", true
      %Crontab.CronExpression{extended: true, day: [:*], hour: [:*], minute: [:*],
        month: [:*], weekday: [:*], year: [:*], second: [:*]}

      iex> Crontab.CronExpression.Parser.parse! "fooo"
      ** (RuntimeError) Can't parse fooo as interval minute.

  """
  @spec parse!(binary, boolean) :: CronExpression.t | no_return
  def parse!(cron_expression, extended \\ false) do
    case parse(cron_expression, extended) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @spec interpret([binary], [CronExpression.interval], CronExpression.t) :: {:ok, CronExpression.t} | {:error, binary}
  defp interpret([head_format | tail_format], [head_expression | tail_expression], cron_expression) do
    conditions = interpret head_expression, head_format
    case conditions do
      {:ok, ok_conditions} -> patched_cron_expression = Map.put(cron_expression, head_expression, ok_conditions)
        interpret(tail_format, tail_expression, patched_cron_expression)
      _ -> conditions
    end
  end
  defp interpret([], _, cron_expression), do: {:ok, cron_expression}
  defp interpret(_, [], _), do: {:error, "The Cron Format String contains to many parts."}

  @spec interpret(CronExpression.interval, binary) :: {:ok, [CronExpression.value]} | {:error, binary}
  defp interpret(interval, format) do
    parts = String.split(format, ",")
    tokens = Enum.map(parts, fn(part) -> tokenize interval, part end)
    if get_failed_token(tokens) do
      get_failed_token(tokens)
    else
      {:ok, Enum.map(tokens, fn({:ok, token}) -> token end)}
    end
  end

  @spec get_failed_token([{:error, binary}] | CronExpression.value) :: {:error, binary} | nil
  defp get_failed_token(tokens) do
    Enum.find(tokens, fn(token) -> case token do
      {:error, _} -> true
      _ -> false
    end end)
  end

  @spec tokenize(CronExpression.interval, binary) :: {:ok, CronExpression.value} | {:error, binary}
  defp tokenize(_, "*"), do: {:ok, :*}
  defp tokenize(interval, other) do
    cond do
      String.contains?(other, "/") -> tokenize interval, :complex_divider, other
      Regex.match?(~r/^.+-.+$/, other) -> tokenize interval, :-, other
      true -> tokenize interval, :single_value, other
    end
  end
  @spec tokenize(CronExpression.interval, :- | :single_value | :complex_divider)
    :: {:ok, CronExpression.value} | {:error, binary}
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
      {error = {:error, _}, _} -> error
    end
  end

  @spec clean_value(CronExpression.interval, binary) :: {:ok, CronExpression.value} | {:error, binary}
  defp clean_value(:weekday, "L"), do: {:ok, 7}
  defp clean_value(:weekday, value) do
    cond do
      String.match?(value, ~r/L$/) ->
        case parse_week_day(binary_part(value, 0, byte_size(value) - 1)) do
          {:ok, value} -> {:ok, {:L, value}}
          error = {:error, _} -> error
        end
      String.match?(value, ~r/#\d+$/) ->
        [weekday, n] = String.split value, "#"
        case parse_week_day weekday do
          {:ok, value} ->
            {n_int, _} = Integer.parse(n)
            {:ok, {:"#", value, n_int}}
          error = {:error, _} -> error
        end
      true -> parse_week_day(value)
    end
  end
  defp clean_value(:month, "L"), do: {:ok, 12}
  defp clean_value(:month, value) do
    case {Map.fetch(@month_values, String.to_atom(String.upcase(value))), Integer.parse(value, 10)} do
      {:error, :error} -> {:error, "Can't parse " <> value <> " as interval month."}
      {{:ok, number}, :error} -> {:ok, number}
      {:error, {number, _}} -> {:ok, number}
    end
  end
  defp clean_value(:day, "L"), do: {:ok, :L}
  defp clean_value(:day, "LW"), do: {:ok, {:W, :L}}
  defp clean_value(:day, value) do
    if String.match?(value, ~r/W$/) do
      day = binary_part(value, 0, byte_size(value) - 1)
      case Integer.parse(day, 10) do
        {number, _} -> {:ok, {:W, number}}
        :error -> {:error, "Can't parse " <> value <> " as interval day."}
      end
    else
      case Integer.parse(value, 10) do
        {number, _} -> {:ok, number}
        :error -> {:error, "Can't parse " <> value <> " as interval day."}
      end
    end
  end
  defp clean_value(interval, value) do
    case Integer.parse(value, 10) do
      {number, _} -> {:ok, number}
      :error -> {:error, "Can't parse " <> value <> " as interval " <> Atom.to_string(interval) <> "."}
    end
  end

  @spec parse_week_day(binary) :: {:ok, CronExpression.value} | {:error, binary}
  defp parse_week_day(value) do
    case {Map.fetch(@weekday_values, String.to_atom(String.upcase(value))), Integer.parse(value, 10)} do
      {:error, :error} -> {:error, "Can't parse " <> value <> " as interval weekday."}
      {{:ok, number}, :error} -> {:ok, number}
      {:error, {number, _}} -> {:ok, number}
    end
  end

  @spec special(atom) :: result
  defp special(identifier) do
    if Map.has_key?(@specials, identifier) do
      {:ok, Map.fetch!(@specials, identifier)}
    else
      {:error, "Special identifier @" <> Atom.to_string(identifier) <> " is undefined."}
    end
  end
end
