defmodule Crontab.DateHelper do
  @moduledoc false

  @type unit :: :year | :month | :day | :hour | :minute | :second | :microsecond

  @type date :: NaiveDateTime.t() | DateTime.t()

  @units [
    {:year, {nil, nil}},
    {:month, {1, 12}},
    {:day, {1, :end_of_month}},
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

      iex> Crontab.DateHelper.beginning_of(~U[2016-03-14 01:45:45.123Z], :year)
      ~U[2016-01-01 00:00:00Z]

  """
  @spec beginning_of(date, unit :: unit) :: date when date: date
  def beginning_of(date, unit) do
    _beginning_of(date, proceeding_units(unit))
  end

  @doc """
  Get the end of a period of a date.

  ## Examples

      iex> Crontab.DateHelper.end_of(~N[2016-03-14 01:45:45.123], :year)
      ~N[2016-12-31 23:59:59.999999]

      iex> Crontab.DateHelper.end_of(~U[2016-03-14 01:45:45.123Z], :year)
      ~U[2016-12-31 23:59:59.999999Z]

  """
  @spec end_of(date, unit :: unit) :: date when date: date
  def end_of(date, unit) do
    _end_of(date, proceeding_units(unit))
  end

  @doc """
  Find last occurrence of weekday in month

  ### Examples:

      iex> Crontab.DateHelper.last_weekday(~N[2016-03-14 01:45:45.123], 6)
      26

      iex> Crontab.DateHelper.last_weekday(~U[2016-03-14 01:45:45.123Z], 6)
      26

  """
  @spec last_weekday(date :: date, day_of_week :: Calendar.day_of_week()) :: Calendar.day()
  def last_weekday(date, weekday) do
    date
    |> end_of(:month)
    |> last_weekday(weekday, :end)
  end

  @doc """
  Find nth weekday of month

  ### Examples:

      iex> Crontab.DateHelper.nth_weekday(~N[2016-03-14 01:45:45.123], 6, 2)
      12

      iex> Crontab.DateHelper.nth_weekday(~U[2016-03-14 01:45:45.123Z], 6, 2)
      12

  """
  @spec nth_weekday(date :: date, weekday :: Calendar.day_of_week(), n :: pos_integer) ::
          Calendar.day()
  def nth_weekday(date, weekday, n) do
    date
    |> beginning_of(:month)
    |> nth_weekday(weekday, n, :start)
  end

  @doc """
  Find last occurrence of weekday in month

  ### Examples:

      iex> Crontab.DateHelper.last_weekday_of_month(~N[2016-03-14 01:45:45.123])
      31

      iex> Crontab.DateHelper.last_weekday_of_month(~U[2016-03-14 01:45:45.123Z])
      31

  """
  @spec last_weekday_of_month(NaiveDateTime.t()) :: Calendar.day()
  def last_weekday_of_month(date) do
    last_weekday_of_month(end_of(date, :month), :end)
  end

  @doc """
  Find next occurrence of weekday relative to date

  ### Examples:

      iex> Crontab.DateHelper.next_weekday_to(~N[2016-03-14 01:45:45.123])
      14

      iex> Crontab.DateHelper.next_weekday_to(~U[2016-03-14 01:45:45.123Z])
      14

  """
  @spec next_weekday_to(date :: date) :: Calendar.day()
  def next_weekday_to(date = %NaiveDateTime{year: year, month: month, day: day}) do
    weekday = :calendar.day_of_the_week(year, month, day)
    next_day = NaiveDateTime.add(date, 1, :day)
    previous_day = NaiveDateTime.add(date, -1, :day)

    cond do
      weekday == 7 && next_day.month == date.month -> next_day.day
      weekday == 7 -> NaiveDateTime.add(date, -2, :day).day
      weekday == 6 && previous_day.month == date.month -> previous_day.day
      weekday == 6 -> NaiveDateTime.add(date, 2, :day).day
      true -> date.day
    end
  end

  def next_weekday_to(date = %DateTime{year: year, month: month, day: day}) do
    weekday = :calendar.day_of_the_week(year, month, day)
    # FIXME: How to correct date with tz?
    next_day = DateTime.add(date, 1, :day)
    # FIXME: How to correct date with tz?
    previous_day = DateTime.add(date, -1, :day)

    cond do
      weekday == 7 && next_day.month == date.month -> next_day.day
      weekday == 7 -> DateTime.add(date, -2, :day).day
      weekday == 6 && previous_day.month == date.month -> previous_day.day
      weekday == 6 -> DateTime.add(date, 2, :day).day
      true -> date.day
    end
  end

  @doc """
  Increment Year

  ### Examples:

      iex> Crontab.DateHelper.inc_year(~N[2016-03-14 01:45:45.123])
      ~N[2017-03-15 01:45:45.123]

      iex> Crontab.DateHelper.inc_year(~U[2016-03-14 01:45:45.123Z])
      ~U[2017-03-15 01:45:45.123Z]

  """
  @spec inc_year(date) :: date when date: date
  def inc_year(date = %NaiveDateTime{}) do
    leap_year? =
      date
      |> NaiveDateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      NaiveDateTime.add(date, 366, :day)
    else
      NaiveDateTime.add(date, 365, :day)
    end
  end

  def inc_year(date = %DateTime{}) do
    leap_year? =
      date
      |> DateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      # FIXME: How to correct date with tz?
      DateTime.add(date, 366, :day)
    else
      # FIXME: How to correct date with tz?
      DateTime.add(date, 365, :day)
    end
  end

  @doc """
  Decrement Year

  ### Examples:

      iex> Crontab.DateHelper.dec_year(~N[2016-03-14 01:45:45.123])
      ~N[2015-03-14 01:45:45.123]

      iex> Crontab.DateHelper.dec_year(~U[2016-03-14 01:45:45.123Z])
      ~U[2015-03-14 01:45:45.123Z]

  """
  @spec dec_year(date) :: date when date: date
  def dec_year(date = %NaiveDateTime{}) do
    leap_year? =
      date
      |> NaiveDateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      NaiveDateTime.add(date, -366, :day)
    else
      NaiveDateTime.add(date, -365, :day)
    end
  end

  def dec_year(date = %DateTime{}) do
    leap_year? =
      date
      |> DateTime.to_date()
      |> Date.leap_year?()

    if leap_year? do
      # FIXME: How to correct date with tz?
      DateTime.add(date, -366, :day)
    else
      # FIXME: How to correct date with tz?
      DateTime.add(date, -365, :day)
    end
  end

  @doc """
  Increment Month

  ### Examples:

      iex> Crontab.DateHelper.inc_month(~N[2016-03-14 01:45:45.123])
      ~N[2016-04-01 01:45:45.123]

      iex> Crontab.DateHelper.inc_month(~U[2016-03-14 01:45:45.123Z])
      ~U[2016-04-01 01:45:45.123Z]

  """
  @spec inc_month(date) :: date when date: date
  def inc_month(date = %NaiveDateTime{day: day}) do
    days =
      date
      |> NaiveDateTime.to_date()
      |> Date.days_in_month()

    NaiveDateTime.add(date, days + 1 - day, :day)
  end

  def inc_month(date = %DateTime{day: day}) do
    days =
      date
      |> DateTime.to_date()
      |> Date.days_in_month()

    # FIXME: How to correct date with tz?
    DateTime.add(date, days + 1 - day, :day)
  end

  @doc """
  Decrement Month

  ### Examples:

      iex> Crontab.DateHelper.dec_month(~N[2016-03-14 01:45:45.123])
      ~N[2016-02-14 01:45:45.123]

      iex> Crontab.DateHelper.dec_month(~U[2016-03-14 01:45:45.123Z])
      ~U[2016-02-14 01:45:45.123Z]

      iex> Crontab.DateHelper.dec_month(~N[2011-05-31 23:59:59])
      ~N[2011-04-30 23:59:59]

  """
  @spec dec_month(date) :: date when date: date
  def dec_month(date = %NaiveDateTime{day: day}) do
    days_in_last_month =
      date
      |> NaiveDateTime.to_date()
      |> day_in_last_month
      |> Date.days_in_month()

    NaiveDateTime.add(date, -(day + max(days_in_last_month - day, 0)), :day)
  end

  def dec_month(date = %DateTime{day: day}) do
    days_in_last_month =
      date
      |> DateTime.to_date()
      |> day_in_last_month
      |> Date.days_in_month()

    # FIXME: How to correct date with tz?
    DateTime.add(date, -(day + max(days_in_last_month - day, 0)), :day)
  end

  defp day_in_last_month(start_date), do: day_in_last_month(start_date, start_date)

  defp day_in_last_month(date = %Date{month: month}, start_date = %Date{month: month}),
    do: date |> Date.add(-1) |> day_in_last_month(start_date)

  defp day_in_last_month(date, _start_date), do: date

  @spec _beginning_of(date, [{unit, {any, any}}]) :: date when date: date
  defp _beginning_of(date, [{unit, {lower, _}} | tail]) do
    _beginning_of(Map.put(date, unit, lower), tail)
  end

  defp _beginning_of(date, []), do: date

  @spec _end_of(date, [{unit, {any, any}}]) :: date when date: date
  defp _end_of(date = %NaiveDateTime{}, [{unit, {_, :end_of_month}} | tail]) do
    upper =
      date
      |> NaiveDateTime.to_date()
      |> Date.days_in_month()

    _end_of(Map.put(date, unit, upper), tail)
  end

  defp _end_of(date = %DateTime{}, [{unit, {_, :end_of_month}} | tail]) do
    upper =
      date
      |> DateTime.to_date()
      |> Date.days_in_month()

    # FIXME: How to correct date with tz?
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
            [{key, value} | acc]

          key == unit ->
            [{key, value}]

          true ->
            []
        end
      end)
      |> Enum.reverse()

    units
  end

  @spec nth_weekday(date :: date, weekday :: Calendar.day_of_week(), position :: :start) ::
          boolean
  defp nth_weekday(date = %NaiveDateTime{}, _, 0, :start),
    do: NaiveDateTime.add(date, -1, :day).day

  # FIXME: How to correct date with tz?
  defp nth_weekday(date = %DateTime{}, _, 0, :start),
    do: DateTime.add(date, -1, :day).day

  defp nth_weekday(date = %NaiveDateTime{year: year, month: month, day: day}, weekday, n, :start) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      nth_weekday(NaiveDateTime.add(date, 1, :day), weekday, n - 1, :start)
    else
      nth_weekday(NaiveDateTime.add(date, 1, :day), weekday, n, :start)
    end
  end

  defp nth_weekday(date = %DateTime{year: year, month: month, day: day}, weekday, n, :start) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      # FIXME: How to correct date with tz?
      nth_weekday(DateTime.add(date, 1, :day), weekday, n - 1, :start)
    else
      # FIXME: How to correct date with tz?
      nth_weekday(DateTime.add(date, 1, :day), weekday, n, :start)
    end
  end

  @spec last_weekday_of_month(date :: date(), position :: :end) :: Calendar.day()
  defp last_weekday_of_month(date = %NaiveDateTime{year: year, month: month, day: day}, :end) do
    weekday = :calendar.day_of_the_week(year, month, day)

    if weekday > 5 do
      last_weekday_of_month(NaiveDateTime.add(date, -1, :day), :end)
    else
      day
    end
  end

  defp last_weekday_of_month(date = %DateTime{year: year, month: month, day: day}, :end) do
    weekday = :calendar.day_of_the_week(year, month, day)

    if weekday > 5 do
      # FIXME: How to correct date with tz?
      last_weekday_of_month(DateTime.add(date, -1, :day), :end)
    else
      day
    end
  end

  @spec last_weekday(date :: date, weekday :: Calendar.day_of_week(), position :: :end) ::
          Calendar.day()
  defp last_weekday(date = %NaiveDateTime{year: year, month: month, day: day}, weekday, :end) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      day
    else
      last_weekday(NaiveDateTime.add(date, -1, :day), weekday, :end)
    end
  end

  defp last_weekday(date = %DateTime{year: year, month: month, day: day}, weekday, :end) do
    if :calendar.day_of_the_week(year, month, day) == weekday do
      day
    else
      # FIXME: How to correct date with tz?
      last_weekday(DateTime.add(date, -1, :day), weekday, :end)
    end
  end
end
