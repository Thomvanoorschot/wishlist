defmodule WishlistWeb.Layouts do
  import SaladUI.Tooltip
  import SaladUI.Sheet
  import SaladUI.Button
  import SaladUI.Breadcrumb
  import SaladUI.Input
  import SaladUI.DropdownMenu
  import SaladUI.Avatar
  import SaladUI.Menu

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
