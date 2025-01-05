defmodule MyDreamGifts.Product do
  alias MyDreamGifts.Product.Queries
  alias MyDreamGifts.Product.Models.ProductModel

  @spec search(String.t()) :: list(ProductModel.t())
  def search(product_name) do
    {_, res} = Queries.Q.get_products([product_name: product_name], into: %ProductModel{})
    res
  end
end
