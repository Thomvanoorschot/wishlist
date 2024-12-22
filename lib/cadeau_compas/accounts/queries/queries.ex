defmodule CadeauCompas.Accounts.Queries.Q do
  use AyeSQL, repo: CadeauCompas.Repo

  defqueries("queries.sql")
end
