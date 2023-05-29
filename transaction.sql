DROP SCHEMA IF EXISTS public CASCADE;

DROP SCHEMA IF EXISTS account CASCADE;

DROP SCHEMA IF EXISTS gallery CASCADE;

DROP SCHEMA IF EXISTS shop CASCADE;

DROP SCHEMA IF EXISTS forum CASCADE;

ROLLBACK;

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
        'sarah.hitier@sfr.fr',
        'sarah',
        'Sarah biography',
        'https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'
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
        'test@test.com',
        'test',
        'test biography',
        'https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'
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
 * ADRESSES CREATION
 */

BEGIN;

-- Insert a new adress

INSERT INTO
    account.addresses (
        address,
        city,
        postal_code,
        country_code
    )
VALUES (
        '8 bis Rue de la Fontaine au Roi',
        'Paris',
        '75011',
        'FR'
    ), (
        '123 Rue Lyautey',
        'Paris',
        '75016',
        'FR'
    );

COMMIT;

/*
 * USERS ADRESSES RELATION
 */

BEGIN;

-- Insert a new relation

INSERT INTO
    account.users_addresses (user_id, address_id)
VALUES (1, 1), (1, 2);

SAVEPOINT user_addresses_created;

-- Test unique constraint

INSERT INTO
    account.users_addresses (user_id, address_id)
VALUES (1, 1);

ROLLBACK TO user_addresses_created;

COMMIT;

-- Test references

BEGIN;

-- Test if the user is deleted, the relation with the address is deleted too

DELETE FROM account.users WHERE id = 1;

-- Test if the address is deleted, the relation with the user is deleted too

DELETE FROM account.addresses WHERE id = 1;

COMMIT;