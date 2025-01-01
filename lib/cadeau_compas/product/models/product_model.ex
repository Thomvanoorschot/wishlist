defmodule CadeauCompas.Product.Models.ProductModel do
  @type t :: %__MODULE__{}

  defstruct [:id, :name, :l, :category, :price, :is_checked_off]
end

defmodule AvgClicks do
  defstruct [:day, :count]
end
