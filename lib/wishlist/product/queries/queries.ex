defmodule Wishlist.Product.Queries.Q do
  use AyeSQL, repo: Wishlist.Repo

  defqueries("queries.sql")
end
