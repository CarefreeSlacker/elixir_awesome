defmodule ElixirAwesome.External.DatabaseRecordsServiceTest do
  @moduledoc false

  use ElixirAwesome.DataCase
  alias ElixirAwesome.DomainModel.{Context, Section}
  alias ElixirAwesome.External.DatabaseRecordsService

  describe "#create_sections" do
    test "Create of update sections by given params. Find records by name." do
      {:ok, %{name: existing_name1}} = Factory.create(:section, %{comment: "Existing comment1"})
      {:ok, %{name: existing_name2}} = Factory.create(:section, %{comment: "Existing comment2"})
      {:ok, %{name: unapdeted_name, comment: unapdeted_comment}} = Factory.create(:section)

      new_name1 = "New name1"
      new_name2 = "New name2"
      before_sections_count = Repo.aggregate(Section, :count, :id)

      assert is_nil(Context.section_by_name(new_name1))
      assert is_nil(Context.section_by_name(new_name2))

      DatabaseRecordsService.create_sections([
        %{name: existing_name1, comment: "New comment1"},
        %{name: existing_name2, comment: "New comment2"},
        %{name: new_name1, comment: "New comment3"},
        %{name: new_name2, comment: "New comment4"}
      ])

      refute is_nil(Context.section_by_name(new_name1))
      refute is_nil(Context.section_by_name(new_name2))

      assert %{name: ^existing_name1, comment: "New comment1"} =
               Context.section_by_name(existing_name1)

      assert %{name: ^existing_name2, comment: "New comment2"} =
               Context.section_by_name(existing_name2)

      assert %{name: ^unapdeted_name, comment: ^unapdeted_comment} =
               Context.section_by_name(unapdeted_name)

      assert before_sections_count + 2 == Repo.aggregate(Section, :count, :id)
    end

    test "Raise error if there validation error" do
      assert_raise(ArgumentError, fn ->
        DatabaseRecordsService.create_sections([%{name: nil, comment: "Does not matter"}])
      end)
    end
  end

  describe "#add_section_id_to_libraries_data" do
    test "Add section data to libraries data" do
      {:ok, %{id: section_id1, name: name1, comment: comment1} = section1} =
        Factory.create(:section)

      {:ok, %{id: section_id2, name: name2, comment: comment2} = section2} =
        Factory.create(:section)

      {:ok, %{id: section_id3, name: name3, comment: comment3} = section3} =
        Factory.create(:section)

      libraries1 = [%{name: "L11"}, %{name: "L12"}, %{name: "L13"}, %{name: "L14"}]
      libraries2 = [%{name: "L21"}, %{name: "L22"}, %{name: "L23"}]
      libraries3 = [%{name: "L31"}, %{name: "L32"}]

      raw_sections_data = [
        %{name: name1, comment: comment1, libraries: libraries1},
        %{name: name2, comment: comment2, libraries: libraries2},
        %{name: name3, comment: comment3, libraries: libraries3}
      ]

      standard =
        [
          Enum.map(libraries1, &Map.put(&1, :section_id, section_id1)),
          Enum.map(libraries2, &Map.put(&1, :section_id, section_id2)),
          Enum.map(libraries3, &Map.put(&1, :section_id, section_id3))
        ]
        |> Enum.flat_map(fn libs -> libs end)
        |> Enum.sort_by(fn %{section_id: id} -> id end)

      assert {:ok, result} =
               DatabaseRecordsService.add_section_id_to_libraries_data(
                 [section1, section2, section3],
                 raw_sections_data
               )

      assert Enum.sort_by(result, fn %{section_id: id} -> id end) == standard
    end
  end
end
