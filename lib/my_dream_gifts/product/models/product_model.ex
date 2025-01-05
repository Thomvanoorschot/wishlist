defmodule MyDreamGifts.Product.Models.ProductModel do
  @type t :: %__MODULE__{}

  defstruct [:id, :name, :l, :category, :price, :checked_off_by]
end

defmodule AvgClicks do
  defstruct [:day, :count]
end
