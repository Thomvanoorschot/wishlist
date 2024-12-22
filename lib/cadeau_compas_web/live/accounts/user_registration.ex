defmodule CadeauCompasWeb.Live.UserRegistration do
  use CadeauCompasWeb, :live_view
  import CadeauCompasWeb.Components.{Header}
  import SaladUI.{Form, Button, Input}

  alias CadeauCompas.Accounts.Register
  alias CadeauCompas.Accounts.Models.UserModel

  def mount(_params, _session, socket) do
    changeset = UserModel.registration_changeset(%UserModel{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> assign(:current_page, :register_user)
      |> assign(:breadcrumbs, [
        %{name: "Register", link: ~p"/wishlist/manage"}
      ])

    {:ok, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Register.register_user(user_params, &url(~p"/users/confirm/#{&1}")) do
      {:ok} ->
        {:noreply, socket |> assign(trigger_submit: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = UserModel.registration_changeset(%UserModel{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
