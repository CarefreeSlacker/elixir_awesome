defmodule ElixirAwesomeWeb.PageController do
  use ElixirAwesomeWeb, :controller
  alias ElixirAwesome.DomainModel.Context
  alias ElixirAwesome.GithubData.Api
  alias ElixirAwesome.External.RefreshDataService

  def index(conn, params) do
    sections_with_libraries =
      Context.sections_with_libraries(%{min_stars: Map.get(params, "min_stars")})

    {processed_count, processing} =
      case Api.get_get_processed_count() do
        {:ok, count} -> {count, true}
        {:error, _reason} -> {"No processing", false}
      end

    render(conn, "index.html",
      sections: sections_with_libraries,
      processed_count: processed_count,
      processing: processing
    )
  end

  def update(conn, _params) do
    RefreshDataService.perform()

    redirect(conn, to: "/")
  end
end
