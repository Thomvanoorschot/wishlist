defmodule CadeauCompas.Wishlist.Models.WishlistModel do
  alias CadeauCompas.Product.Models.ProductModel

  defstruct [:id, :user_id, :name, :slug, :total_cost, :inserted_at, products: []]

  def list_from_dto(dto) do
    dto
    |> Enum.group_by(& &1.id)
    |> Enum.map(fn {_id, wishlist_items} ->
      [first_item | _] = wishlist_items

      products =
        wishlist_items
        |> Enum.filter(& &1.product_id)
        |> Enum.map(fn item ->
          %ProductModel{
            id: item.product_id,
            name: item.product_name,
            category: item.product_category,
            price: item.product_price
          }
        end)

      %__MODULE__{
        id: first_item.id,
        user_id: first_item.user_id,
        name: first_item.name,
        slug: first_item.slug,
        inserted_at: first_item.inserted_at,
        total_cost: first_item.total_cost,
        products: products
      }
    end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end
end
