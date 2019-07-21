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
    with parsed_xml <- markdown_to_parsed_xml(markdown),
         sections_data <- get_sections_data(parsed_xml),
         libraries_data <- get_libraries_data(parsed_xml, sections_data) do
      {:ok, {sections_data, libraries_data}}
    else
      error -> error
    end
  end

  defp markdown_to_parsed_xml(markdown) do
    markdown
    |> Cmark.to_xml()
    |> String.replace("<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n", "")
    |> parse()
  end

  defp get_sections_data(parsed_xml) do
    []
  end

  defp get_libraries_data(parsed_xml, sections_data) do
    []
  end
end
