defmodule CadeauCompas.Wishlist do
  import CadeauCompas.Helpers.StringHelpers
  alias CadeauCompas.Wishlist.Queries
  alias CadeauCompas.Wishlist.Queries.Q
  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Product.Models.ProductModel

  def upsert_wishlist(%WishlistModel{id: nil} = wishlist) do
    upsert_wishlist(%WishlistModel{wishlist | id: Ecto.UUID.generate()})
  end

  def upsert_wishlist(%WishlistModel{id: id, user_id: user_id, name: name} = wishlist) do
    case Q.upsert_wishlist(id: id, user_id: user_id, name: name, slug: slugify(name)) do
      {:ok, [%{id: wishlist_id}]} ->
        {:ok, %{wishlist | id: wishlist_id}}

      {:error, _} = error ->
        error
    end
  end

  def get_with_products(user_id) do
    {_, wishlists_dto} = Q.get_with_products([user_id: user_id], into: %Queries.WishlistDTO{})

    WishlistModel.list_from_dto(wishlists_dto)
  end

  def add_to_wishlist_and_update_query(%WishlistModel{id: wishlist_id, products: wishlist_products, user_id: user_id} = wishlist, product_id, query) do
    params = [wishlist_id: wishlist_id, product_id: product_id, user_id: user_id]

    case Q.insert_to_wishlist(params, into: %ProductModel{}) do
      {:ok, inserted_product} ->
        updated_products = inserted_product ++ wishlist_products
        products = Product.search(query)
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}, products}

      {:error, _} = error ->
        error
    end
  end

  def delete_wishlist(wishlist_id, user_id) do
    Q.delete_wishlist(wishlist_id: wishlist_id, user_id: user_id)
  end

  def delete_product_from_list(%WishlistModel{products: products, user_id: user_id} = wishlist, product_id) do
    case Q.delete_product_from_list(wishlist_id: wishlist.id, product_id: product_id, user_id: user_id) do
      {:ok, []} ->
        updated_products = Enum.reject(products, &(&1.id == product_id))
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}}

      {:error, []} ->
        {:error, wishlist}
    end
  end

  def get_detail_with_products(username, slug) do
    {_, wishlist_dto} = Q.get_detail_by_slug_with_products([username: username, slug: slug], into: Queries.WishlistDTO)

    Enum.at(WishlistModel.list_from_dto(wishlist_dto), 0)
  end
end
