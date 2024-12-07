defmodule Wishlist.Wishlist do
  alias Wishlist.Wishlist.Queries
  alias Wishlist.Product

  def upsert_wishlist(%{id: id, user_id: user_id, name: name}) do
    Queries.Q.upsert_wishlist(id: id, user_id: user_id, name: name)
  end

  def get_with_products() do
    {_, db_wishlist_with_products} = Queries.Q.get_with_products([], into: Queries.WishlistDTO)
    Queries.WishlistDTO.to_model(db_wishlist_with_products)
  end

  def add_to_wishlist_and_update_query(wishlist_id, product_id, query) do
    Queries.Q.insert_to_wishlist(wishlist_id: wishlist_id, product_id: product_id)
    {_, db_wishlist_with_products} = Queries.Q.get_with_products([], into: Queries.WishlistDTO)
    products = Product.search(query)

    {:ok, Queries.WishlistDTO.to_model(db_wishlist_with_products), products}
  end

  def delete_wishlist(wishlist_id) do
    Queries.Q.delete_wishlist(wishlist_id: wishlist_id)
  end

  def delete_product_from_list(wishlist_id, product_id) do
    Queries.Q.delete_product_from_list(wishlist_id: wishlist_id, product_id: product_id)
  end
end
