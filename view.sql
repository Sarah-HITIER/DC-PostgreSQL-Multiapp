/*
 ************************************************************
 * GALLERY VIEW
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
	    c.name AS category,
	    u.username AS artist_username,
	    u.profile_img AS artist_profile_img
	FROM gallery.artworks a
	    INNER JOIN account.users u ON a.artist_id = u.id
	    INNER JOIN gallery.artwork_categories ac ON a.id = ac.artwork_id
	    INNER JOIN gallery.categories c ON ac.category_id = c.id
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
	    u.username AS artist_username,
	FROM gallery.artworks a
	    INNER JOIN account.users u ON a.artist_id = u.id
	    INNER JOIN gallery.artwork_categories ac ON a.id = ac.artwork_id
	    INNER JOIN gallery.categories c ON ac.category_id = c.id
; 

SELECT *
FROM
    gallery.artworks_by_category
WHERE c.name = 'Category 1';

/*
 * ***** VIEW *****
 * POPULAR IMAGES
 * Contains the most popular images
 */

CREATE VIEW GALLERY 
	.popular_images AS
	SELECT
	    a.id,
	    a.title,
	    a.description,
	    i.url,
	    a.views
	FROM gallery.artworks a
	    JOIN gallery.images i ON a.id = i.artwork_id
	ORDER BY a.views
DESC; 

SELECT * FROM gallery.popular_images;

/*
 * ***** VIEW *****
 * ARTWORKS COMMENTS
 */

CREATE VIEW ARTWORK_COMMENTS_VIEW 
	AS
	SELECT
	    c.id AS comment_id,
	    c.content,
	    c.created_at,
	    u.username AS commenter_username
	FROM gallery.comments c
	    INNER JOIN account.users u ON c.user_id = u.id
; 

SELECT *
FROM
    gallery.artwork_comments_view
WHERE c.artwork_id = 1;