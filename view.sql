/*
 ************************************************************
 * GALLERY VIEWS
 ************************************************************
 */

/*
 * ***** VIEW *****
 * ARTWORKS
 * Contains all the artworks
 */

CREATE VIEW GALLERY 
	.GALLERY_VIEW AS
	SELECT
	    a.id AS artwork_id,
	    a.title,
	    a.description,
	    a.views,
	    a.likes,
	    u.username AS artist_username,
	    u.profile_img AS artist_profile_img
	FROM gallery.artworks a
	    INNER JOIN account.users u ON a.artist_id = u.id
; 

SELECT * FROM gallery.gallery_view;

/*
 * ***** VIEW *****
 * ARTWORKS BY CATEGORY
 * Contains all the artworks by category
 */

CREATE VIEW GALLERY 
	.ARTWORKS_BY_CATEGORY AS
	SELECT
	    a.id AS artwork_id,
	    a.title,
	    a.description,
	    a.views,
	    a.likes,
	    c.name AS category,
	    u.username AS artist_username
	FROM gallery.artworks a
	    INNER JOIN account.users u ON a.artist_id = u.id
	    INNER JOIN gallery.artwork_categories ac ON a.id = ac.artwork_id
	    INNER JOIN gallery.categories c ON ac.category_id = c.id
; 

SELECT *
FROM
    gallery.artworks_by_category
WHERE category = 'Category 2';

/*
 * ***** VIEW *****
 * POPULAR artworks
 * Contains the most popular artworks
 */

CREATE VIEW GALLERY 
	.popular_artworks AS
	SELECT
	    a.id,
	    a.title,
	    a.description,
	    a.views
	FROM gallery.artworks a
	ORDER BY a.views
DESC; 

SELECT * FROM gallery.popular_artworks;

/*
 * ***** VIEW *****
 * ARTWORKS COMMENTS
 */

CREATE OR REPLACE VIEW GALLERY 
	.ARTWORK_COMMENTS_VIEW AS
	SELECT
	    c.id AS comment_id,
	    c.artwork_id,
	    c.content,
	    c.created_at,
	    u.username AS commenter_username
	FROM gallery.comments c
	    INNER JOIN account.users u ON c.user_id = u.id
; 

SELECT *
FROM
    gallery.artwork_comments_view
WHERE artwork_id = 1;

/*
 ************************************************************
 * SHOP VIEWS
 ************************************************************
 */

/*
 * ***** VIEW *****
 * ORDERS
 * Contains all the orders
 */

CREATE VIEW SHOP 
	.ORDERS_VIEW AS
	SELECT
	    o.id AS order_id,
	    o.created_at,
	    o.total_price,
	    o.status,
	    u.username AS buyer_username,
	    u.profile_img AS buyer_profile_img
	FROM shop.orders o
	    INNER JOIN account.users u ON o.user_id = u.id
; 

SELECT * FROM shop.orders_view;

/*
 * ***** VIEW *****
 * SHOP PRODUCTS
 */

CREATE VIEW SHOP 
	.SHOP_PRODUCTS_VIEW AS
	SELECT
	    p.id AS product_id,
	    a.title,
	    a.description,
	    p.price,
	    p.stock
	FROM shop.products p
	    INNER JOIN gallery.artworks a ON p.artwork_id = a.id
; 

SELECT * FROM shop.shop_products_view;

/*
 * ***** VIEW *****
 * SHOP PRODUCTS BY ARTIST
 */

CREATE VIEW SHOP 
	.SHOP_PRODUCTS_BY_ARTIST_VIEW AS
	SELECT
	    p.id AS product_id,
	    a.title,
	    a.description,
	    p.price,
	    p.stock,
	    u.username AS artist_username
	FROM shop.products p
	    INNER JOIN gallery.artworks a ON p.artwork_id = a.id
	    INNER JOIN account.users u ON a.artist_id = u.id
; 

SELECT *
FROM
    shop.shop_products_by_artist_view
WHERE artist_username = 'user1';

/*
 * ***** VIEW *****
 * SHOP PRODUCTS OUT OF STOCK
 */

CREATE VIEW SHOP 
	.SHOP_PRODUCTS_OUT_OF_STOCK_VIEW AS
	SELECT
	    p.id AS product_id,
	    a.title,
	    a.description,
	    p.price,
	    p.stock
	FROM shop.products p
	    INNER JOIN gallery.artworks a ON p.artwork_id = a.id
	WHERE p.stock = 0
; 

SELECT * FROM shop.shop_products_out_of_stock_view;

/*
 ************************************************************
 * FORUM VIEWS
 ************************************************************
 */

/*
 * ***** VIEW *****
 * FORUM DISCUSSIONS
 */

CREATE VIEW FORUM 
	.FORUM_DISCUSSIONS_VIEW AS
	SELECT
	    d.id AS discussion_id,
	    d.title,
	    d.created_at,
	    u.username AS author_username,
	    u.profile_img AS author_profile_img
	FROM forum.discussions d
	    INNER JOIN account.users u ON d.user_id = u.id
; 

SELECT * FROM forum.forum_discussions_view;