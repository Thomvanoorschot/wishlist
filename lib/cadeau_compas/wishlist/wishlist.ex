defmodule CadeauCompas.Wishlist do
  alias CadeauCompas.Wishlist.Queries
  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Product.Models.ProductModel

  def upsert_wishlist(%{id: id, user_id: user_id, name: name}) do
    Queries.Q.upsert_wishlist(id: id, user_id: user_id, name: name)
  end

  @spec get_with_products() :: list(WishlistModel.t())
  def get_with_products() do
    {_, wishlists_dto} = Queries.Q.get_with_products([], into: Queries.WishlistDTO)

    WishlistModel.list_from_dto(wishlists_dto)
  end

  @spec add_to_wishlist_and_update_query(WishlistModel.t(), Ecto.UUID.t(), String.t()) :: {:ok, WishlistModel.t(), list(ProductModel.t())} | {:error, any()}
  def add_to_wishlist_and_update_query(%WishlistModel{} = wishlist, product_id, query) do
    params = [wishlist_id: wishlist.id, product_id: product_id]

    case Queries.Q.insert_to_wishlist(params, into: %ProductModel{}) do
      {:ok, inserted_product} ->
        IO.inspect(wishlist.products)
        updated_products = inserted_product ++ wishlist.products
        IO.inspect(updated_products)

        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))

        updated_wishlist = %WishlistModel{
          wishlist
          | products: updated_products,
            total_cost: updated_total_cost
        }

        IO.inspect(updated_wishlist)
        products = Product.search(query)

        {:ok, updated_wishlist, products}

      {:error, _} = error ->
        error
    end
  end

  def delete_wishlist(wishlist_id) do
    Queries.Q.delete_wishlist(wishlist_id: wishlist_id)
  end

  @spec delete_product_from_list(any(), any()) :: {:error, any()} | {:ok, any()}
  def delete_product_from_list(wishlist_id, product_id) do
    Queries.Q.delete_product_from_list(wishlist_id: wishlist_id, product_id: product_id)
  end
end
