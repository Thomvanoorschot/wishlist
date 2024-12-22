defmodule CadeauCompas.Accounts.Register do
  import Ecto.Changeset

  alias CadeauCompas.Accounts.Models.{UserModel, UserTokenModel}
  alias CadeauCompas.Accounts.Queries.Q
  alias CadeauCompas.Accounts.UserNotifier

  def register_user(attrs, confirmation_url_fun) do
    changeset =
      %UserModel{}
      |> UserModel.registration_changeset(attrs)
      |> UserModel.hash_password()
      |> UserModel.generate_id()

    with {:ok, %UserModel{id: id, email: email, hashed_password: hashed_password} = user_model} <- apply_action(changeset, :update),
         {:ok, _} <-
           Q.insert_user(
             id: id,
             email: email,
             hashed_password: hashed_password,
             confirmed_at: nil
           ),
         IO.inspect(user_model),
         deliver_user_confirmation_instructions(user_model, confirmation_url_fun) do
      {:ok}
    else
      {:error, %Postgrex.Error{postgres: %{code: :unique_violation}}} ->
        changeset
        |> add_error(
          :email,
          "This email already exists."
        )
        |> apply_action(:validate)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp deliver_user_confirmation_instructions(%UserModel{} = user, confirmation_url_fun)
       when is_function(confirmation_url_fun, 1) do
    with {encoded_token, %UserTokenModel{token: token, context: context, sent_to: sent_to, user_id: user_id}} <-
           UserTokenModel.build_email_token(user, "confirm"),
         id <- Ecto.UUID.generate(),
         {:ok, _} <-
           Q.insert_user_token(
             id: id,
             user_id: user_id,
             token: token,
             context: context,
             sent_to: sent_to
           ),
         {:ok, _} <-
           UserNotifier.deliver_confirmation_instructions(
             user,
             confirmation_url_fun.(encoded_token)
           ) do
      {:ok, :delivered}
    else
      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, :unexpected_error}
    end
  end
end
