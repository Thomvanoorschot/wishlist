defmodule Wishlist.Wishlist.WishlistDb.WithProducts do
  alias Wishlist.Product
  alias Wishlist.Wishlist

  defstruct [
    :id,
    :user_id,
    :name,
    :total_cost,
    :inserted_at,
    :product_id,
    :product_name,
    :product_category,
    :product_price
  ]

  def to_model(db_wishlists) do
    db_wishlists
    |> Enum.group_by(& &1.id)
    |> Enum.map(fn {_id, wishlist_items} ->
      [first_item | _] = wishlist_items

      products =
        wishlist_items
        |> Enum.filter(& &1.product_id)
        |> Enum.map(fn item ->
          %Product.Model{
            id: item.product_id,
            name: item.product_name,
            category: item.product_category,
            price: item.product_price
          }
        end)

      %Wishlist.Model{
        id: first_item.id,
        user_id: first_item.user_id,
        name: first_item.name,
        inserted_at: first_item.inserted_at,
        total_cost: first_item.total_cost,
        products: products
      }
    end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end
end
