defmodule ElixirAwesome.Utils.PresenterTest do
  @moduledoc false

  use ElixirAwesome.TestCase
  alias ElixirAwesome.Utils.Presenter

  describe "#days_between" do
    test "calculate days count between date_times #1" do
      date_time1 = %NaiveDateTime{
        year: 2019,
        month: 4,
        day: 7,
        hour: 13,
        minute: 13,
        second: 13
      }

      date_time2 = %NaiveDateTime{
        year: 2019,
        month: 4,
        day: 4,
        hour: 11,
        minute: 13,
        second: 13
      }

      assert 3 == Presenter.days_between(date_time1, date_time2)
    end

    test "calculate days count between date_times #2" do
      date_time1 = %NaiveDateTime{
        year: 2019,
        month: 5,
        day: 4,
        hour: 13,
        minute: 13,
        second: 13
      }

      date_time2 = %NaiveDateTime{
        year: 2019,
        month: 7,
        day: 18,
        hour: 23,
        minute: 13,
        second: 13
      }

      assert 75 == Presenter.days_between(date_time1, date_time2)
    end

    test "calculate days count between date_times #3" do
      date_time1 = %NaiveDateTime{
        year: 2017,
        month: 4,
        day: 4,
        hour: 11,
        minute: 00,
        second: 00
      }

      date_time2 = %NaiveDateTime{
        year: 2019,
        month: 7,
        day: 4,
        hour: 23,
        minute: 13,
        second: 13
      }

      assert 821 == Presenter.days_between(date_time1, date_time2)
    end
  end
end
