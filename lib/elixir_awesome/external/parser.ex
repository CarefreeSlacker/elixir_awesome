defmodule ElixirAwesome.External.Parser do
  @moduledoc """
  Parse given markdown and return two lists those contains sections data and libraries data.
  """

  import SweetXml

  @doc """
  Gets markdown and returns {:ok, sections_data} | {:error, reason}
  Sections data contains data for sections with data about libraries
  Looks like:

  ```
  [
    %{
      name: "Actors",
      comment: "Libraries for working with Actors",
      libraries: [
        %{
          name: "dflow",
          url: "https://github.com/dalmatinerdb/dflow",
          comment: "Pipelined flow processing engine."
        },
        ...
      ]
    }
  ]
  ```
  """
  @spec perform(binary) :: {:ok, list(map)} | {:error, :invalid_xml}
  def perform(markdown) do
    with parsed_xml <- markdown_to_parsed_xml(markdown),
         sections_data when sections_data != [] <- get_sections_data(parsed_xml),
         full_sections_data when full_sections_data != [] <-
           get_libraries_data(parsed_xml, sections_data) do
      {:ok, full_sections_data}
    else
      error -> {:error, :invalid_xml}
    end
  end

  defp markdown_to_parsed_xml(markdown) do
    markdown
    |> Cmark.to_xml()
    |> String.replace("<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n", "")
    |> parse()
  end

  defp get_sections_data(parsed_xml) do
    parsed_xml
    |> select_section_names()
    |> Enum.map(fn section_name ->
      %{
        name: section_name,
        comment: select_section_comment(parsed_xml, section_name)
      }
    end)
  end

  defp select_section_names(parsed_xml) do
    xpath(
      parsed_xml,
      ~x"//list[@type=\"bullet\"][1]/item/list[@type=\"bullet\"]/item//text/text()"ls
    )
  end

  defp select_section_comment(parsed_xml, section_name) do
    xpath(
      parsed_xml,
      ~x"#{libraries_section_selector(section_name)}/following-sibling::paragraph[1]//text/text()"s
    )
  end

  defp libraries_section_selector(section_name) do
    "//heading[@level=\"2\"]//.[text()=\"#{section_name}\"]/.."
  end

  def get_libraries_data(parsed_xml, sections_data) do
    sections_data
    |> Enum.map(fn %{name: section_name} = section_data ->
      section_libraries =
        parsed_xml
        |> xpath(
          ~x"#{libraries_section_selector(section_name)}/following-sibling::paragraph[1]/following-sibling::list[1]"
        )
        |> xpath(~x"//item/paragraph"l)
        |> Enum.map(fn section_library ->
          name =
            section_library
            |> xpath(~x"//link[1]/text/text()"ls)
            |> Enum.join("")

          comment =
            section_library
            |> xpath(~x"//text/text()"ls)
            |> Enum.join("")
            |> String.replace(name, "")
            |> String.replace(" - ", "")

          %{
            name: name,
            url: xpath(section_library, ~x"//link/@destination"s),
            comment: comment
          }
        end)

      Map.put(section_data, :libraries, section_libraries)
    end)
  end
end
