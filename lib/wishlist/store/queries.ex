defmodule Wishlist.Store.Queries do
  use AyeSQL, repo: Wishlist.Repo

  defqueries("queries.sql")
end
