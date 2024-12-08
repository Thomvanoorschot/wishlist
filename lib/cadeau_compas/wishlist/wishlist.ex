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

  @spec add_to_wishlist_and_update_query(Ecto.UUID.t(), Ecto.UUID.t(), String.t()) :: {:ok, list(WishlistModel.t()), list(ProductModel.t())}
  def add_to_wishlist_and_update_query(wishlist_id, product_id, query) do
    Queries.Q.insert_to_wishlist(wishlist_id: wishlist_id, product_id: product_id)

    {_, wishlists_dto} =
      Queries.Q.get_with_products([], into: Queries.WishlistDTO)

    products = Product.search(query)

    {:ok, WishlistModel.list_from_dto(wishlists_dto), products}
  end

  def delete_wishlist(wishlist_id) do
    Queries.Q.delete_wishlist(wishlist_id: wishlist_id)
  end

  @spec delete_product_from_list(any(), any()) :: {:error, any()} | {:ok, any()}
  def delete_product_from_list(wishlist_id, product_id) do
    Queries.Q.delete_product_from_list(wishlist_id: wishlist_id, product_id: product_id)
  end
end
