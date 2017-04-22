defmodule Crontab.DateLibraryTest do
  use ExUnit.Case, async: true

  @implementations [Crontab.DateLibrary.Timex]

  @shift_tests [{"add seconds", ~N[2016-01-01 01:01:01], {66,  :seconds}, ~N[2016-01-01 01:02:07]},
                {"sub seconds", ~N[2016-01-01 01:01:01], {-66, :seconds}, ~N[2016-01-01 00:59:55]},
                {"add minutes", ~N[2016-01-01 01:01:01], {66,  :minutes}, ~N[2016-01-01 02:07:01]},
                {"sub minutes", ~N[2016-01-01 01:01:01], {-66, :minutes}, ~N[2015-12-31 23:55:01]},
                {"add hours",   ~N[2016-01-01 01:01:01], {66,  :hours},   ~N[2016-01-03 19:01:01]},
                {"sub hours",   ~N[2016-01-01 01:01:01], {-66, :hours},   ~N[2015-12-29 07:01:01]},
                {"add days",    ~N[2016-01-01 01:01:01], {66,  :days},    ~N[2016-03-07 01:01:01]},
                {"sub days",    ~N[2016-01-01 01:01:01], {-66, :days},    ~N[2015-10-27 01:01:01]},
                {"add weeks",   ~N[2016-01-01 01:01:01], {66,  :weeks},   ~N[2017-04-07 01:01:01]},
                {"sub weeks",   ~N[2016-01-01 01:01:01], {-66, :weeks},   ~N[2014-09-26 01:01:01]},
                {"add months",  ~N[2016-01-01 01:01:01], {66,  :months},  ~N[2021-07-01 01:01:01]},
                {"sub months",  ~N[2016-01-01 01:01:01], {-66, :months},  ~N[2010-07-01 01:01:01]},
                {"add years",   ~N[2016-01-01 01:01:01], {66,  :years},   ~N[2082-01-01 01:01:01]},
                {"sub years",   ~N[2016-01-01 01:01:01], {-66, :years},   ~N[1950-01-01 01:01:01]}]

  for module <- @implementations do
    @module module

    describe Atom.to_string(module) <> ".shift/3" do
      for {name, date_from, {amount, unit}, expected_date} <- @shift_tests do
        @name name
        @date_from date_from
        @amount amount
        @unit unit
        @expected_date expected_date

        test @name do
          assert @module.shift(@date_from, @amount, @unit) == @expected_date
        end
      end
    end
  end
end
