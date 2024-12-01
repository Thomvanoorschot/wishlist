defmodule WishlistWeb.SearchModal do
  use WishlistWeb, :live_component

  alias Phoenix.LiveView.JS

  attr :placeholder, :string, default: "Find something..."
  attr :search_entries, :any, default: []

  @spec search_modal(map()) :: Phoenix.LiveView.Rendered.t()
  def search_modal(assigns) do
    ~H"""
    <div
      id="searchbar-dialog"
      class="hidden fixed inset-0 z-50"
      role="dialog"
      aria-modal="true"
      phx-window-keydown={hide_search_modal()}
      phx-key="escape"
    >
      <div class="fixed inset-0 bg-zinc-400/25 backdrop-blur-sm opacity-100"></div>
      <div class="fixed inset-0 overflow-y-auto px-4 py-4 sm:py-20 sm:px-6 md:py-32 lg:px-8 lg:py-[15vh]">
        <div
          id="searchbox_container"
          class="mx-auto overflow-hidden rounded-lg bg-zinc-50 shadow-xl ring-zinc-900/7.5 sm:max-w-xl opacity-100 scale-100"
          phx-hook="SearchModal"
        >
          <div
            role="combobox"
            aria-haspopup="listbox"
            phx-click-away={hide_search_modal()}
            aria-expanded={@search_entries != []}
          >
            <form action="" novalidate="" role="search" phx-change="update_search_query">
              <div class="group relative flex h-12">
                <svg
                  viewBox="0 0 20 20"
                  fill="none"
                  aria-hidden="true"
                  class="pointer-events-none absolute left-3 top-0 h-full w-5 stroke-zinc-500"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M12.01 12a4.25 4.25 0 1 0-6.02-6 4.25 4.25 0 0 0 6.02 6Zm0 0 3.24 3.25"
                  >
                  </path>
                </svg>

                <input
                  phx-update="ignore"
                  id="search-input"
                  name="search[query]"
                  class="flex-auto rounded-lg appearance-none bg-transparent pl-10 text-zinc-900 outline-none focus:outline-none border-slate-200 focus:border-slate-200 focus:ring-0 focus:shadow-none placeholder:text-zinc-500 focus:w-full focus:flex-none sm:text-sm [&::-webkit-search-cancel-button]:hidden [&::-webkit-search-decoration]:hidden [&::-webkit-search-results-button]:hidden [&::-webkit-search-results-decoration]:hidden pr-4"
                  style={
                    @search_entries != [] &&
                      "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none"
                  }
                  aria-autocomplete="both"
                  aria-controls="searchbox__results_list"
                  autocomplete="off"
                  autocorrect="off"
                  autocapitalize="off"
                  enterkeyhint="search"
                  spellcheck="false"
                  placeholder={@placeholder}
                  type="search"
                  value=""
                  tabindex="0"
                />
              </div>

              <ul
                :if={@search_entries != []}
                class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
                id="searchbox__results_list"
                role="listbox"
              >
                <%= for entry <- @search_entries do %>
                  <.link
                    phx-click="click_search_entry"
                    phx-value-id={entry.id}
                    id={"#{entry.id}"}
                    class="block p-4 hover:bg-slate-100 focus:outline-none focus:bg-slate-100 focus:text-sky-800"
                  >
                    <%= entry.name %>
                  </.link>
                <% end %>
              </ul>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def open_search_modal(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#searchbox_container",
      transition:
        {"transition ease-out duration-200", "opacity-0 scale-95", "opacity-100 scale-100"}
    )
    |> JS.show(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-0", "opacity-100"}
    )
    |> JS.focus(to: "#search-input")
  end

  def hide_search_modal(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#searchbar-searchbox_container",
      transition:
        {"transition ease-in duration-100", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
    |> JS.hide(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-100", "opacity-0"}
    )
  end
end
