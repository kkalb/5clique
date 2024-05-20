defmodule Bench do
  def run() do
    words = RandomWord.wordlist_from_file()
    words_vec = RandomWordVector.wordlist_from_file()

    Benchee.run(
      %{
        "5_words" => fn -> RandomWord.new(words, 5) end,
        "5_words_vec" => fn -> RandomWordVector.new(words_vec, 5) end,
        "55_words" => fn -> RandomWord.new(words, 55) end,
        "55_words_vec" => fn -> RandomWordVector.new(words_vec, 55) end,
        "555_words" => fn -> RandomWord.new(words, 555) end,
        "555_words_vec" => fn -> RandomWordVector.new(words_vec, 555) end,
        "5555_words" => fn -> RandomWord.new(words, 5555) end,
        "5555_words_vec" => fn -> RandomWordVector.new(words_vec, 5555) end
      },
      # profile_after: true,
      unit_scaling: :smallest
    )
  end
end
