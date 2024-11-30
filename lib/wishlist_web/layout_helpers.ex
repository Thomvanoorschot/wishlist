defmodule WishlistWeb.LayoutHelpers do
  def nav_link_class(current_page, page) do
    base_class = "flex h-9 w-9 items-center justify-center rounded-lg transition-colors md:h-8 md:w-8"

    if current_page == page do
      "#{base_class} bg-accent text-accent-foreground"
    else
      "#{base_class} text-muted-foreground hover:text-foreground"
    end
  end
end
