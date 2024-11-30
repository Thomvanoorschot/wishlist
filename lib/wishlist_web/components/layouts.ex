defmodule WishlistWeb.Layouts do
  import SaladUI.Breadcrumb
  import SaladUI.Button
  import SaladUI.DropdownMenu
  import SaladUI.Input
  import SaladUI.Menu
  import SaladUI.Sheet
  import SaladUI.Tooltip
  import SaladUI.Avatar

  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use WishlistWeb, :controller` and
  `use WishlistWeb, :live_view`.
  """
  use WishlistWeb, :html

  embed_templates "layouts/*"
end
