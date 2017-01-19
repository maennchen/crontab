defmodule Crontab do
  @moduledoc """
  This Library is built to parse & compose cron expressions, test them against a
  given date and finde the next execution date.

  In the main module defined are helper functions which work directlyfrom a
  string cron expression.
  """

  alias Crontab.CronExpression.Parser
  alias Crontab.Scheduler
  alias Crontab.DateChecker

  @doc """
  Find the next execution date relative to now for a string of an eventually
  extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_next_run_date("* * * * *")
      {:ok, ~N[2016-12-23 16:00:00.348751]}

      iex> Crontab.get_next_run_date("* * * * *", true)
      {:ok, ~N[2016-12-23 16:00:00.348751]}

      iex> Crontab.get_next_run_date("* * * * *", false)
      {:ok, ~N[2016-12-23 16:00:00.348751]}

  """
  @spec get_next_run_date(binary, boolean) :: Scheduler.result
  def get_next_run_date(cron_expression, extended \\ false) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_next_run_date_relative_to(cron_expression, date, extended)
  end

  @doc """
  Find the next execution date relative to a given date for a string of an
  eventually extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_next_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:00])
      {:ok, ~N[2016-12-17 00:00:00]}

      iex> Crontab.get_next_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:00], false)
      {:ok, ~N[2016-12-17 00:00:00]}

      iex> Crontab.get_next_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:01], true)
      {:ok, ~N[2016-12-17 00:00:01]}

  """
  @spec get_next_run_date_relative_to(binary, NaiveDateTime.t, boolean) :: Scheduler.result
  def get_next_run_date_relative_to(cron_expression, date, extended \\ false) do
    case Parser.parse(cron_expression, extended) do
      {:ok, cron_format} -> Scheduler.get_next_run_date(cron_format, date)
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the next n execution dates relative to now for a string of an eventually
  extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_next_run_dates(3, "* * * * *")
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 16:01:00]},
       {:ok, ~N[2016-12-23 16:02:00]}]

      iex> Crontab.get_next_run_dates(3, "* * * * *", true)
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 16:00:01]},
       {:ok, ~N[2016-12-23 16:00:02]}]

      iex> Crontab.get_next_run_dates(3, "* * * * *", false)
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 16:01:00]},
       {:ok, ~N[2016-12-23 16:02:00]}]

  """
  @spec get_next_run_dates(pos_integer, binary, boolean) :: [Scheduler.result]
  def get_next_run_dates(n, cron_expression, extended \\ false) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_next_run_dates_relative_to(n, cron_expression, date, extended)
  end

  @doc """
  Find the next n execution dates relative to a given date for a string of an
  eventually extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_next_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00])
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-17 00:01:00]},
       {:ok, ~N[2016-12-17 00:02:00]}]

      iex> Crontab.get_next_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00], true)
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-17 00:00:01]},
       {:ok, ~N[2016-12-17 00:00:02]}]

      iex> Crontab.get_next_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00], false)
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-17 00:01:00]},
       {:ok, ~N[2016-12-17 00:02:00]}]

  """
  @spec get_next_run_dates_relative_to(pos_integer, binary, NaiveDateTime.t, boolean) :: [Scheduler.result]
  def get_next_run_dates_relative_to(n, cron_expression, date, extended \\ false)
  def get_next_run_dates_relative_to(0, _, _, _), do: []
  def get_next_run_dates_relative_to(n, cron_expression, date, false) do
    case Parser.parse(cron_expression, false) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Scheduler.get_next_run_date(cron_format, date)
        [result | get_next_run_dates_relative_to(n - 1, cron_expression, Timex.shift(run_date, minutes: 1), false)]
      error = {:error, _} -> error
    end
  end
  def get_next_run_dates_relative_to(n, cron_expression, date, true) do
    case Parser.parse(cron_expression, true) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Scheduler.get_next_run_date(cron_format, date)
        [result | get_next_run_dates_relative_to(n - 1, cron_expression, Timex.shift(run_date, seconds: 1), true)]
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the previous execution date relative to now for a string  of an
  eventually extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_previous_run_date("* * * * *")
      {:ok, ~N[2016-12-23 16:00:00.348751]}

      iex> Crontab.get_previous_run_date("* * * * *", true)
      {:ok, ~N[2016-12-23 16:00:00.348751]}

      iex> Crontab.get_previous_run_date("* * * * *", false)
      {:ok, ~N[2016-12-23 16:00:00.348751]}

  """
  @spec get_previous_run_date(binary, boolean) :: Scheduler.result
  def get_previous_run_date(cron_expression, extended \\ false) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_previous_run_date_relative_to(cron_expression, date, extended)
  end

  @doc """
  Find the previous execution date relative to a given date for a string of an
  eventually extended cron expression.

  ### Examples

      iex> Crontab.get_previous_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:00])
      {:ok, ~N[2016-12-17 00:00:00]}

      iex> Crontab.get_previous_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:00], true)
      {:ok, ~N[2016-12-17 00:00:00]}

      iex> Crontab.get_previous_run_date_relative_to("* * * * *", ~N[2016-12-17 00:00:00], false)
      {:ok, ~N[2016-12-17 00:00:00]}

  """
  @spec get_previous_run_date_relative_to(binary, NaiveDateTime.t, boolean) :: Scheduler.result
  def get_previous_run_date_relative_to(cron_expression, date, extended \\ false) do
    case Parser.parse(cron_expression, extended) do
      {:ok, cron_format} -> Scheduler.get_previous_run_date(cron_format, date)
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the previous n execution dates relative to now for a string of an
  eventually extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_previous_run_dates(3, "* * * * *")
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 15:59:00]},
       {:ok, ~N[2016-12-23 15:58:00]}]

      iex> Crontab.get_previous_run_dates(3, "* * * * *", true)
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 15:59:59]},
       {:ok, ~N[2016-12-23 15:59:58]}]

      iex> Crontab.get_previous_run_dates(3, "* * * * *", false)
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 15:59:00]},
       {:ok, ~N[2016-12-23 15:58:00]}]

  """
  @spec get_previous_run_dates(pos_integer, binary, boolean) :: [Scheduler.result]
  def get_previous_run_dates(n, cron_expression, extended \\ false) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_previous_run_dates_relative_to(n, cron_expression, date, extended)
  end

  @doc """
  Find the previous n execution dates relative to a given date for a string of
  an eventually extended cron expression. (Extended = including seconds)

  ### Examples

      iex> Crontab.get_previous_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00])
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-16 23:59:00]},
       {:ok, ~N[2016-12-16 23:58:00]}]

      iex> Crontab.get_previous_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00], true)
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-16 23:59:59]},
       {:ok, ~N[2016-12-16 23:59:58]}]

      iex> Crontab.get_previous_run_dates_relative_to(3, "* * * * *", ~N[2016-12-17 00:00:00], false)
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-16 23:59:00]},
       {:ok, ~N[2016-12-16 23:58:00]}]

  """
  @spec get_previous_run_dates_relative_to(pos_integer, binary, NaiveDateTime.t, boolean) :: [Scheduler.result]
  def get_previous_run_dates_relative_to(n, cron_expression, date, extended \\ false)
  def get_previous_run_dates_relative_to(0, _, _, _), do: []
  def get_previous_run_dates_relative_to(n, cron_expression, date, false) do
    case Parser.parse(cron_expression, false) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Scheduler.get_previous_run_date(cron_format, date)
        [result | get_previous_run_dates_relative_to(n - 1, cron_expression, Timex.shift(run_date, minutes: -1), false)]
      error = {:error, _} -> error
    end
  end
  def get_previous_run_dates_relative_to(n, cron_expression, date, true) do
    case Parser.parse(cron_expression, true) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Scheduler.get_previous_run_date(cron_format, date)
        [result | get_previous_run_dates_relative_to(n - 1, cron_expression, Timex.shift(run_date, seconds: -1), true)]
      error = {:error, _} -> error
    end
  end


  @doc """
  Check if now matches a given string of an eventually extended cron expression.

  ### Examples

      iex> Crontab.matches_date("*/2 * * * *")
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *")
      {:ok, false}

      iex> Crontab.matches_date("*/2 * * * *", true)
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *", false)
      {:ok, false}

  """
  @spec matches_date(binary, boolean) :: {:ok, boolean} | CronExpression.Parser.result
  def matches_date(cron_expression, extended \\ false) do
    date = DateTime.to_naive(DateTime.utc_now)
    matches_date_relative_to(cron_expression, date, extended)
  end

  @doc """
  Check if given date matches a given string of an eventually extended cron
  expression.

  ### Examples

      iex> Crontab.matches_date_relative_to("*/2 * * * *", ~N[2016-12-17 00:02:00])
      {:ok, true}

      iex> Crontab.matches_date_relative_to("*/7 * * * *", ~N[2016-12-17 00:06:00])
      {:ok, false}

      iex> Crontab.matches_date_relative_to("*/2 * * * *", ~N[2016-12-17 00:02:00], true)
      {:ok, true}

      iex> Crontab.matches_date_relative_to("*/7 * * * *", ~N[2016-12-17 00:06:00], false)
      {:ok, false}

  """
  @spec matches_date_relative_to(binary, NaiveDateTime.t, boolean) :: {:ok, boolean} | CronExpression.Parser.result
  def matches_date_relative_to(cron_expression, date, extended \\ false) do
    case Parser.parse(cron_expression, extended) do
      {:ok, cron_format} -> {:ok, DateChecker.matches_date(cron_format, date)}
      error = {:error, _} -> error
    end
  end
end
