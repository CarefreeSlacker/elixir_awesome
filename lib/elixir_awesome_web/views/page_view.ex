defmodule ElixirAwesomeWeb.PageView do
  use ElixirAwesomeWeb, :view

  alias ElixirAwesome.Utils.Presenter

  def name_to_link(name) do
    name
    |> name_to_link_id()
    |> (fn prepared_name -> "#" <> prepared_name end).()
  end

  def name_to_link_id(name) do
    name
    |> String.replace(" ", "-")
    |> String.downcase()
  end

  def calculate_days_ago(last_commit_date_time) do
    Presenter.days_between(last_commit_date_time, NaiveDateTime.utc_now())
  end
end
