DROP SCHEMA IF EXISTS public CASCADE;

DROP SCHEMA IF EXISTS account CASCADE;

DROP SCHEMA IF EXISTS gallery CASCADE;

DROP SCHEMA IF EXISTS shop CASCADE;

DROP SCHEMA IF EXISTS forum CASCADE;

/*
 ************************************************************
 * PUBLIC SCHEMA
 ************************************************************
 */

/*
 * ***** SCHEMA *****
 * PUBLIC
 * Create public schema if not exists.
 */

CREATE SCHEMA IF NOT EXISTS public;

/*
 ************************************************************
 * ACCOUNT SCHEMA
 ************************************************************
 */

/*
 * ***** SCHEMA *****
 * ACCOUNT
 * Create account schema if not exists. It contains all the tables related to the user accounts
 */

CREATE SCHEMA IF NOT EXISTS account;

/*
 * ***** TYPE *****
 * USER ROLES
 * Users can have only user, admin or moderator roles
 */

DROP TYPE IF EXISTS "account"."user_roles";

CREATE TYPE
    "account"."user_roles" AS ENUM ('user', 'admin', 'moderator');

/*
 * ***** TABLE *****
 * USERS
 * Contains all the users of the application
 */

CREATE TABLE
    IF NOT EXISTS "account"."users" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        -- SERIAL is auto-increment unlike INT and BIGSERIAL has advantages for storage over SERIAL 
        "username" VARCHAR(50) NOT NULL UNIQUE,
        -- username and email must be unique
        "email" VARCHAR(100) NOT NULL UNIQUE,
        "password" VARCHAR(50) NOT NULL,
        "biography" TEXT,
        "profile_img" VARCHAR(200),
        -- stock the url of the image
        "role" account.user_roles DEFAULT 'user',
        -- use type user_roles
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Update the created_at and updated_at columns when a row is inserted or updated
 */

CREATE OR REPLACE FUNCTION UPDATE_TIMESTAMP() RETURNS 
TRIGGER AS $$ 
	BEGIN IF TG_OP = 'INSERT' THEN NEW.created_at = NOW();
	ELSEIF TG_OP = 'UPDATE' THEN NEW.updated_at = NOW();
	END IF;
	RETURN NEW;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE TRIGGER UPDATE_USERS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON account.users FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * ADDRESSES
 * Contains all the addresses of users
 */

CREATE TABLE
    IF NOT EXISTS "account"."addresses" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "address" VARCHAR(100) NOT NULL,
        "city" VARCHAR(50) NOT NULL,
        "postal_code" VARCHAR(10) NOT NULL,
        "country_code" VARCHAR(2) NOT NULL,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_ADDRESSES_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON account.addresses FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * USERS ADDRESSES
 * Associates users with addresses
 * Relation MANY TO MANY between users and addresses : users can have several addresses and an address can be associated with several users
 */

CREATE TABLE
    IF NOT EXISTS "account"."users_addresses" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "user_id" BIGINT NOT NULL REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the user is deleted, the associated address is deleted too
        "address_id" BIGINT NOT NULL REFERENCES "account"."addresses" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the address is deleted, the associated user is deleted too
        CONSTRAINT "unique_user_address" UNIQUE ("user_id", "address_id") -- A user can not be associated with the same address twice
    );

/*
 ************************************************************
 * GALLERY SCHEMA
 ************************************************************
 */

/*
 * ***** SCHEMA *****
 * GALLERY
 * Cate gallery schema if not exists. It contains all the tables related to the gallery
 */

CREATE SCHEMA IF NOT EXISTS gallery;

