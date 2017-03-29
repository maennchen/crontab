defmodule Crontab.DateLibrary do
  @moduledoc """
  This Behaviour offers Date Library Independant integration of helper
  functions.

  **This behavious is considered internal. Breaking Changes can occur on every
  release.**

  Make sure your implementation passes `Crontab.DateLibraryTest`. Otherwise
  unexpected behaviour can occur.
  """

  @type time_unit :: :days | :hours | :minutes | :seconds | :years | :months

  @callback shift(NaiveDateTime.t, integer, time_unit) :: NaiveDateTime.t

  @callback beginning_of_year(NaiveDateTime.t) :: NaiveDateTime.t

  @callback end_of_year(NaiveDateTime.t) :: NaiveDateTime.t

  @callback beginning_of_month(NaiveDateTime.t) :: NaiveDateTime.t

  @callback end_of_month(NaiveDateTime.t) :: NaiveDateTime.t

  @callback beginning_of_day(NaiveDateTime.t) :: NaiveDateTime.t

  @callback end_of_day(NaiveDateTime.t) :: NaiveDateTime.t
end
