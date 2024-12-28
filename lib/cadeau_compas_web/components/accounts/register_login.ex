defmodule CadeauCompasWeb.Components.RegisterLogIn do
  use Phoenix.LiveComponent
  use CadeauCompasWeb, :verified_routes

  import SaladUI.{Form, Input, Button, Tabs, Card}

  alias CadeauCompas.Accounts.Register
  alias CadeauCompas.Accounts.Models.UserModel
  alias Phoenix.LiveView.JS

  @impl true
  def update(%{default_tab: default_tab, email: email?, login_error: login_error?} = assigns, socket) do
    register_changeset = UserModel.registration_changeset(%UserModel{})
    log_in_form = to_form(%{"email" => email?}, as: "user_login")

    socket =
      socket
      |> assign(assigns)
      |> assign(:default_tab, default_tab)
      |> assign(:trigger_submit, false)
      |> assign(:check_errors, false)
      |> assign(:login_error, login_error?)
      |> assign_register_form(register_changeset)
      |> assign(:log_in_form, log_in_form)

    {:ok, socket}
  end

  @impl true
  def handle_event("register", %{"user_register" => user_params}, socket) do
    case Register.register_user(user_params, &url(~p"/users/confirm/#{&1}")) do
      {:ok} ->
        {:noreply, socket |> assign(trigger_submit: true)}

      {:error, %Ecto.Changeset{} = register_changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_register_form(register_changeset)}
    end
  end

  @impl true
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

  attr :class, :string, default: nil
  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class}>
      <.tabs :let={builder} default={@default_tab} id={"tab-single-tab-#{@default_tab}"}>
        <.tabs_list class="grid w-full grid-cols-2">
          <.tabs_trigger id="log_in_tab" builder={builder} value="log_in">Log in</.tabs_trigger>
          <.tabs_trigger id="register_tab" builder={builder} value="register">Sign up</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="log_in" class={if(@default_tab != "log_in", do: "hidden ", else: "")}>
          <.card>
            <.card_header>
              <.card_title>Log in to account</.card_title>
              <.card_description>
                Don't have an account?
                <.link phx-click={JS.dispatch("click", to: "#register_tab")} class="font-semibold text-brand hover:underline">
                  Sign up
                </.link>
                for an account.
              </.card_description>
            </.card_header>
            <.card_content class="space-y-2">
              <.form phx-target={@myself} class="space-y-6" for={@log_in_form} id="login_form" action={~p"/users/log_in"}>
                <.form_item>
                  <.form_label>Email</.form_label>
                  <.form_control>
                    <.input field={@log_in_form[:email]} type="email" placeholder="myaccount@email.com" required phx-debounce="500" />
                  </.form_control>
                </.form_item>
                <.form_item>
                  <.form_control>
                    <.form_label class="flex items-center justify-between h-6">
                      Password
                      <.link tabindex="-1" href={~p"/users/reset_password"} class="text-sm font-medium hover:underline leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                        Forgot your password?
                      </.link>
                    </.form_label>
                    <.input field={@log_in_form[:password]} type="password" placeholder="Password" required />
                    <.form_message :if={@login_error} errors={[@login_error]} />
                  </.form_control>
                </.form_item>
                <div class="mt-2 flex items-center justify-between gap-6">
                  <.button phx-disable-with="Logging in..." class="w-full">
                    Log in
                  </.button>
                </div>
              </.form>
            </.card_content>
          </.card>
        </.tabs_content>
        <.tabs_content value="register" class={if(@default_tab != "register", do: "hidden", else: "")}>
          <.card>
            <.card_header>
              <.card_title>Register for an account</.card_title>
              <.card_description>
                Already registered?
                <.link phx-click={JS.dispatch("click", to: "#log_in_tab")} class="font-semibold text-brand hover:underline">
                  Log in
                </.link>
                to your account now.
              </.card_description>
            </.card_header>
            <.card_content class="space-y-2">
              <.form
                phx-target={@myself}
                class="space-y-6"
                for={@register_form}
                id="registration_form"
                phx-trigger-action={@trigger_submit}
                phx-change="validate_register"
                phx-submit="register"
                action={~p"/users/log_in?_action=registered"}
              >
                <.form_item>
                  <.form_label>Username</.form_label>
                  <.form_control>
                    <.input field={@register_form[:username]} type="text" placeholder="MyUserName" required phx-debounce="500" />
                  </.form_control>
                  <.form_message :if={@check_errors} field={@register_form[:username]} />
                </.form_item>
                <.form_item>
                  <.form_label>Email</.form_label>
                  <.form_control>
                    <.input field={@register_form[:email]} type="email" placeholder="myaccount@email.com" required phx-debounce="500" />
                  </.form_control>
                  <.form_message :if={@check_errors} field={@register_form[:email]} />
                </.form_item>
                <.form_item>
                  <.form_control>
                    <.form_label>Password</.form_label>
                    <.input field={@register_form[:password]} type="password" placeholder="Password" required />
                  </.form_control>
                  <.form_message :if={@check_errors} field={@register_form[:password]} />
                </.form_item>

                <div class="mt-2 flex items-center justify-between gap-6">
                  <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
                </div>
              </.form>
            </.card_content>
          </.card>
        </.tabs_content>
      </.tabs>
    </div>
    """
  end
end
