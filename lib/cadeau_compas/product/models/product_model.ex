defmodule CadeauCompas.Product.Models.ProductModel do
  @type t :: %__MODULE__{}

  defstruct [:id, :name, :l, :category, :price]
end

defmodule AvgClicks do
  defstruct [:day, :count]
end
