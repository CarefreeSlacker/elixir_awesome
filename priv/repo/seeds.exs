# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirAwesome.Repo.insert!(%ElixirAwesome.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirAwesome.DomainModel.Context

sections_attrs = [
  %{name: "Actors", comment: "Libraries and tools for working with actors and such."},
  %{name: "Authentication", comment: "Libraries for implementing authentication schemes."},
  %{name: "Documentation", comment: "Libraries and tools for creating documentation."}
]

libraries_attrs = [
  [
    %{
      name: "dflow",
      stars: 20,
      url: "https://github.com/dalmatinerdb/dflow",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Pipelined flow processing engine."
    },
    %{
      name: "exactor",
      stars: 20,
      url: "https://github.com/sasa1977/exactor",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Helpers for easier implementation of actors in Elixir."
    },
    %{
      name: "exos",
      stars: 20,
      url: "https://github.com/awetzel/exos",
      last_commit: NaiveDateTime.utc_now(),
      comment: "A Port Wrapper which forwards cast and call to a linked Port."
    },
    %{
      name: "flowex",
      stars: 20,
      url: "https://github.com/antonmi/flowex",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Railway Flow-Based Programming with Elixir GenStage."
    },
    %{
      name: "mon_handler",
      stars: 60,
      url: "https://github.com/tattdcodemonkey/mon_handler",
      last_commit: NaiveDateTime.utc_now(),
      comment: "A minimal GenServer that monitors a given GenEvent handler."
    },
    %{
      name: "pool_ring",
      stars: 60,
      url: "https://github.com/camshaft/pool_ring",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Create a pool based on a hash ring."
    }
  ],
  [
    %{
      name: "aeacus",
      stars: 60,
      url: "https://github.com/zmoshansky/aeacus",
      last_commit: NaiveDateTime.utc_now(),
      comment:
        "A simple configurable identity/password authentication module (Compatible with Ecto/Phoenix)."
    },
    %{
      name: "apache_passwd_md5",
      stars: 150,
      url: "https://github.com/kevinmontuori/Apache.PasswdMD5",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Apache/APR Style Password Hashing."
    },
    %{
      name: "aws_auth",
      stars: 150,
      url: "https://github.com/bryanjos/aws_auth",
      last_commit: NaiveDateTime.utc_now(),
      comment: "AWS Signature Version 4 Signing Library for Elixir."
    },
    %{
      name: "basic_auth",
      stars: 150,
      url: "https://github.com/CultivateHQ/basic_auth",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Elixir Plug to easily add HTTP basic authentication to an app."
    },
    %{
      name: "coherence",
      stars: 150,
      url: "https://github.com/smpallen99/coherence",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Coherence is a full featured, configurable authentication system for Phoenix."
    },
    %{
      name: "doorman",
      stars: 150,
      url: "https://github.com/BlakeWilliams/doorman",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Tools to make Elixir authentication simple and flexible."
    },
    %{
      name: "github_oauth",
      stars: 170,
      url: "https://github.com/lidashuang/github_oauth",
      last_commit: NaiveDateTime.utc_now(),
      comment: "A simple github oauth library."
    },
    %{
      name: "goth",
      stars: 170,
      url: "https://github.com/peburrows/goth",
      last_commit: NaiveDateTime.utc_now(),
      comment: "OAuth 2.0 library for server to server applications via Google Cloud APIs."
    },
    %{
      name: "guardian",
      stars: 170,
      url: "https://github.com/ueberauth/guardian",
      last_commit: NaiveDateTime.utc_now(),
      comment: "An authentication framework for use with Elixir applications."
    },
    %{
      name: "htpasswd",
      stars: 170,
      url: "https://github.com/kevinmontuori/Apache.htpasswd",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Apache htpasswd file reader/writer in Elixir."
    }
  ],
  [
    %{
      name: "blue_bird",
      stars: 300,
      url: "https://github.com/KittyHeaven/blue_bird",
      last_commit: NaiveDateTime.utc_now(),
      comment:
        "BlueBird is a library written in the Elixir programming language for the Phoenix framework. It lets you generate API documentation in the API Blueprint format from annotations in controllers and automated tests."
    },
    %{
      name: "bureaucrat",
      stars: 300,
      url: "https://github.com/api-hogs/bureaucrat",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Generate Phoenix API documentation from tests."
    },
    %{
      name: "ex_doc",
      stars: 300,
      url: "https://github.com/elixir-lang/ex_doc",
      last_commit: NaiveDateTime.utc_now(),
      comment: "ExDoc is a tool to generate documentation for your Elixir projects."
    },
    %{
      name: "ex_doc_dash",
      stars: 300,
      url: "https://github.com/JonGretar/ExDocDash",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Formatter for ExDoc to generate docset documentation for use in Dash.app."
    },
    %{
      name: "hexdocset",
      stars: 300,
      url: "https://github.com/yesmeck/hexdocset",
      last_commit: NaiveDateTime.utc_now(),
      comment: "Convert hex doc to Dash.app's docset format."
    }
  ]
]

sections_attrs
|> Enum.with_index()
|> Enum.each(fn {section_attrs, index} ->
  {:ok, section} = Context.create_section(section_attrs)

  libraries_attrs
  |> Enum.at(index)
  |> Enum.map(& Map.put(&1, :section_id, section.id))
  |> Enum.map(& Context.create_library(&1))
end)
