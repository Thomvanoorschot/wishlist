defmodule MyDreamGifts.Helpers.ToastHelpers do
  def custom_toast_class_fn(assigns) do
    [
      # base classes
      "group/toast z-100 pointer-events-auto relative w-full items-center justify-between origin-center overflow-hidden rounded-lg p-4 shadow-lg border col-start-1 col-end-1 row-start-1 row-end-2",
      # start hidden if javascript is enabled
      "[@media(scripting:enabled)]:opacity-0 [@media(scripting:enabled){[data-phx-main]_&}]:opacity-100",
      # used to hide the disconnected flashes
      if(assigns[:rest][:hidden] == true, do: "hidden", else: "flex"),
      # override styles per severity
      assigns[:kind] == :info && "text-black !bg-green-100 border-green-200",
      assigns[:kind] == :error && "!text-red-700 !bg-red-100 border-red-200",
      assigns[:kind] == :warning && "!text-amber-700 !bg-amber-100 border-amber-200"
    ]
  end
end
