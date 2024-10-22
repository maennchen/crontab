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
          Calendar.day() | nil
  def nth_weekday(date = %{month: month}, weekday, n),
    do: find_nth_weekday(%{date | day: 1}, month, weekday, n)

  @doc """
  Find last occurrence of weekday in month

  ### Examples:

      iex> Crontab.DateHelper.last_weekday_of_month(~N[2016-03-14 01:45:45.123])
      31

      iex> Crontab.DateHelper.last_weekday_of_month(~U[2016-03-14 01:45:45.123Z])
      31

  """
  @spec last_weekday_of_month(date :: date()) :: Calendar.day()
  def last_weekday_of_month(date), do: last_weekday_of_month(end_of(date, :month), :end)

  @doc """
  Find next occurrence of weekday relative to date

  ### Examples:

      iex> Crontab.DateHelper.next_weekday_to(~N[2016-03-14 01:45:45.123])
      14

      iex> Crontab.DateHelper.next_weekday_to(~U[2016-03-14 01:45:45.123Z])
      14

  """
  @spec next_weekday_to(date :: date) :: Calendar.day()
  def next_weekday_to(date) do
    weekday = Date.day_of_week(date)
    next_day = add(date, 1, :day)
    previous_day = add(date, -1, :day)

    cond do
      weekday == 7 && next_day.month == date.month -> next_day.day
      weekday == 7 -> add(date, -2, :day).day
      weekday == 6 && previous_day.month == date.month -> previous_day.day
      weekday == 6 -> add(date, 2, :day).day
      true -> date.day
    end
  end

  @doc """
  Increment Year

  ### Examples:

      iex> Crontab.DateHelper.inc_year(~N[2016-03-14 01:45:45.123])
      ~N[2017-03-14 01:45:45.123]

      iex> Crontab.DateHelper.inc_year(~U[2016-03-14 01:45:45.123Z])
      ~U[2017-03-14 01:45:45.123Z]

  """
  @spec inc_year(date) :: date when date: date
  def inc_year(date = %{month: 2, day: 29}), do: add(date, 365, :day)

  def inc_year(date = %{month: month}) do
    candidate = add(date, 365, :day)
    date_leap_year_before_mar? = Date.leap_year?(date) and month < 3
    candidate_leap_year_after_feb? = Date.leap_year?(candidate) and month > 2
    adjustment = if candidate_leap_year_after_feb? or date_leap_year_before_mar?, do: 1, else: 0
    add(candidate, adjustment, :day)
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
  def dec_year(date = %{month: 2, day: 29}), do: add(date, -366, :day)

  def dec_year(date = %{month: month}) do
    candidate = add(date, -365, :day)
    date_leap_year_after_mar? = Date.leap_year?(date) and month > 2
    candidate_leap_year_before_feb? = Date.leap_year?(candidate) and month < 3
    adjustment = if date_leap_year_after_mar? or candidate_leap_year_before_feb?, do: -1, else: 0
    add(candidate, adjustment, :day)
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
  def inc_month(date = %{year: year, month: month, day: day}) do
    days =
      Date.new!(year, month, day)
      |> Date.days_in_month()

    add(date, days + 1 - day, :day)
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
  def dec_month(date = %{year: year, month: month, day: day}) do
    days_in_last_month = Date.new!(year, month, 1) |> Date.add(-1) |> Date.days_in_month()
    add(date, -(day + max(days_in_last_month - day, 0)), :day)
  end

  @spec _beginning_of(date, [{unit, {any, any}}]) :: date when date: date
  defp _beginning_of(date, [{unit, {lower, _}} | tail]) do
    _beginning_of(Map.put(date, unit, lower), tail)
  end

  defp _beginning_of(date, []), do: date

  @spec _end_of(date, [{unit, {any, any}}]) :: date when date: date
  defp _end_of(date, [{unit, {_, :end_of_month}} | tail]) do
    upper = Date.days_in_month(date)
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

  @spec find_nth_weekday(
          date :: date,
          month :: Calendar.month(),
          weekday :: Calendar.day_of_week(),
          n :: non_neg_integer()
        ) :: Calendar.day() | nil
  defp find_nth_weekday(date = %{month: month}, month, weekday, n) do
    modifier =
      if Date.day_of_week(date) == weekday,
        do: n - 1,
        else: n

    if modifier == 0,
      do: date.day,
      else: find_nth_weekday(add(date, 1, :day), month, weekday, modifier)
  end

  defp find_nth_weekday(_, _, _, _), do: nil

  @spec last_weekday_of_month(date :: date(), position :: :end) :: Calendar.day()
  defp last_weekday_of_month(date = %{day: day}, :end) do
    if Date.day_of_week(date) > 5 do
      last_weekday_of_month(add(date, -1, :day), :end)
    else
      day
    end
  end

  @spec last_weekday(date :: date, weekday :: Calendar.day_of_week(), position :: :end) ::
          Calendar.day()
  defp last_weekday(date = %{day: day}, weekday, :end) do
    if Date.day_of_week(date) == weekday do
      day
    else
      last_weekday(add(date, -1, :day), weekday, :end)
    end
  end

  @doc false
  def add(datetime = %NaiveDateTime{}, amt, unit), do: NaiveDateTime.add(datetime, amt, unit)

  def add(datetime = %DateTime{}, amt, unit) do
    candidate = DateTime.add(datetime, amt, unit)
    adjustment = datetime.std_offset - candidate.std_offset
    adjusted = DateTime.add(candidate, adjustment, :second)

    if adjusted.std_offset != candidate.std_offset do
      candidate
    else
      case DateTime.from_naive(DateTime.to_naive(adjusted), adjusted.time_zone) do
        {:ambiguous, _, target} -> target
        {:ok, target} -> target
      end
    end
  end
end
