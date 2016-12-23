defmodule CrontabTest do
  use ExUnit.Case
  doctest Crontab, except: [get_next_run_date: 1, get_next_run_dates: 2, get_previous_run_date: 1, get_previous_run_dates: 2, matches_date: 1]
end
