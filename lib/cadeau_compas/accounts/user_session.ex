defmodule CadeauCompas.Accounts.UserSession do
  alias CadeauCompas.Accounts.Models.{UserModel, UserTokenModel}
  alias CadeauCompas.Accounts.Queries.Q

  def generate_session_token(user) do
    {token, %UserTokenModel{token: token, context: context, user_id: user_id}} = UserTokenModel.build_session_token(user)

    Q.insert_session_token(
      id: Ecto.UUID.generate(),
      user_id: user_id,
      token: token,
      context: context
    )

    token
  end

  def get_user_by_session_token(token) do
    case Q.get_user_by_session_token(token: token, into: %UserModel{}) do
      {:ok, [user | _rest]} ->
        user

      _ ->
        nil
    end
  end

  def delete_token(token) do
    Q.delete_session_token(token: token)
  end
end
