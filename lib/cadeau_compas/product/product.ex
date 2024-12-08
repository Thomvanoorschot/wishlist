defmodule CadeauCompas.Product do
  alias CadeauCompas.Product.Queries
  alias CadeauCompas.Product.Models.ProductModel

  @spec search(String.t()) :: list(ProductModel.t())
  def search(product_name) do
    {_, res} = Queries.Q.get_products(product_name: product_name, into: ProductModel)
    res
  end
end
