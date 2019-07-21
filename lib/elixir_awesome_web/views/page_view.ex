defmodule ElixirAwesomeWeb.PageView do
  use ElixirAwesomeWeb, :view

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
end
