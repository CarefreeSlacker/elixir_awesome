defmodule ElixirAwesome.Factories.LibraryFactory do
  @moduledoc false

  alias ElixirAwesome.Repo
  alias ElixirAwesome.DomainModel.{Context, Library}
  alias ElixirAwesome.Testing.Factory

  def create(attrs) do
    default_attrs
    |> Map.merge(attrs)
    |> create_section_if_does_not_exist()
    |> Context.create_library()
  end

  def default_attrs do
    %{
      name: "Section Name #{:rand.uniform(9999)}",
      stars: 5,
      url: "http://github.com/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}",
      last_commit:
        NaiveDateTime.add(NaiveDateTime.utc_now(), -(500 + :rand.uniform(24 * 60 * 60))),
      comment: "Section comment ##{:rand.uniform(9999)}"
    }
  end

  defp create_section_if_does_not_exist(%{section_id: section_id} = attrs)
       when not is_nil(section_id),
       do: attrs

  defp create_section_if_does_not_exist(attrs) do
    {:ok, %{id: section_id}} = Factory.create(:section)
    Map.put(attrs, :section_id, section_id)
  end
end
