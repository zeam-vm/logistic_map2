defmodule LogisticMap2Nif do
  use Rustler, otp_app: :logistic_map2, crate: :logisticmap2nif

  def benchmark_rust_single(_size), do: exit(:nif_not_loaded)

  def benchmark_rust_multi(_size), do: exit(:nif_not_loaded)
end