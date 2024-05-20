defmodule RandomWordVectorTest do
  use ExUnit.Case
  alias RandomWordVector

  @words ["Latiner", "nonvoluntary", "preprofess", "stairbeak", "waiterlike"]

  test "Case 2" do
    assert @words
           |> Arrays.new(implementation: Aja.Vector)
           |> RandomWordVector.new(5)
           |> String.split("-")
           |> Enum.sort() == @words
  end

  test "Case 3" do
    words = RandomWordVector.wordlist_from_file()
    expected_length = 5555
    rand_words = RandomWordVector.new(words, expected_length)
    assert rand_words |> String.split("-") |> Enum.uniq() |> Enum.count() == expected_length
  end
end
