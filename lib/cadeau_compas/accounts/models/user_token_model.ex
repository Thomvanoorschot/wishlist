defmodule CadeauCompas.Accounts.Models.UserTokenModel do
  alias CadeauCompas.Accounts.Models.UserTokenModel

  @hash_algorithm :sha256
  @rand_size 32

  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  defstruct [
    :id,
    :user_id,
    :token,
    :context,
    :sent_to,
    :inserted_at,
  ]

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserTokenModel{token: token, context: "session", user_id: user.id}}
  end


  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserTokenModel{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end
end
