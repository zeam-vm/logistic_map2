defmodule LogisticMap2Nif do
  use Rustler, otp_app: :logistic_map2, crate: :logisticmap2nif

  def add(_a, _b), do: exit(:nif_not_loaded)
end