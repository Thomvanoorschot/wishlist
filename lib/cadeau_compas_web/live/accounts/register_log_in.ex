defmodule CadeauCompasWeb.Live.RegisterLogIn do
  use CadeauCompasWeb, :live_view
  import SaladUI.{Form, Input, Button, Tabs, Card}
  alias CadeauCompas.Accounts.Register
  alias CadeauCompas.Accounts.Models.UserModel

  def mount(_params, _session, socket) do
    register_changeset = UserModel.registration_changeset(%UserModel{})
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    login_error = Phoenix.Flash.get(socket.assigns.flash, :login_error)
    log_in_form = to_form(%{"email" => email}, as: "user_login")

    socket =
      socket
      |> assign(default_tab: socket.assigns.live_action || "log_in")
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(login_error: login_error)
      |> assign_register_form(register_changeset)
      |> assign(:current_page, :register_user)
      |> assign(:log_in_form, log_in_form)

    {:ok, socket}
  end

  def handle_event("register", %{"user_register" => user_params}, socket) do
    case Register.register_user(user_params, &url(~p"/users/confirm/#{&1}")) do
      {:ok} ->
        {:noreply, socket |> assign(trigger_submit: true)}

      {:error, %Ecto.Changeset{} = register_changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_register_form(register_changeset)}
    end
  end

  def handle_event("validate_register", %{"user_register" => user_params}, socket) do
    register_changeset = UserModel.registration_changeset(%UserModel{}, user_params)
    {:noreply, assign_register_form(socket, Map.put(register_changeset, :action, :validate))}
  end

  defp assign_register_form(socket, %Ecto.Changeset{} = register_changeset) do
    register_form = to_form(register_changeset, as: "user_register")

    if register_changeset.valid? do
      assign(socket, register_form: register_form, check_errors: false)
    else
      assign(socket, register_form: register_form)
    end
  end
end
