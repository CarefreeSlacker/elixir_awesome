defmodule ElixirAwesomeWeb.MainPageLive do
  @moduledoc """
  Perform exercise but with live view. To provide dynamical view of the refreshing and filtering process.
  """

  use Phoenix.LiveView

  alias ElixirAwesome.DomainModel.Context
  alias ElixirAwesome.External.RefreshDataService
  alias ElixirAwesome.GithubData.Api, as: GithubApi
  alias ElixirAwesome.Utils.Presenter

  @page_refresh_interval 1000

  # Callbacks
  def render(assigns) do
    ~L"""
    <div id="table-of-content" class="container">
    <div id="sections" class="container">
      <div>
        <section>
          <ul class="nav justify-content-center">
            <li class="nav-item">
              <btn class="nav-link active btn btn-primary" phx-click="filter_stars" phx-value=":none">All</btn>
            </li>
            <li class="nav-item">
              <btn class="nav-link active btn btn-primary" phx-click="filter_stars" phx-value="10">>= 10</btn>
            </li>
            <li class="nav-item">
              <btn class="nav-link active btn btn-primary" phx-click="filter_stars" phx-value="50">>= 50</btn>
            </li>
            <li class="nav-item">
              <btn class="nav-link active btn btn-primary" phx-click="filter_stars" phx-value="300">>= 300</btn>
            </li>
          </ul>
        </section>
      </div>
      <div>
      <%= if @processing do %>
        <btn class="active btn btn-primary disabled" phx-click="refresh" disabled>Refreshing ...</btn>
      <% else %>
        <btn class="active btn btn-primary" phx-click="refresh">Start refreshing</btn>
      <% end %>
      <p><%= @processed_count %></p>
      </div>
    </div>
    <h1 class="h1">Table of content</h1>
    <ul>
    <%= Enum.map(@sections, fn section -> %>
      <li>
        <a href="<%= name_to_link(section.name) %>">
          <%= section.name %>
        </a>
      </li>
    <% end) %>
    </ul>
    <div>
    <h1 class="h1">Libraries</h1>
    </div>
    <table class="table">
    <tr>
      <td>Package name</td>
      <td>Stars count</td>
      <td>Days since last commit</td>
      <td>Description</td>
    </tr>
    <%= Enum.map(@sections, fn section -> %>
      <tr>
        <td>
          <h2 class="h2" id="<%= name_to_link_id(section.name) %>">
            <a href="#table-of-content" class="btn" title="To tables of content">&#x2B06;</a>
            <%= section.name %>
          </h2>
        </td>
        <td colspan="3">
          <p><%= section.comment %></p>
        </td>
      </tr>
      <%= Enum.sort_by(section.libraries, & &1.name) |> Enum.map(fn library -> %>
        <tr>
          <td>
            <a href="<%= library.url %>">
              <%= library.name %>
            </a>
          </td>
          <td>Stars: <%= library.stars %></td>
          <td><%= calculate_days_ago(library.last_commit) %></td>
          <td><%= library.comment %></td>
        </tr>
      <% end) %>
    <% end) %>
    </table>
    </div>
    """
  end

  def mount(_params, socket) do
    if GithubApi.refreshing_github_data?(), do: schedule_refreshing()

    {:ok, set_socket_data(socket)}
  end

  def handle_info(:refresh, socket) do
    new_socket = set_socket_data(socket)
    if GithubApi.refreshing_github_data?(), do: schedule_refreshing()
    {:noreply, new_socket}
  end

  defp schedule_refreshing do
    Process.send_after(self(), :refresh, @page_refresh_interval)
  end

  defp set_socket_data(%{assigns: assigns} = socket) do
    min_stars = Map.get(assigns, :min_stars)
    sections_with_libraries = Context.sections_with_libraries(%{min_stars: min_stars})

    {processed_count, processing} =
      case GithubApi.get_get_processed_count() do
        {:ok, count} -> {count, true}
        {:error, _reason} -> {"No processing", false}
      end

    socket
    |> assign(:sections, sections_with_libraries)
    |> assign(:processed_count, processed_count)
    |> assign(:processing, processing)
  end

  def handle_event("refresh", _value, socket) do
    RefreshDataService.perform()
    schedule_refreshing()
    {:noreply, set_socket_data(socket)}
  end

  def handle_event("filter_stars", ":none", socket) do
    {:noreply, set_min_stars(socket, nil)}
  end

  def handle_event("filter_stars", value, socket) do
    {min_stars, ""} = Integer.parse(value)

    {:noreply, set_min_stars(socket, min_stars)}
  end

  def handle_event(_any_event, _any_value, socket) do
    {:noreply, socket}
  end

  defp set_min_stars(socket, min_stars) do
    socket
    |> assign(:min_stars, min_stars)
    |> set_socket_data()
  end

  # Helpers
  def name_to_link(name) do
    name
    |> name_to_link_id()
    |> (fn prepared_name -> "#" <> prepared_name end).()
  end

  def name_to_link_id(name) do
    name
    |> String.replace(" ", "-")
    |> String.downcase()
  end

  def calculate_days_ago(last_commit_date_time) do
    Presenter.days_between(last_commit_date_time, NaiveDateTime.utc_now())
  end
end
