defmodule CadeauCompas.Wishlist.Queries.WishlistDTO do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :user_id,
    :name,
    :slug,
    :total_cost,
    :inserted_at,
    :product_id,
    :product_name,
    :product_category,
    :product_price
  ]
end
