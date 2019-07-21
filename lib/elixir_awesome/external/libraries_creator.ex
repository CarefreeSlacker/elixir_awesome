defmodule ElixirAwesome.External.LibrariesCreator do
  @moduledoc """
  Gets sections data and libraries data and create or update database records.
  """

  @doc """
  Gets
  """
  @spec perform(list(map), list(map)) :: {:ok, {list(map), list(map)}} | {:error, term}
  def perform(sections_data, libraries_data) do

    {:ok, {[], []}}
  end
end
