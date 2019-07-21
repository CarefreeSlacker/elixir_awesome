defmodule ElixirAwesome.External.Parser do
  @moduledoc """
  Parse given markdown and return two lists those contains sections data and libraries data.
  """

  import SweetXml

  @doc """
  Gets markdown and returns {:ok, {sections_data, libraries_data}} | {:error, reason}
  """
  @spec perform(binary) :: {:ok, {list(map), list(map)}} | {:error, term}
  def perform(markdown) do
    with xml <- Cmark.to_xml() do

    else
      error -> error
    end
    {:ok, {[], []}}
  end
end
