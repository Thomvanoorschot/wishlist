defmodule MyDreamGifts.Wishlist.Queries.WishlistDTO do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :user_id,
    :name,
    :slug,
    :total_cost,
    :initial_total_cost,
    :inserted_at,
    :product_id,
    :product_name,
    :product_category,
    :product_price,
    :accessibility,
    :user_has_access,
    :secret_question,
    :secret_answer,
    :checked_off_by
  ]
end
