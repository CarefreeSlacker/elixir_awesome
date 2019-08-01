defmodule ElixirAwesome.External.RefreshDataServiceTest do
  @moduledoc false

  use ElixirAwesome.DataCase

  import Mock

  alias ElixirAwesome.External.RefreshDataService
  alias ElixirAwesome.DomainModel.{Library, Section}
  alias ElixirAwesome.GithubData.Api

  describe "#perform" do
    test "Parse markdown. Create sections. Start Github download manager." do
      {:ok, markdown} = File.read("#{File.cwd!()}/test/fixtures/markdown.md")

      before_sections_count = Repo.aggregate(Section, :count, :id)
      before_libraries_count = Repo.aggregate(Library, :count, :id)

      with_mocks([
        {HTTPoison, [], get: fn _, _, _ -> {:ok, %HTTPoison.Response{body: markdown}} end},
        {Api, [], start_manager: fn _ -> {:ok, :pid} end}
      ]) do
        assert {:ok, _} = RefreshDataService.perform()

        assert_called(Api.start_manager(:_))
      end

      assert before_sections_count + 2 == Repo.aggregate(Section, :count, :id)
      assert before_libraries_count == Repo.aggregate(Library, :count, :id)
    end

    test "Return error if error occurred" do
      before_sections_count = Repo.aggregate(Section, :count, :id)
      before_libraries_count = Repo.aggregate(Library, :count, :id)

      with_mocks([
        {HTTPoison, [],
         get: fn _, _, _ -> {:ok, %HTTPoison.Response{body: "wrong markdown"}} end},
        {Api, [], start_manager: fn _ -> {:ok, :pid} end}
      ]) do
        assert {:error, :invalid_xml} = RefreshDataService.perform()

        refute called(Api.start_manager(:_))
      end

      assert before_sections_count == Repo.aggregate(Section, :count, :id)
      assert before_libraries_count == Repo.aggregate(Library, :count, :id)
    end
  end
end
