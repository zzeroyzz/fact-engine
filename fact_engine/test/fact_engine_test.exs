defmodule FactEngineTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    FactEngine.start()
    :ok
  end

  test "input commands" do
    assert :ok == FactEngine.input("likes(alex, sam)")
    assert :ok == FactEngine.input("likes(kato, kay)")
    assert :ok == FactEngine.input("likes(sam, sam)")
  end

  test "simple queries without variables" do
    FactEngine.input("likes(alex, sam)")
    assert [["alex", "sam"]] == FactEngine.query_facts("likes(alex, sam)")
  end

  test "queries with single variable" do
    FactEngine.input("likes(alex, sam)")
    assert [["sam"]] == FactEngine.query_facts("likes(alex, Y)")
  end

  test "queries with multiple variables" do
    FactEngine.input("likes(alex, sam)")
    FactEngine.input("likes(kato, kay)")

    assert [[%{"X" => "alex", "Y" => "sam"}], [%{"X" => "kato", "Y" => "kay"}]] ==
             FactEngine.query_facts("likes(X, Y)")
  end

  test "self-reference queries" do
    FactEngine.input("likes(sam, sam)")
    assert [["sam"]] == FactEngine.query_facts("likes(Y, Y)")
  end

  test "file processing" do
    # Ensure this file exists with proper input and queries.
    file_path = "files/fact_file.txt"

    output =
      capture_io(fn ->
        FactEngine.process_file(file_path)
      end)

    assert String.contains?(output, "Result of query is_a_cat (x): [[\"lucy\"], [\"garfield\"]]")
    assert String.contains?(output, "Result of query likes (X, sam): [[\"alex\"], [\"sam\"]]")
  end
end
