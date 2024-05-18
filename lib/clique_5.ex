defmodule Clique5 do
  @moduledoc """

  URL

  DESCRIPTION
  """

  alias NimbleCSV.RFC4180, as: CSV

  @path "/workspaces/5clique/lib/data/words_alpha.txt"

  def find_cliques(words \\ get_words()) do
    words
    |> generate_graph()
    |> build_neighbors()
    |> solver(words)
    |> elem(1)
    |> Enum.map(fn word -> Enum.sort(word) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> IO.inspect()
  end

  defp solver(g, words) do
    IO.inspect(Enum.count(words), label: "amount of words")

    words
    |> Enum.with_index()
    |> Enum.reduce({g, []}, fn {word, idx}, {g, solutions} ->
      start = Time.utc_now()
      nbs_first = Graph.neighbors(g, word)

      # word: "abcde"
      # nbs_first: ["fghij", "klmno", "pqrst", "uvwxy"]
      res =
        Enum.flat_map(nbs_first, fn nb_first ->
          # nb_first: "fghij"
          # nbs_of_nb_first: ["abcde", "klmno", "pqrst", "uvwxy"]
          # nbs_common: ["klmno", "pqrst", "uvwxy"]
          nbs_of_nb_first = Graph.neighbors(g, nb_first)
          nbs_common = get_common_neighbors(nbs_first, nbs_of_nb_first)

          Enum.flat_map(nbs_common, fn nb_common ->
            # nbs_common: ["klmno", "pqrst", "uvwxy"]
            # nb_common: "klmno"
            # nbs_of_nb_common: ["abcde", "fghij", "pqrst", "uvwxy"]
            nbs_of_nb_common = Graph.neighbors(g, nb_common)
            # nbs_common_level_2: ["pqrst", "uvwxy"]
            nbs_common_level_2 = get_common_neighbors(nbs_common, nbs_of_nb_common)

            Enum.flat_map(nbs_common_level_2, fn nb_of_nb_common ->
              # nbs_common_level_2: ["pqrst", "uvwxy"]
              # nb_common: "pqrst"
              # nbs_of_nb_common: ["abcde", "fghij", "klmno", "uvwxy"]
              nbs_of_nb_of_nb_common = Graph.neighbors(g, nb_of_nb_common)
              # nbs_common_level_3: ["uvwxy"]
              nbs_common_level_3 =
                get_common_neighbors(nbs_common_level_2, nbs_of_nb_of_nb_common)

              for last <- nbs_common_level_3,
                  do: [word, nb_first, nb_common, nb_of_nb_common, last]
            end)
          end)
        end)

      timeit(start, to_string(idx))

      IO.inspect(List.first(res))
      {g, res ++ solutions}
    end)
  end

  defp get_common_neighbors(list1, list2) do
    list1 -- list1 -- list2
  end

  defp generate_graph(words) do
    start = Time.utc_now()
    g = Graph.new(type: :undirected)

    Enum.reduce(words, g, fn word, g ->
      Graph.add_vertex(g, word)
    end)

    timeit(start, "generate_graph")
    {words, g}
  end

  defp build_neighbors({words, g}) do
    start = Time.utc_now()
    zipped = words |> strings_to_32_bit_int() |> Enum.zip(words)

    mapping = for {int, word} <- zipped, into: %{}, do: {word, int}

    result =
      Enum.reduce(words, g, fn word_iter, g ->
        Enum.reduce(words, g, fn word, g2 ->
          if Bitwise.band(mapping[word_iter], mapping[word]) == 0 do
            # they are unique
            Graph.add_edge(g2, word_iter, word)
          else
            g2
          end
        end)
      end)

    timeit(start, "build_neighbors")

    result
  end

  defp timeit(start, label) do
    v = Time.diff(Time.utc_now(), start, :millisecond)
    IO.inspect("#{to_string(v)} ms", label: label)
  end

  defp revert_mapping([result], mapping) do
    Enum.map(result, fn int -> mapping[int] end)
  end

  def get_words() do
    start = Time.utc_now()

    @path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [word] -> word end)
    |> Enum.to_list()
    |> Enum.filter(fn word -> String.length(word) == 5 end)
    |> Enum.uniq()
    |> remove_ununique_words()
    |> remove_anagrams()
    |> tap(fn _ -> timeit(start, "get_words") end)
  end

  # string to interger representing every char as one bit
  defp strings_to_32_bit_int(words) do
    # example: "sayer" is [18, 0, 24, 4, 17] which is 63 and since we removed anagrams,
    # 63 can only be sayer and not seyar, for example, which gives the possibility to map these integers
    # back to strings at the end
    words
    |> Enum.map(fn word ->
      word
      |> String.to_charlist()
      |> Enum.reduce(0, fn c, acc ->
        acc + Integer.pow(2, c - 97)
      end)
    end)
  end

  defp solve(words) do
    start = Time.utc_now()

    Enum.reduce_while(Enum.with_index(words), [], fn {word, i}, acc ->
      ret = check(words, word)

      # log(velocity)
      if rem(i, 1000) == 0 do
        v = Time.diff(Time.utc_now(), start, :microsecond) / (i + 1)
        IO.inspect("#{to_string(v)} per µs")
      end

      # first ever list found after like 3 min
      # [401728, 35668496, 16778247, 5279872, 8914984]
      if length(ret) == 5 do
        IO.inspect(length(acc) + 1, label: to_string(i))

        {:halt, acc ++ [ret]}
      else
        {:cont, acc}
      end
    end)
  end

  defp check(words_graphemes, word_gra) do
    Enum.reduce_while(words_graphemes, [word_gra], fn w_gra, a ->
      combined_gra = a ++ [w_gra]

      cond do
        length(combined_gra) == 6 ->
          {:halt, a}

        are_all_unique?(combined_gra) ->
          {:cont, combined_gra}

        true ->
          {:cont, a}
      end
    end)
  end

  defp are_all_unique?(words) do
    [first_word | new_words] = words

    result =
      Enum.reduce_while(new_words, first_word, fn word, acc ->
        if Bitwise.band(acc, word) == 0 do
          # unique
          {:cont, acc + word}
        else
          {:halt, 0}
        end
      end)

    result != 0
  end

  defp remove_ununique_words(words) do
    Enum.filter(words, &(&1 |> String.graphemes() |> Enum.uniq() |> Enum.count() == 5))
  end

  defp remove_anagrams(words) do
    words_map =
      for word <- words, into: %{} do
        {word, word |> String.graphemes() |> Enum.sort()}
      end

    words_map
    |> Enum.uniq_by(fn {_word, sorted_word} -> sorted_word end)
    |> Enum.map(&elem(&1, 0))
  end
end
