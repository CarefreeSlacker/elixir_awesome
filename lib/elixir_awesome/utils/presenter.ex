defmodule ElixirAwesome.Utils.Presenter do
  @moduledoc """
  Contains functions for visualisation of the data
  """

  @doc """
  Calculate whole days count between two days
  """
  @spec days_between(NaiveDateTime.t(), NaiveDateTime.t()) :: integer
  def days_between(first_date, second_date) do
    NaiveDateTime.diff(first_date, second_date)
    |> abs()
    |> (fn seconds_count -> div(seconds_count, 24 * 60 * 60) end).()
  end
end
