defmodule Clique5Test do
  use ExUnit.Case
  alias Clique5

  @moduletag timeout: :infinity

  test "Case 1" do
    assert Clique5.find_cliques() == 538
  end

  test "Case 2" do
    proper_words = ["abcde", "fghij", "klmno", "pqrst", "uvwxy", "afkpq"]
    # words = proper_words ++ ["bcdef", "ghijk", "lmnop", "qrstu", "vwxyz"]
    assert result = Clique5.find_cliques(proper_words)
  end

  test "Case 3" do
    words = [
      "ambry",
      "fldxt",
      "pucks",
      "vejoz",
      "whing",
      "pungs",
      "whick",
      "spung",
      "ampyx",
      "bejig",
      "fconv",
      "hdqrs",
      "klutz",
      "bewig"
    ]

    solution = [
      ["ambry", "fldxt", "pucks", "vejoz", "whing"],
      ["ambry", "fldxt", "pungs", "vejoz", "whick"],
      ["ambry", "fldxt", "spung", "vejoz", "whick"],
      ["ampyx", "bejig", "fconv", "hdqrs", "klutz"],
      ["ampyx", "bewig", "fconv", "hdqrs", "klutz"]
    ]

    assert solution == Clique5.find_cliques(words)
  end
end
