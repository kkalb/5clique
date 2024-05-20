# Random word problem by groovemonkey

## Background
Since there are a lot of bugs in the original code and I did not trust the results shown in the [video](https://www.youtube.com/watch?v=ICZKZQowiHs) where Elixir and Go are compared, I tried to fix the code on my own, respecting the "bad" approach of generating a long word and checking afterwards if it is unique.

Clearly, this was designed to have bigger load on the CPU both in Go and Elixir.

#### Benchmark #1

I first of all fixed the code and used a different approach on checking on uniqueness. Already used words are stored in a map for the `n_words` runs. All the `n_words_vec` runs are similar to the original code, resulting in **O(n^2)**

```
Name                     ips        average  deviation         median         99th %
5_words_vec        598807.57        1.67 μs  ±1126.75%        1.51 μs        2.48 μs
5_words            454714.77        2.20 μs   ±384.67%           2 μs        3.36 μs
55_words_vec        40032.28       24.98 μs    ±45.18%       23.66 μs       56.15 μs
55_words            28917.33       34.58 μs    ±53.73%       32.41 μs       85.02 μs
555_words            3438.48      290.83 μs    ±19.17%      278.58 μs      440.64 μs
555_words_vec         948.92     1053.83 μs     ±8.66%     1039.36 μs     1283.28 μs
5555_words            277.31     3606.08 μs    ±12.80%     3434.62 μs     4846.96 μs
5555_words_vec          8.17   122351.74 μs     ±7.81%   119250.35 μs   154309.15 μs

Comparison: 
5_words_vec        598807.57
5_words            454714.77 - 1.32x slower +0.53 μs
55_words_vec        40032.28 - 14.96x slower +23.31 μs
55_words            28917.33 - 20.71x slower +32.91 μs
555_words            3438.48 - 174.15x slower +289.16 μs
555_words_vec         948.92 - 631.04x slower +1052.16 μs
5555_words            277.31 - 2159.35x slower +3604.41 μs
5555_words_vec          8.17 - 73265.15x slower +122350.07 μs
```