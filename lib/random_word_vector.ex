defmodule RandomWordVector do
  @default_dictpath "/workspaces/random_word/lib/data/wordlist.txt"

  # run on creators system
  # Name                             ips        average
  # array_five_words          1219115.95     0.00082 ms (820 ns)
  # array_fifty_five_words     138452.40     0.00722 ms (7220 ns)
  # array_5555_words             1359.00        0.74 ms (740,000 ns)

  # run on my system
  # Name                             ips        average                   deviation         median         99th %
  # five_words                       686.78 K   1.46 μs  (1460 ns)        ±1526.43%         1.28 μs        2.22 μs
  # fifty_five_words                 66.18 K    15.11 μs (15,110 ns)      ±92.59%           12.93 μs       40.69 μs
  # 5555_words                       756.04     1.32 ms  (1,320,000 ns)   ±8.41%            1.30 ms        1.76 ms

  # so we keep in mind the factor 1,320,000 ns / 740,000 ns -> 1.78 that my system is slower for later comparsion

  # with specs
  # Operating System: Linux
  # CPU Information: AMD Ryzen 7 3700X 8-Core Processor
  # Number of Available Cores: 16
  # Available memory: 15.58 GB
  # Elixir 1.16.2
  # Erlang 26.2.4
  # JIT enabled: true

  # without randomness
  # Name                       ips        average  deviation         median         99th %
  # five_words              2.78 M     0.00036 ms  ±6601.09%     0.00032 ms     0.00045 ms
  # fifty_five_words      0.0704 M      0.0142 ms    ±69.77%      0.0134 ms      0.0327 ms
  # 5555_words           0.00090 M        1.11 ms     ±8.69%        1.11 ms        1.36 ms

  # with Enum.shuffle once
  # five_words                7.80      128.20 ms    ±16.24%      122.79 ms      188.93 ms
  # fifty_five_words          6.94      144.08 ms    ±15.75%      143.43 ms      207.48 ms
  # 5555_words                6.60      151.48 ms    ±25.17%      132.63 ms      269.61 ms

  # with random picking each iteration
  # Name                       ips        average  deviation         median         99th %
  # five_words              292.23        3.42 ms    ±15.08%        3.39 ms        4.88 ms
  # fifty_five_words         26.28       38.05 ms     ±7.39%       37.65 ms       52.16 ms
  # 5555_words                0.25     4028.27 ms     ±4.11%     4028.27 ms     4145.28 ms

  # with wordlist as a map with idx keys and values as words
  # Name                       ips        average  deviation         median         99th %
  # five_words               10.54       94.85 ms     ±8.46%       93.34 ms      112.20 ms
  # fifty_five_words         10.31       97.01 ms    ±10.81%       93.75 ms      129.77 ms
  # 5555_words                9.84      101.64 ms    ±10.69%       97.48 ms      122.33 ms

  @spec new(Aja.Vector.t(), non_neg_integer()) :: binary()
  def new(wordlist, length) do
    wordlist
    |> choose_words(length, [])
    |> Enum.join("-")
  end

  @spec choose_words(Aja.Vector.t(), non_neg_integer(), list()) :: list()
  defp choose_words(_wordlist, 0, words), do: words

  defp choose_words(wordlist, num_words, words) do
    choose_words(wordlist, num_words, words, rand_from_array(wordlist))
  end

  defp choose_words(wordlist, num_words, words, rand_word) do
    if Enum.member?(words, rand_word) do
      choose_words(wordlist, num_words, words)
    else
      choose_words(wordlist, num_words - 1, [rand_word | words])
    end
  end

  @spec rand_from_array(Aja.Vector.t()) :: binary()
  def rand_from_array(arr) do
    idx = :rand.uniform(Arrays.size(arr))
    arr[idx - 1]
  end

  @spec wordlist_from_file(binary()) :: Aja.Vector.t()
  def wordlist_from_file(dictpath \\ @default_dictpath) do
    dictpath
    |> File.read!()
    |> String.split("\n")
    |> wordlist_to_vector()
  end

  # this shows that mapping on vector is done before measurement starts
  @spec wordlist_to_vector(list()) :: Aja.Vector.t()
  def wordlist_to_vector(wordlist) do
    Arrays.new(wordlist, implementation: Aja.Vector)
  end
end
