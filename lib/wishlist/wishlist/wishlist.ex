defmodule Wishlist.Wishlist do
  alias Wishlist.Wishlist.Queries
  alias Wishlist.Wishlist.WishlistDb

  def upsert_wishlist(%{id: id, user_id: user_id, name: name}) do
    Queries.upsert_wishlist(id: id, user_id: user_id, name: name)
  end

  def get_with_products() do
    {_, db_wishlist_with_products} = Queries.get_with_products([], into: WishlistDb.WithProducts)

    WishlistDb.WithProducts.to_model(db_wishlist_with_products)
  end

  def add_to_wishlist(wishlist_id, product_id) do
    Queries.insert_to_wishlist(wishlist_id: wishlist_id, product_id: product_id)
  end
end
