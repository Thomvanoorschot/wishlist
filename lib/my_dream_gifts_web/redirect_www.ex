defmodule MyDreamGiftsWeb.Plugs.RedirectWWW do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @www_host "www.mydream.gifts"
  @apex_host "mydream.gifts"

  def init(opts), do: opts

  def call(%Plug.Conn{host: @www_host} = conn, _opts) do
    new_url =
      URI.to_string(%URI{
        scheme: "https",
        host: @apex_host,
        path: conn.request_path,
        query: conn.query_string
      })

    conn
    |> redirect(external: new_url)
    |> halt()
  end

  def call(conn, _opts), do: conn
end
