defmodule CadeauCompas.Product.Models.ProductModel do
  @type t :: %__MODULE__{}

  defstruct [:id, :name, :category, :price]
end