/*
 * ***** TABLE *****
 * ARTWORKS
 * Contains all the artworks in the gallery
 * Relation MANY TO ONE between artworks and users : an artwork is created by a user and a user can create several artworks
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."artworks" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artist_id" BIGINT NOT NULL REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- The artwork is related to the user who created it. If the user is deleted, the artwork is deleted too
        "title" VARCHAR(100) NOT NULL,
        "description" TEXT,
        -- TEXT is a string with unlimited length
        "dimensions" JSON,
        "views" INT DEFAULT 0,
        -- views is defined to 0 by default
        "likes" INT DEFAULT 0,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_ARTWORKS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON gallery.artworks FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * IMAGES
 * Contains all the images of artworks
 * Relation MANY TO ONE between images and artworks : an image is related to an artwork and an artwork can have several images
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."images" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT NOT NULL REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the artwork is deleted, the associated image is deleted too
        "url" VARCHAR(200) NOT NULL,
        "is_main" BOOL NOT NULL DEFAULT false,
        -- Define the main image of the artwork (cover image)
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_IMAGES_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON gallery.images FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * LIKES
 * Tracks the likes of users on artworks
 * Relation MANY TO ONE between likes and artworks : a like is related to an artwork and an artwork can have several likes
 * Relation MANY TO ONE between likes and users : a like is related to a user and a user can have several likes
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."likes" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the artwork is deleted, the associated like is deleted too
        "user_id" BIGINT REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the user is deleted, the associated like is deleted too
        "created_at" TIMESTAMP DEFAULT NOW(),
        -- The date of the like
        CONSTRAINT "unique_artwork_user_likes" UNIQUE ("artwork_id", "user_id") -- A user can not like the same artwork twice
    );

/*
 * ***** TRIGGER *****
 * LIKES NUMBER
 * Increment the number of likes of an artwork
 */

CREATE OR REPLACE FUNCTION GALLERY.UPDATE_LIKES_NUMBER
() RETURNS TRIGGER AS $$ 
	BEGIN IF TG_OP = 'INSERT' THEN
	UPDATE gallery.artworks
	SET likes = likes + 1
	WHERE id = NEW.artwork_id;
	END IF;
	RETURN NEW;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE TRIGGER UPDATE_LIKES_NUMBER 
	AFTER
	INSERT
	    ON gallery.likes FOR EACH ROW
	EXECUTE
	    PROCEDURE gallery.update_likes_number()
; 

/*
 * ***** TRIGGER *****
 * UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 * Trigger is used only in INSERT
 */

CREATE TRIGGER UPDATE_LIKES_TIMESTAMP 
	BEFORE
	INSERT
	    ON gallery.likes FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * CATEGORIES
 * Contains the categories of artworks
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."categories" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "name" VARCHAR(50) NOT NULL,
        "description" TEXT,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_CATEGORIES_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON gallery.categories FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * ARTWORK CATEGORIES
 * Associates artworks with categories
 * Relation MANY TO MANY between artworks and categories : categories can have multiple artworks and artworks can be associated with multiple categories
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."artwork_categories" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT NOT NULL REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the artwork is deleted, the associated category is deleted too
        "category_id" BIGINT NOT NULL REFERENCES "gallery"."categories" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the category is deleted, the associated artwork is deleted too
        CONSTRAINT "unique_artwork_category" UNIQUE ("artwork_id", "category_id") -- A category can not be associated with the same artwork twice
    );

/*
 * ***** TABLE *****
 * TAGS
 * Contains all the tags
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."tags" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "name" VARCHAR(50) NOT NULL UNIQUE,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_TAGS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON gallery.tags FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * ARTWORK TAGS
 * Associates artworks with tags
 * Relation MANY TO MANY between artworks and tags : artworks can have multiple tags and tags can be associated with multiple artworks
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."artwork_tags" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT NOT NULL REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the artwork is deleted, the associated tag is deleted too
        "tag_id" BIGINT NOT NULL REFERENCES "gallery"."tags" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the tag is deleted, the associated artwork is deleted too
        CONSTRAINT "unique_artwork_tag" UNIQUE ("artwork_id", "tag_id") -- A tag can not be associated with the same artwork twice
    );

/*
 * ***** TABLE *****
 * COMMENTS
 * Contains all the comments posted on artworks
 * Relation MANY TO ONE between comments and artworks : a comment is related to an artwork and an artwork can have several comments
 * Relation MANY TO ONE between comments and users : a comment is related to a user and a user can have several comments
 */

