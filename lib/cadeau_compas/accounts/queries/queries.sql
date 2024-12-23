-- file: queries.sql
-- name: get_user_by_id
SELECT
    id :: text,
    email,
    hashed_password,
    confirmed_at,
    inserted_at,
    updated_at
FROM
    users
WHERE
    id = :t :: text :: uuid;

-- name: get_user_by_email_and_password
SELECT
    id :: text,
    email,
    hashed_password,
    confirmed_at,
    inserted_at,
    updated_at
FROM
    users
WHERE
    email = :email;

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

-- name: insert_session_token
INSERT INTO
    users_tokens (
        id,
        user_id,
        token,
        context,
        inserted_at
    )
VALUES
    (
        :id :: text :: uuid,
        :user_id :: text :: uuid,
        :token,
        :context,
        now()
    );

-- name: get_user_by_session_token
SELECT
    u.id :: text,
    u.email,
    u.confirmed_at
FROM
    users_tokens AS t
    JOIN users AS u ON t.user_id = u.id
WHERE
    t.token = :token
    AND t.context = 'session'
    AND t.inserted_at > (NOW() - INTERVAL '60 day');

-- name: delete_session_token
DELETE FROM
    users_tokens
WHERE
    t.token = :token
    AND t.context = 'session';