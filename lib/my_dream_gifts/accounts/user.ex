defmodule MyDreamGifts.Accounts.User do
  alias MyDreamGifts.Accounts.Models.{UserModel, UserTokenModel}
  alias MyDreamGifts.Accounts.Queries.Q

  def get_user(user_id) do
    params = [user_id: user_id]
    Q.get_user_by_id(params, into: %UserModel{})
  end

  def get_user(email, password) do
    case Q.get_user_by_email_and_password([email: email], into: %UserModel{}) do
      {:ok, [%UserModel{hashed_password: hashed_password} = user | _rest]} ->
        if Argon2.verify_pass(password, hashed_password) do
          {:ok, user}
        else
          {:error, "Invalid email or password"}
        end

      {:ok, []} ->
        {:error, "Invalid email or password"}

      {:error, error} ->
        {:error, error}
    end
  end

end
