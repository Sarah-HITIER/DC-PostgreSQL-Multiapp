/*
 ************************************************************
 * ACCOUNT SCHEMA
 ************************************************************
 */

/*
 * USERS CREATION
 */

-- Begin transaction

BEGIN;

-- Insert a new user

INSERT INTO
    account.users (
        username,
        email,
        password,
        biography,
        profile_img
    )
VALUES (
        'sarah',
        'sarah.hitier@example.com',
        'sarah',
        'Sarah biography',
        'sarah.jpg'
    );

-- Make a savepoint

SAVEPOINT user_created;

-- Test username unique constraint

INSERT INTO
    account.users (
        username,
        email,
        password,
        biography,
        profile_img
    )
VALUES (
        'sarah',
        'sarah@example.com',
        'password',
        'Biography of Sarah',
        'sarah.jpg'
    );

-- Rollback to savepoint

ROLLBACK TO user_created;

-- Commit datas

COMMIT;

-- Test updated_at trigger

BEGIN;

UPDATE account.users
SET
    biography = 'Sarah biography'
WHERE id = 1;

COMMIT;

/*
 * USERS ADRESSES RELATION
 */

BEGIN;

-- Insert a new relation

INSERT INTO
    account.users_addresses (user_id, address_id)
VALUES (1, 3);

SAVEPOINT user_addresses_created;

-- Test unique constraint

INSERT INTO
    account.users_addresses (user_id, address_id)
VALUES (1, 1);

ROLLBACK TO user_addresses_created;

COMMIT;

-- Test references

-- Test if the user is deleted, the relation with the address is deleted too

BEGIN;

DELETE FROM account.users WHERE id = 4;

COMMIT;

-- Test if the address is deleted, the relation with the user is deleted too

BEGIN;

DELETE FROM account.addresses WHERE id = 3;

COMMIT;