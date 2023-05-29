/*
 ************************************************************
 * ACCOUNT DATAS
 ************************************************************
 */

/*
 * ***** INSERT *****
 * USERS
 */

INSERT INTO
    "account"."users" (
        "username",
        "email",
        "password",
        "biography",
        "profile_img",
        "role"
    )
VALUES (
        'user1',
        'user1@example.com',
        'password1',
        'Biography of User 1',
        'profile1.jpg',
        'user'
    ), (
        'user2',
        'user2@example.com',
        'password2',
        'Biography of User 2',
        'profile2.jpg',
        'user'
    ), (
        'admin1',
        'admin1@example.com',
        'adminpass1',
        'Biography of Admin 1',
        'admin_profile1.jpg',
        'admin'
    ), (
        'moderator1',
        'moderator1@example.com',
        'modpass1',
        'Biography of Moderator 1',
        'moderator_profile1.jpg',
        'moderator'
    );

/*
 * ***** INSERT *****
 * ADDRESSES
 */

INSERT INTO
    "account"."addresses" (
        "address",
        "city",
        "postal_code",
        "country_code"
    )
VALUES (
        '123 Street',
        'City1',
        '12345',
        'US'
    ), (
        '456 Avenue',
        'City2',
        '67890',
        'UK'
    ), (
        '789 Road',
        'City3',
        '98765',
        'CA'
    );

/*
 * ***** INSERT *****
 * USERS ADDRESSES
 */

INSERT INTO
    "account"."users_addresses" ("user_id", "address_id")
VALUES (1, 1), (1, 2), (2, 2), (3, 3), (4, 1);

/*
 ************************************************************
 * GALLERY DATAS
 ************************************************************
 */

/*
 * ***** INSERT *****
 * ARTWORKS
 */

INSERT INTO
    gallery.artworks (
        artist_id,
        title,
        description,
        dimensions
    )
VALUES (
        1,
        'Artwork 1',
        'Description for Artwork 1',
        '{"width": 100, "height": 200}'
    ), (
        1,
        'Artwork 2',
        'Description for Artwork 2',
        '{"width": 150, "height": 250}'
    ), (
        2,
        'Artwork 3',
        'Description for Artwork 3',
        '{"width": 120, "height": 180}'
    );

/*
 * ***** INSERT *****
 * IMAGES
 */

INSERT INTO
    gallery.images (artwork_id, url, is_main)
VALUES (1, 'image1.jpg', true), (1, 'image2.jpg', false), (2, 'image3.jpg', true);

/*
 * ***** INSERT *****
 * LIKES
 */

INSERT INTO
    gallery.likes (artwork_id, user_id)
VALUES (1, 1), (1, 2), (2, 1);

/*
 * ***** INSERT *****
 * CATEGORIES
 * Contains the categories of artworks
 */

INSERT INTO
    gallery.categories (name, description)
VALUES (
        'Category 1',
        'Description for Category 1'
    ), (
        'Category 2',
        'Description for Category 2'
    );

/*
 * ***** INSERT *****
 * ARTWORK CATEGORIES
 */

INSERT INTO
    gallery.artwork_categories (artwork_id, category_id)
VALUES (1, 1), (1, 2), (2, 2);

/*
 * ***** INSERT *****
 * TAGS
 */

INSERT INTO gallery.tags (name) VALUES ('Tag 1'), ('Tag 2');

/*
 * ***** INSERT *****
 * ARTWORK TAGS
 */

INSERT INTO
    gallery.artwork_tags (artwork_id, tag_id)
VALUES (1, 1), (1, 2), (2, 2);

/*
 * ***** INSERT *****
 * COMMENTS
 */

INSERT INTO
    gallery.comments (artwork_id, user_id, content)
VALUES (1, 1, 'Comment 1 on Artwork 1'), (1, 2, 'Comment 2 on Artwork 1'), (2, 1, 'Comment 1 on Artwork 2');

/*
 ************************************************************
 * SHOP DATAS
 ************************************************************
 */

/*
 * ***** TABLE *****
 * PRODUCTS
 */

INSERT INTO
    shop.products (artwork_id, price, stock)
VALUES (1, 29.99, 10), (2, 49.99, 5), (3, 19.99, 3);

/*
 * ***** TABLE *****
 * ORDERS
 */

INSERT INTO
    shop.orders (
        user_id,
        delivery_address_id,
        billing_address_id,
        status
    )
VALUES (1, 1, 2, 'shipped'), (2, 3, 3, 'delivered'), (3, 2, 1, 'processing');

/*
 * ***** TABLE *****
 * PRODUCTS_ORDERS
 */

INSERT INTO
    shop.products_orders (product_id, order_id, quantity)
VALUES (1, 1, 2), (2, 1, 1), (3, 1, 3), (2, 2, 1), (3, 3, 2);

/*
 ************************************************************
 * FORUM DATAS
 ************************************************************
 */

/*
 * ***** TABLE *****
 * DISCUSSIONS
 */

INSERT INTO
    forum.discussions (
        user_id,
        title,
        description,
        category
    )
VALUES (
        1,
        'Discussion 1',
        'Description of Discussion 1',
        'general'
    ), (
        2,
        'Discussion 2',
        'Description of Discussion 2',
        'tips_and_tricks'
    ), (
        1,
        'Discussion 3',
        'Description of Discussion 3',
        'critiques'
    );

-- Insert posts

INSERT INTO
    forum.posts (
        discussion_id,
        user_id,
        content
    )
VALUES (1, 1, 'Post 1 in Discussion 1'), (1, 2, 'Post 2 in Discussion 1'), (2, 1, 'Post 1 in Discussion 2'), (2, 2, 'Post 2 in Discussion 2'), (2, 1, 'Post 3 in Discussion 2'), (3, 2, 'Post 1 in Discussion 3');