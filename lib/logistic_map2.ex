defmodule LogisticMap2 do
  @moduledoc """
  Documentation for LogisticMap2.
  """

  @logistic_map_size 0x10000
  @default_prime 6_700_417
  @default_mu 22
  @scoring_time 5000

  def calc(x, p, mu), do: rem(mu * x * (x + 1), p)

  defp calc_recursive_reverse(n) when n <= 0, do: []
  defp calc_recursive_reverse(n) when n > 0,  do: [{n, calc(n, @default_prime, @default_mu)} | calc_recursive_reverse(n - 1)]

  def calc_recursive(n), do: calc_recursive_reverse(n) |> Enum.reverse()

  def benchmark_recursive(size \\ @logistic_map_size), do: calc_recursive(size)

  def benchmark_enum(size \\ @logistic_map_size) do
  	Enum.zip(Stream.iterate(1, & &1 + 1), 1..size)
  	|> Enum.map(& {elem(&1, 0), calc(elem(&1, 1), @default_prime, @default_mu)})
  end

  def benchmark_flow(size \\ @logistic_map_size) do
  	Enum.zip(Stream.iterate(1, & &1 + 1), 1..size)
  	|> Flow.from_enumerable()
  	|> Flow.map(& {elem(&1, 0), calc(elem(&1, 1), @default_prime, @default_mu)})
  	|> Enum.to_list
  end

  def benchmark(function, acc, size \\ @logistic_map_size) do
  	time_start = :erlang.monotonic_time(:nano_seconds)
  	result = function.(size)
  	time_end = :erlang.monotonic_time(:nano_seconds)
  	time = :erlang.convert_time_unit(time_end - time_start, :native, :milli_seconds)
  	{result, time, time + acc}
  end

  def reference({result, _time, _acc}) do
  	benchmark_enum(Kernel.length(result))
  end

  def result_sort({result, time, acc}) do
  	{(result |> Enum.sort(& elem(&1, 0) <= elem(&2, 0))), time, acc}
  end

  def verify?({result, _time, _acc}, reference) do
  	(Enum.zip(result, reference)
  	|> Enum.reject(& elem(&1, 0) == elem(&1, 1))
  	|> Kernel.length) == 0
  end

  def verify_all(result, reference) do
  	[
  		unsorted: (result |> verify?(reference)),
  		sorted:   (result |> result_sort |> verify?(reference)),
  	]
  end

  def show_verification(function) do
  	result = benchmark(function, 0)
  	IO.inspect verify_all(result, reference(result))
  end

  def sum(list) do
  	list |> Enum.reduce(0, fn x, acc -> x + acc end)
  end

  def average(list) do
  	sum(list) / Kernel.length(list |> Enum.to_list)
  end

  def deviation(list) do
  	ave = average(list)
  	list |> Enum.map(& &1 - ave)
  end

  def variance(list) do
  	list
  	|> deviation()
  	|> Enum.map(& &1 * &1)
  	|> average()
  end

  def standard_deviation(list) do
  	list
  	|> variance()
  	|> :math.sqrt()
  end

  def score_list(function) do
  	Stream.unfold(0, fn acc ->
  		{_result, time, acc} = benchmark(function, acc)
  		if acc > @scoring_time do nil else {time, acc} end
  	end)
  	|> Enum.to_list
  end

  def show_score({name, function}) do
  	score_list = score_list(function)
  	score = Kernel.length(score_list)
  	sd = standard_deviation(score_list)
  	IO.puts name
  	IO.puts "score: #{score} ± #{sd}"
  	show_verification(function)
  end

  def all_benchmarks() do
  	[
  		{"Benchmark Elixir recursive", &benchmark_recursive/1},
  		{"Benchmark Elixir Enum",      &benchmark_enum/1},
  		{"Benchmark Elixir Flow",      &benchmark_flow/1},
  		{"Benchmark Rust Single Thread",             &LogisticMap2Nif.benchmark_rust_single/1},
  		{"Benchmark Rust Multi Thread",             &LogisticMap2Nif.benchmark_rust_multi/1},
  	]
  	|> Enum.each(& show_score(&1))
  end
end
