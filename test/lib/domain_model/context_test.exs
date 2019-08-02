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

  describe "#update_library" do
    test "Update library if params is valid" do
      {:ok, library} = Factory.create(:library)

      new_name = "NewName"
      new_stars = :rand.uniform(99_999)
      new_attrs = %{name: new_name, stars: new_stars}

      assert {:ok, %Library{name: ^new_name, stars: ^new_stars}} =
               Context.update_library(library, new_attrs)
    end

    test "Does not update library if params invalid" do
      {:ok, %{id: library_id, name: old_name, stars: old_stars} = library} =
        Factory.create(:library)

      new_attrs = %{name: nil, stars: -1, url: nil, last_commit: nil, comment: nil}

      assert {:error, %Ecto.Changeset{errors: errors}} =
               Context.update_library(library, new_attrs)

      assert Enum.any?(errors, fn {field_name, _details} -> field_name == :stars end)
      assert Enum.any?(errors, fn {field_name, _details} -> field_name == :name end)
      assert Enum.any?(errors, fn {field_name, _details} -> field_name == :url end)
      assert Enum.any?(errors, fn {field_name, _details} -> field_name == :last_commit end)
      assert length(errors) == 4

      assert %Library{name: ^old_name, stars: ^old_stars} = Repo.get(Library, library_id)
    end
  end

  describe "#delete_library" do
    test "Delete existing library" do
      {:ok, %{id: library_id} = library} = Factory.create(:library)

      assert {:ok, %Library{id: ^library_id}} = Context.delete_library(library)

      assert is_nil(Repo.get(Library, library_id))
    end
  end

  describe "#create_section" do
    test "Create section if it's valid" do
      before_sections_count = Repo.aggregate(Section, :count, :id)

      assert {:ok, %Section{}} = Context.create_section(Factory.default_attrs(:section))

      assert before_sections_count + 1 == Repo.aggregate(Section, :count, :id)
    end

    test "Does not create section" do
      before_sections_count = Repo.aggregate(Section, :count, :id)

      assert {:error, %Ecto.Changeset{errors: [name: {_, [validation: :required]}]}} =
               Context.create_section(Map.put(Factory.default_attrs(:section), :name, nil))

      assert before_sections_count == Repo.aggregate(Section, :count, :id)
    end
  end

  describe "#update_section" do
    test "Update section if params is valid" do
      {:ok, section} = Factory.create(:section)

      new_name = "NewName"
      new_attrs = %{name: new_name}

      assert {:ok, %Section{name: ^new_name}} = Context.update_section(section, new_attrs)
    end

    test "Does not update section if params invalid" do
      {:ok, %{id: section_id, name: old_name, comment: old_comment} = section} =
        Factory.create(:section)

      new_attrs = %{name: nil, comment: nil}

      assert {:error, %Ecto.Changeset{errors: errors}} =
               Context.update_section(section, new_attrs)

      assert Enum.any?(errors, fn {field_name, _details} -> field_name == :name end)
      assert length(errors) == 1

      assert %Section{name: ^old_name, comment: ^old_comment} = Repo.get(Section, section_id)
    end
  end

  describe "#delete_section" do
    test "Delete existing section" do
      {:ok, %{id: section_id} = section} = Factory.create(:section)

      assert {:ok, %Section{id: ^section_id}} = Context.delete_section(section)

      assert is_nil(Repo.get(Section, section_id))
    end
  end

  describe "#sections_with_libraries #1 without min_stars param" do
    test "Does not return sections if they does not have libraries" do
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)

      assert 5 == Repo.aggregate(Section, :count, :id)
      assert 0 == Repo.aggregate(Library, :count, :id)

      assert [] = Context.sections_with_libraries()
    end

    test "Return sections if they have libraries" do
      Factory.create(:section)
      {:ok, %{id: section1_id}} = Factory.create(:section, %{name: "B"})
      Factory.create(:section)
      Factory.create(:section)
      {:ok, %{id: section2_id}} = Factory.create(:section, %{name: "A"})
      {:ok, %{id: library1_id}} = Factory.create(:library, %{section_id: section1_id})
      {:ok, %{id: library2_id}} = Factory.create(:library, %{section_id: section2_id})
      {:ok, %{id: library3_id}} = Factory.create(:library, %{section_id: section2_id})
      {:ok, %{id: library4_id}} = Factory.create(:library, %{section_id: section2_id})
      {:ok, %{id: library5_id}} = Factory.create(:library, %{section_id: section2_id})

      assert 5 == Repo.aggregate(Section, :count, :id)
      assert 5 == Repo.aggregate(Library, :count, :id)

      assert [
               %Section{
                 id: ^section2_id,
                 libraries: libraries
               },
               %Section{id: ^section1_id, libraries: [%Library{id: ^library1_id}]}
             ] = Context.sections_with_libraries()

      assert [
               %Library{id: ^library2_id},
               %Library{id: ^library3_id},
               %Library{id: ^library4_id},
               %Library{id: ^library5_id}
             ] = Enum.sort_by(libraries, fn %{id: id} -> id end)
    end
  end

  describe "#sections_with_libraries #1 with min_stars param" do
    test "Does not return sections if they does not have libraries" do
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)
      Factory.create(:section)

      assert 5 == Repo.aggregate(Section, :count, :id)
      assert 0 == Repo.aggregate(Library, :count, :id)

      assert [] = Context.sections_with_libraries(%{min_stars: 0})
    end

    test "Return sections if they have libraries. Return only libraries those match clause" do
      Factory.create(:section)
      {:ok, %{id: section1_id}} = Factory.create(:section, %{name: "B"})
      Factory.create(:section)
      Factory.create(:section)
      {:ok, %{id: section2_id}} = Factory.create(:section, %{name: "A"})
      Factory.create(:library, %{section_id: section1_id, stars: 4})

      {:ok, %{id: library2_id}} =
        Factory.create(:library, %{section_id: section2_id, name: "B", stars: 10})

      {:ok, %{id: library3_id}} =
        Factory.create(:library, %{section_id: section2_id, name: "A", stars: 11})

      Factory.create(:library, %{section_id: section2_id, name: "C", stars: 4})
      Factory.create(:library, %{section_id: section2_id, name: "D", stars: 3})

      :timer.sleep(100)

      assert 5 == Repo.aggregate(Section, :count, :id)
      assert 5 == Repo.aggregate(Library, :count, :id)

      assert [%Section{id: ^section2_id, libraries: libraries}] =
               Context.sections_with_libraries(%{min_stars: 5})

      assert [
               %Library{id: ^library3_id},
               %Library{id: ^library2_id}
             ] = libraries
    end

    test "Does not return sections if they does not satisfy given min_stars clause" do
      Factory.create(:section)
      {:ok, %{id: section1_id}} = Factory.create(:section, %{name: "A"})
      Factory.create(:section)
      Factory.create(:section)
      {:ok, %{id: section2_id}} = Factory.create(:section, %{name: "B"})
      Factory.create(:library, %{section_id: section1_id, stars: 4})
      Factory.create(:library, %{section_id: section2_id, stars: 10})
      Factory.create(:library, %{section_id: section2_id, stars: 11})
      Factory.create(:library, %{section_id: section2_id, stars: 4})
      Factory.create(:library, %{section_id: section2_id, stars: 3})

      assert 5 == Repo.aggregate(Section, :count, :id)
      assert 5 == Repo.aggregate(Library, :count, :id)
      assert [] = Context.sections_with_libraries(%{min_stars: 20})
    end
  end

  describe "#section_by_name" do
    test "Return section if section with such name exist" do
      {:ok, %Section{id: section_id, name: name}} = Factory.create(:section)

      assert %Section{id: ^section_id, name: ^name} = Context.section_by_name(name)
    end

    test "Return nil if section does not exist" do
      assert is_nil(Context.section_by_name("RandomName#{:rand.uniform(99999)}"))
    end
  end

  describe "#library_by_name" do
    test "Return library if library with such name exist" do
      {:ok, %Library{id: library_id, name: name}} = Factory.create(:library)

      assert %Library{id: ^library_id, name: ^name} = Context.library_by_name(name)
    end

    test "Return nil if library does not exist" do
      assert is_nil(Context.library_by_name("RandomName#{:rand.uniform(99999)}"))
    end
  end
end
