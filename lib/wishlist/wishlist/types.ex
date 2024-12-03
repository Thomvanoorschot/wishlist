defmodule Wishlist.Wishlist.Model do
  defstruct [:id, :user_id, :name, :total_cost, :inserted_at, products: []]
end