CREATE TABLE
    IF NOT EXISTS "gallery"."comments" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the artwork is deleted, the associated comment is deleted too
        "user_id" BIGINT REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the user is deleted, the associated comment is deleted too
        "content" TEXT,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_COMMENTS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON gallery.comments FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 ************************************************************
 * SHOP SCHEMA
 ************************************************************
 */

/*
 * ***** SCHEMA *****
 * SHOP
 * Create shop schema if not exists. It contains all the tables related to the shop
 */

CREATE SCHEMA IF NOT EXISTS shop;

/*
 * ***** TABLE *****
 * PRODUCTS
 * Contains all the products available in the shop
 * Relation ONE TO ONE between products and artworks : a product is related to an artwork and an artwork can have only one product
 */

CREATE TABLE
    IF NOT EXISTS "shop"."products" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "artwork_id" BIGINT UNIQUE REFERENCES "gallery"."artworks" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- The products are the artworks. If the artwork is deleted, the associated product is deleted too
        "price" MONEY,
        "stock" INT DEFAULT 0
    );

/*
 * ***** TYPE *****
 * ORDER STATUS
 * Order can only have pending, processing, shipped or delivered status
 */

CREATE TYPE
    shop.order_status AS ENUM (
        'pending',
        -- en attente de paiement
        'processing',
        -- en cours de traitement
        'shipped',
        -- expédiée
        'delivered',
        -- livrée
        'cancelled',
        -- annulée
        'returned' -- retournée
    );

/*
 * ***** TABLE *****
 * ORDERS
 * Contains all the orders made by users
 * Relation MANY TO ONE between orders and users : an order is related to a user and a user can have several orders
 */

CREATE TABLE
    IF NOT EXISTS "shop"."orders" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "user_id" BIGINT REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If user is deleted, the associated order is deleted too
        "total_price" MONEY DEFAULT 0,
        "delivery_address_id" BIGINT REFERENCES "account"."addresses" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the address is deleted, the associated order is deleted too
        "billing_address_id" BIGINT REFERENCES "account"."addresses" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the address is deleted, the associated order is deleted too
        "status" shop.order_status NOT NULL,
        -- Use type shop.order_status
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TABLE *****
 * PRODUCTS ORDERS
 * Associates products with orders
 * Relation MANY TO ONE between products and artworks : a product is related to an artwork and an artwork can have several products
 * Relation MANY TO MANY between products and orders : products can be in multiple orders and orders can have multiple products
 */

CREATE TABLE
    IF NOT EXISTS "shop"."products_orders" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "product_id" BIGINT REFERENCES "shop"."products" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the product is deleted, the associated order is deleted too
        "order_id" BIGINT REFERENCES "shop"."orders" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the order is deleted, the associated product is deleted too
        "quantity" INT NOT NULL DEFAULT 1,
        CONSTRAINT "unique_product_order" UNIQUE ("product_id", "order_id") -- A product can not be associated with the same order twice
    );

/*
 * ***** TRIGGER *****
 * ORDER TOTAL PRICE
 * Update the total price of the order in function of the products ordered
 */

CREATE OR REPLACE FUNCTION SHOP.UPDATE_ORDER_TOTAL_PRICE
() RETURNS TRIGGER AS $$ 
	BEGIN
	UPDATE shop.orders
	SET total_price = (
	        SELECT
	            SUM(
	                products.price * products_orders.quantity
	            )
	        FROM shop.products
	            INNER JOIN shop.products_orders ON products.id = products_orders.product_id
	        WHERE
	            products_orders.order_id = NEW.order_id
	    )
	WHERE id = NEW.order_id;
	RETURN NEW;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE TRIGGER UPDATE_ORDER_TOTAL_PRICE 
	AFTER
	INSERT OR
	UPDATE
	    ON shop.products_orders FOR EACH ROW
	EXECUTE
	    PROCEDURE shop.update_order_total_price()
