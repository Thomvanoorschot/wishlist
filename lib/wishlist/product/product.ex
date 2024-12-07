defmodule Wishlist.Product do
  alias Wishlist.Product.Queries

  def search(product_name) do
    {_, res} = Queries.Q.get_products(product_name: product_name)
    res
  end
end
