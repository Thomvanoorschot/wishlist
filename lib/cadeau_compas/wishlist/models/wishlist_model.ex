defmodule CadeauCompas.Wishlist.Models.WishlistModel do
  defstruct [:id, :user_id, :name, :total_cost, :inserted_at, products: []]
end
