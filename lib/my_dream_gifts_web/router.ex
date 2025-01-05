defmodule MyDreamGiftsWeb.Router do
  use MyDreamGiftsWeb, :router

  import MyDreamGiftsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyDreamGiftsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyDreamGiftsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_dream_gifts, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyDreamGiftsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", MyDreamGiftsWeb do
    pipe_through :browser

    live_session :maybe_user,
      on_mount: [{MyDreamGiftsWeb.UserAuth, :mount_current_user}, MyDreamGiftsWeb.SetDomain] do
      live "/", Live.Lander
      live "/wishlist/:username/:wishlist_slug", Live.WishlistDetail
    end
  end

  ## Authentication routes

  scope "/", MyDreamGiftsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MyDreamGiftsWeb.UserAuth, :redirect_if_user_is_authenticated}, MyDreamGiftsWeb.SetDomain] do
      live "/users/register", Live.RegisterLogIn, :register
      live "/users/log_in", Live.RegisterLogIn, :log_in
      # live "/users/reset_password", UserForgotPasswordLive, :new
      # live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", MyDreamGiftsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MyDreamGiftsWeb.UserAuth, :ensure_authenticated}, MyDreamGiftsWeb.SetDomain] do
      live "/wishlist/manage", Live.ManageWishlists
      # live "/users/settings", UserSettingsLive, :edit
      # live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", MyDreamGiftsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{MyDreamGiftsWeb.UserAuth, :mount_current_user}, MyDreamGiftsWeb.SetDomain] do
      # live "/users/confirm/:token", UserConfirmationLive, :edit
      # live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
