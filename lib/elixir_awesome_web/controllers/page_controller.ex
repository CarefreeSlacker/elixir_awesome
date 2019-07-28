defmodule ElixirAwesomeWeb.PageController do
  use ElixirAwesomeWeb, :controller
  alias ElixirAwesome.DomainModel.Context
  alias ElixirAwesome.GithubData.Api

  def index(conn, params) do
    sections_with_libraries =
      Context.sections_with_libraries(%{min_stars: Map.get(params, "min_stars")})

    processed_status =
      case Api.get_processed_status() do
        {:ok, processed_status} -> processed_status
        {:error, reason} -> "No processing"
      end

    render(conn, "index.html",
      sections: sections_with_libraries,
      processed_status: processed_status
    )
  end
end
