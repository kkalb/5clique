defmodule RandomWordsTest do
  use ExUnit.Case
  alias RandomWord

  @words ["Latiner", "nonvoluntary", "preprofess", "stairbeak", "waiterlike"]

  test "Case 1" do
    joined_random_words = @words |> RandomWord.wordlist_to_map() |> RandomWord.new(5)

    assert String.split(joined_random_words, "-") |> Enum.sort() == @words
  end
end
