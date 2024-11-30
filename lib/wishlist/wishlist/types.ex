defmodule Wishlist.Wishlist.Model do
  defstruct [:id, :user_id, :name, products: []]
end
