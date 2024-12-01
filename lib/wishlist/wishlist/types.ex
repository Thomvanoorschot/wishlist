defmodule Wishlist.Wishlist.Model do
  defstruct [:id, :user_id, :name, :inserted_at, products: []]
end
