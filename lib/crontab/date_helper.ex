defmodule Crontab.DateHelper do
  @moduledoc false

  @type unit :: :year | :month | :day | :hour | :minute | :second | :microsecond

  @units [
    {:year, {nil, nil}},
    {:month, {1, 12}},
    {:day, {1, :end_onf_month}},
    {:hour, {0, 23}},
    {:minute, {0, 59}},
    {:second, {0, 59}},
    {:microsecond, {{0, 0}, {999_999, 6}}}
  ]

  @doc """
  Get Start of a period of a date.

  ## Examples

      iex> Crontab.DateHelper.beginning_of(~N[2016-03-14 01:45:45.123], :year)
      ~N[2016-01-01 00:00:00]

  """
  @spec beginning_of(NaiveDateTime.t(), unit) :: NaiveDateTime.t()
  def beginning_of(date, unit) do
    _beginning_of(date, proceeding_units(unit))
  end

  @doc """
  Get the end of a period of a date.

  ## Examples

      iex> Crontab.DateHelper.end_of(~N[2016-03-14 01:45:45.123], :year)
      ~N[2016-12-31 23:59:59.999999]

  """
  @spec end_of(NaiveDateTime.t(), unit) :: NaiveDateTime.t()
  def end_of(date, unit) do
    _end_of(date, proceeding_units(unit))
  end

  @doc """
  Find the last occurrence of weekday in month.
  """
  @spec last_weekday(NaiveDateTime.t(), Calendar.day_of_week()) :: Calendar.day()
  def last_weekday(date, weekday) do
    date
    |> end_of(:month)
    |> last_weekday(weekday, :end)
  end

  @doc """
  Find the nth weekday of month.
  """
  @spec nth_weekday(NaiveDateTime.t(), Calendar.day_of_week(), integer) :: Calendar.day()
  def nth_weekday(date, weekday, n) do
    date
    |> beginning_of(:month)
    |> nth_weekday(weekday, n, :start)
  end

  @doc """
  Find the last occurrence of weekday in month.
  """
  @spec last_weekday_of_month(NaiveDateTime.t()) :: Calendar.day()
  def last_weekday_of_month(date) do
    last_weekday_of_month(end_of(date, :month), :end)
  end

  @doc """
  Find the next occurrence of weekday relative to date.
  """
  @spec next_weekday_to(NaiveDateTime.t()) :: Calendar.day()
  def next_weekday_to(date = %NaiveDateTime{year: year, month: month, day: day}) do
    weekday = :calendar.day_of_the_week(year, month, day)
    next_day = NaiveDateTime.add(date, 86_400, :second)
    previous_day = NaiveDateTime.add(date, -86_400, :second)

    cond do
      weekday == 7 && next_day.month == date.month -> next_day.day
      weekday == 7 -> NaiveDateTime.add(date, -86_400 * 2, :second).day
      weekday == 6 && previous_day.month == date.month -> previous_day.day
      weekday == 6 -> NaiveDateTime.add(date, 86_400 * 2, :second).day
      true -> date.day
    end
  end

  @spec inc_year(NaiveDateTime.t()) :: NaiveDateTime.t()
  def inc_year(date) do
    leap_year? =
      date
      |> NaiveDateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      NaiveDateTime.add(date, 366 * 86_400, :second)
    else
      NaiveDateTime.add(date, 365 * 86_400, :second)
    end
  end

  @spec dec_year(NaiveDateTime.t()) :: NaiveDateTime.t()
  def dec_year(date) do
    leap_year? =
      date
      |> NaiveDateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      NaiveDateTime.add(date, -366 * 86_400, :second)
    else
      NaiveDateTime.add(date, -365 * 86_400, :second)
    end
  end

  @spec inc_month(NaiveDateTime.t()) :: NaiveDateTime.t()
  def inc_month(date = %NaiveDateTime{day: day}) do
    days =
      date
      |> NaiveDateTime.to_date()
      |> Date.days_in_month()

    NaiveDateTime.add(date, (days + 1 - day) * 86_400, :second)
  end

  @spec dec_month(NaiveDateTime.t()) :: NaiveDateTime.t()
  def dec_month(date) do
    days =
      date
      |> NaiveDateTime.to_date()
      |> Date.days_in_month()

    NaiveDateTime.add(date, days * -86_400, :second)
  end

  @spec _beginning_of(NaiveDateTime.t(), [{unit, {any, any}}]) :: NaiveDateTime.t()
  defp _beginning_of(date, [{unit, {lower, _}} | tail]) do
    _beginning_of(Map.put(date, unit, lower), tail)
  end

  defp _beginning_of(date, []), do: date

  @spec _end_of(NaiveDateTime.t(), [{unit, {any, any}}]) :: NaiveDateTime.t()
  defp _end_of(date, [{unit, {_, :end_onf_month}} | tail]) do
    upper =
      date
      |> NaiveDateTime.to_date()
      |> Date.days_in_month()

    _end_of(Map.put(date, unit, upper), tail)
  end

  defp _end_of(date, [{unit, {_, upper}} | tail]) do
    _end_of(Map.put(date, unit, upper), tail)
  end

  defp _end_of(date, []), do: date

  @spec proceeding_units(unit) :: [{unit, {any, any}}]
  defp proceeding_units(unit) do
    [_ | units] =
      @units
      |> Enum.reduce([], fn {key, value}, acc ->
        cond do
          Enum.count(acc) > 0 ->
            Enum.concat(acc, [{key, value}])

          key == unit ->
            [{key, value}]

          true ->
            []
        end
      end)

    units
  end

  @spec nth_weekday(NaiveDateTime.t(), Calendar.day_of_week(), :start) :: boolean
  defp nth_weekday(date = %NaiveDateTime{}, _, 0, :start),
    do: NaiveDateTime.add(date, -86_400, :second).day

  defp nth_weekday(date = %NaiveDateTime{year: year, month: month, day: day}, weekday, n, :start) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      nth_weekday(NaiveDateTime.add(date, 86_400, :second), weekday, n - 1, :start)
    else
      nth_weekday(NaiveDateTime.add(date, 86_400, :second), weekday, n, :start)
    end
  end

  @spec last_weekday_of_month(NaiveDateTime.t(), :end) :: Calendar.day()
  defp last_weekday_of_month(date = %NaiveDateTime{year: year, month: month, day: day}, :end) do
    weekday = :calendar.day_of_the_week(year, month, day)

    if weekday > 5 do
      last_weekday_of_month(NaiveDateTime.add(date, -86_400, :second), :end)
    else
      day
    end
  end

  @spec last_weekday(NaiveDateTime.t(), non_neg_integer, :end) :: Calendar.day()
  defp last_weekday(date = %NaiveDateTime{year: year, month: month, day: day}, weekday, :end) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      day
    else
      last_weekday(NaiveDateTime.add(date, -86_400, :second), weekday, :end)
    end
  end
end
