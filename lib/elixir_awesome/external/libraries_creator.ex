defmodule ElixirAwesome.External.LibrariesCreator do
  @moduledoc """
  Gets sections data and libraries data and create or update database records.
  """

  @doc """
  Create, update or delete libraries by data given in sections_data
  """
  @spec perform(list(map)) :: {:ok, {{integer, integer}, {integer, integer}}} | {:error, term}
  def perform(sections_data) do
    {:ok, {{0, 0}, {0, 0}}}
  end
end