; 

/*
 * ***** TRIGGER *****
 * UPDATE PRODUCT STOCK
 * Update the stock of the product in function of the quantity ordered
 */

CREATE OR REPLACE FUNCTION UPDATE_PRODUCT_STOCK() RETURNS 
TRIGGER AS $$ 
	BEGIN
	    IF TG_OP = 'INSERT'
	    OR TG_OP = 'UPDATE' THEN -- Check if stock is sufficient
	    IF NEW.quantity > (
	        SELECT stock
	        FROM shop.products
	        WHERE
	            id = NEW.product_id
	    ) THEN -- Raise an exception if stock is insufficient
	    RAISE EXCEPTION 'Insufficient stock for product: %',
	    NEW.product_id;
	ELSE -- Update product stock
	UPDATE shop.products
	SET stock = stock - NEW.quantity
	WHERE id = NEW.product_id;
	END IF;
	END IF;
	IF TG_OP = 'DELETE' THEN -- Update product stock
	UPDATE shop.products
	SET stock = stock + OLD.quantity
	WHERE id = OLD.product_id;
	END IF;
	RETURN NEW;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE TRIGGER UPDATE_PRODUCT_STOCK_TRIGGER 
	BEFORE
	INSERT OR
	UPDATE OR
	DELETE
	    ON shop.products_orders FOR EACH ROW
	EXECUTE
	    PROCEDURE update_product_stock()
; 

/*
 ************************************************************
 * FORUM SCHEMA
 ************************************************************
 */

/*
 * ***** SCHEMA *****
 * FORUM
 * Create forum schema if not exists. It contains all the tables related to the forum
 */

CREATE SCHEMA IF NOT EXISTS forum;

/*
 * ***** TYPE *****
 * DISCUSSION CATEGORY
 * Discussion can only have general, tips_and_tricks or critiques category
 */

CREATE TYPE
    forum.discussion_category AS ENUM (
        'general',
        'tips_and_tricks',
        'critiques'
    );

/*
 * ***** TABLE *****
 * DISCUSSIONS
 * Contains all the discussions in the forum
 * Relation MANY TO ONE between discussions and users : a discussion is related to a user and a user can have several discussions
 */

CREATE TABLE
    IF NOT EXISTS "forum"."discussions" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "user_id" BIGINT REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the user is deleted, the associated discussion is deleted too
        "title" VARCHAR(100) NOT NULL,
        "description" TEXT,
        "category" forum.discussion_category NOT NULL DEFAULT 'general',
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_DISCUSSIONS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON forum.discussions FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 

/*
 * ***** TABLE *****
 * POSTS
 * Contains all the posts in the forum
 * Relation MANY TO ONE between posts and discussions : a post is related to a discussion and a discussion can have several posts
 * Relation MANY TO ONE between posts and users : a post is related to a user and a user can have several posts
 */

CREATE TABLE
    IF NOT EXISTS "forum"."posts" (
        "id" BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
        "discussion_id" BIGINT NOT NULL REFERENCES "forum"."discussions" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the discussion is deleted, the associated post is deleted too
        "user_id" BIGINT NOT NULL REFERENCES "account"."users" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- If the user is deleted, the associated post is deleted too
        "content" TEXT,
        "created_at" TIMESTAMP DEFAULT NOW(),
        "updated_at" TIMESTAMP DEFAULT NOW()
    );

/*
 * ***** TRIGGER *****
 * CREATED_AT AND UPDATED_AT
 * Use UPDATE_TIMESTAMP trigger
 */

CREATE TRIGGER UPDATE_POSTS_TIMESTAMP 
	BEFORE
	INSERT OR
	UPDATE
	    ON forum.posts FOR EACH ROW
	EXECUTE
	    PROCEDURE update_timestamp()
; 