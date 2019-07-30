defmodule ElixirAwesome.DomainModel.ContextTest do
  @moduledoc false

  use ElixirAwesome.DataCase
  alias ElixirAwesome.DomainModel.{Context, Library, Section}

  describe "#create_library" do
    test "Create library if it's valid" do
      before_libraries_count = Repo.aggregate(Library, :count, :id)
      {:ok, %{id: section_id}} = Factory.create(:section)

      library_attrs = Map.put(Factory.default_attrs(:library), :section_id, section_id)
      assert {:ok, %Library{}} = Context.create_library(library_attrs)

      assert before_libraries_count + 1 == Repo.aggregate(Library, :count, :id)
    end

    test "Does not create library" do
      before_libraries_count = Repo.aggregate(Library, :count, :id)

      assert {:error, %Ecto.Changeset{errors: [section_id: {_, [validation: :required]}]}} =
               Context.create_library(Factory.default_attrs(:library))

      assert before_libraries_count == Repo.aggregate(Library, :count, :id)
    end
  end
end
