defmodule MyDreamGifts.Store.Queries.Q do
  use AyeSQL, repo: MyDreamGifts.Repo

  defqueries("queries.sql")
end
