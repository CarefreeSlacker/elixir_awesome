defmodule ElixirAwesome.External.ParserTest do
  @moduledoc false

  use ElixirAwesome.TestCase
  alias ElixirAwesome.External.Parser

  describe "#parse" do
    test "Parse given file" do
      {:ok, markdown} = File.read("#{File.cwd!()}/test/fixtures/markdown.md")

      standard =
        {:ok,
         [
           %{
             comment: "Libraries and tools for working with actors and such.",
             libraries: [
               %{
                 comment: "Pipelined flow processing engine.",
                 name: "dflow",
                 url: "https://github.com/dalmatinerdb/dflow"
               },
               %{
                 comment: "Helpers for easier implementation of actors in Elixir.",
                 name: "exactor",
                 url: "https://github.com/sasa1977/exactor"
               },
               %{
                 comment: "A Port Wrapper which forwards cast and call to a linked Port.",
                 name: "exos",
                 url: "https://github.com/awetzel/exos"
               }
             ],
             name: "Actors"
           },
           %{
             comment: "Libraries and implementations of algorithms and data structures.",
             libraries: [
               %{
                 comment: "An Elixir wrapper library for Erlang's .",
                 name: "array",
                 url: "https://github.com/takscape/elixir-array"
               },
               %{
                 comment:
                   "Aruspex is a configurable constraint solver, written purely in Elixir.",
                 name: "aruspex",
                 url: "https://github.com/dkendal/aruspex"
               },
               %{
                 comment: "Pure Elixir implementation of  and multimaps.bidirectional maps",
                 name: "bimap",
                 url: "https://github.com/mkaput/elixir-bimap"
               },
               %{
                 comment: "Pure Elixir implementation of .s",
                 name: "bitmap",
                 url: "https://github.com/hashd/bitmap-elixir"
               }
             ],
             name: "Algorithms and Data structures"
           }
         ]}

      assert standard == Parser.perform(markdown)
    end

    test "Return error if wrong markdown given" do
      assert {:error, :invalid_xml} == Parser.perform("dfgdgf")
    end
  end
end
