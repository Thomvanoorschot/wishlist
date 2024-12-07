defmodule CadeauCompas.Store.Queries.Q do
  use AyeSQL, repo: CadeauCompas.Repo

  defqueries("queries.sql")
end
