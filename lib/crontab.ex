defmodule Crontab do
  @moduledoc """
  This Library is built to parse & write cron expressions, test them against a
  given date and finde the next execution date.

  In the main module defined are helper functions which work directlyfrom a
  string cron expression.
  """

  @doc """
  Find the next execution date relative to now for a string cron expression.

  ### Examples

      iex> Crontab.get_next_run_date("* * * * *")
      {:ok, ~N[2016-12-23 16:00:00.348751]}

  """
  def get_next_run_date(cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_next_run_date(cron_expression, date)
  end

  @doc """
  Find the next execution date relativ to a given date for a string cron
  expression.

  ### Examples

      iex> Crontab.get_next_run_date("* * * * *", ~N[2016-12-17 00:00:00])
      {:ok, ~N[2016-12-17 00:00:00]}

  """
  def get_next_run_date(cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} -> Crontab.CronScheduler.get_next_run_date(cron_format, date)
      error = {:error, _} -> error
    end
  end

  @doc """
  Check if now matches a given string cron expression.

  ### Examples

      iex> Crontab.matches_date("*/2 * * * *")
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *")
      {:ok, false}

  """
  def matches_date(cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    matches_date(cron_expression, date)
  end



  @doc """
  Check if given date matches a given string cron expression.

  ### Examples

      iex> Crontab.matches_date("*/2 * * * *", ~N[2016-12-17 00:02:00])
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *", ~N[2016-12-17 00:06:00])
      {:ok, false}

  """
  def matches_date(cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} -> {:ok, Crontab.CronDateChecker.matches_date(cron_format, date)}
      error = {:error, _} -> error
    end
  end
end
