defmodule CadeauCompas.Wishlist do
  alias CadeauCompas.Wishlist.Queries
  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Product.Models.ProductModel

  def upsert_wishlist(%WishlistModel{id: nil} = wishlist) do
    upsert_wishlist(%WishlistModel{wishlist | id: Ecto.UUID.generate()})
  end

  def upsert_wishlist(%WishlistModel{id: id, user_id: user_id, name: name} = wishlist) do
    case Queries.Q.upsert_wishlist(id: id, user_id: user_id, name: name) do
      {:ok, [%{id: wishlist_id}]} ->
        {:ok, %{wishlist | id: wishlist_id}}

      {:error, _} = error ->
        error
    end
  end

  def get_with_products() do
    {_, wishlists_dto} = Queries.Q.get_with_products([], into: Queries.WishlistDTO)

    WishlistModel.list_from_dto(wishlists_dto)
  end

  def add_to_wishlist_and_update_query(%WishlistModel{id: wishlist_id, products: wishlist_products} = wishlist, product_id, query) do
    params = [wishlist_id: wishlist_id, product_id: product_id]

    case Queries.Q.insert_to_wishlist(params, into: %ProductModel{}) do
      {:ok, inserted_product} ->
        updated_products = inserted_product ++ wishlist_products
        products = Product.search(query)
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}, products}

      {:error, _} = error ->
        error
    end
  end

  def delete_wishlist(wishlist_id) do
    Queries.Q.delete_wishlist(wishlist_id: wishlist_id)
  end

  def delete_product_from_list(%WishlistModel{products: products} = wishlist, product_id) do
    case Queries.Q.delete_product_from_list(wishlist_id: wishlist.id, product_id: product_id) do
      {:ok, []} ->
        updated_products = Enum.reject(products, &(&1.id == product_id))
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}}

      {:error, []} ->
        {:error, wishlist}
    end
  end
end
