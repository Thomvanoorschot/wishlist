-- file: queries.sql
-- name: insert_user
INSERT INTO
    users (
        id,
        email,
        hashed_password,
        confirmed_at,
        inserted_at,
        updated_at
    )
VALUES
    (
        :id :: text :: uuid,
        :email,
        :hashed_password,
        :confirmed_at,
        now(),
        now()
    );

-- name: insert_user_token
INSERT INTO
    users_tokens (
        id,
        user_id,
        token,
        context,
        sent_to,
        inserted_at
    )
VALUES
    (
        :id :: text :: uuid,
        :user_id :: text :: uuid,
        :token,
        :context,
        :sent_to,
        now()
    );

-- name: verify_session_token
SELECT
    u.id :: text,
    u.email
FROM
    user_tokens AS t
    JOIN users AS u ON t.user_id = u.id
WHERE
    t.token = :token
    AND t.context = 'session'
    AND t.inserted_at > (NOW() - INTERVAL '60 day')