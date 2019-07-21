defmodule ElixirAwesomeWeb.PageController do
  use ElixirAwesomeWeb, :controller
  alias ElixirAwesome.DomainModel.Context

  def index(conn, params) do
    sections_with_libraries =
      Context.sections_with_libraries(%{min_stars: Map.get(params, "min_stars")})

    render(conn, "index.html", sections: sections_with_libraries)
  end
end
