defmodule CrontabTest do
  use ExUnit.Case
  doctest Crontab, except: [get_next_run_date: 1, matches_date: 1]
  import Crontab
end
