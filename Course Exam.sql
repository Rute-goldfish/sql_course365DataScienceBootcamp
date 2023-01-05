USE albums;
SET @@global.sql_mode:= REPLACE(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');


/* 1 */
USE albums;
SELECT 
    *
FROM
    albums
WHERE
    album_name IS NULL;

/* 2 */
/* SELECT count(*), CASE WHEN album_name IS NULL THEN 1 ELSE 0 END AS count_nulls from albums; */
SELECT sum(CASE WHEN album_name IS NULL THEN 1 ELSE 0 END) AS count_nulls from albums;

/* 3 */
SELECT
    CASE WHEN
        (SELECT
            count(record_label_id)
		    FROM
                albums
                WHERE record_label_id = 1) = (SELECT total_no_artists
			FROM
                record_labels WHERE record_label_id = 1)
	THEN
        'equal'
	ELSE 'not equal'
END AS result;

/* 4 */
SELECT 
    record_label_id, COUNT(record_label_id)
FROM
    albums
WHERE
    record_label_id IS NOT NULL
GROUP BY record_label_id
ORDER BY record_label_id;

SELECT
    record_label_id, total_no_artists
FROM
    record_labels
WHERE
    record_label_id IS NOT NULL
GROUP BY record_label_id
ORDER BY record_label_id;

SELECT 
    *
FROM
    albums;
SELECT 
    *
FROM
    record_labels;

SELECT 
    album_id
FROM
    albums a
        JOIN
    record_labels rl ON a.record_label_id = rl.record_label_id
GROUP BY a.record_label_id
ORDER BY a.record_label_id;

/* 5 */
SELECT 
    sa.record_label_id,
    sa.albums_no_artists,
    srl.total_no_artists,
    CASE
        WHEN albums_no_artists = srl.total_no_artists THEN 'equal'
        ELSE 'not equal'
    END AS coincidence
FROM
    (SELECT 
        record_label_id, COUNT(record_label_id) AS albums_no_artists
    FROM
        albums) sa
        JOIN
    (SELECT 
        record_label_id, total_no_artists
    FROM
        record_labels) srl ON sa.record_label_id = srl.record_label_id;

/* 6 */
SELECT
    SUM(CASE
        WHEN sa.albums_no_artists = srl.total_no_artists
        THEN
	1
    ELSE 0
END) total_number_of_coincidences
FROM
    (SELECT
        record_label_id, COUNT(record_label_id) AS albums_no_artists
	FROM
        albums
	WHERE
        record_label_id IS NOT NULL
	GROUP BY record_label_id
    ORDER BY record_label_id) sa
        JOIN
	(SELECT
        record_label_id, total_no_artists
	FROM
        record_labels
	GROUP BY record_label_id
    ORDER BY record_label_id) srl ON sa.record_label_id = srl.record_label_id;

/* 7 */
SELECT
    art.*,
    CASE
        WHEN alb.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date THEN 'Valid' ELSE 'Invalid'
	END AS validity
FROM
    artists art
        JOIN
        albums alb ON art.artist_id = alb.artist_id
WHERE
    art.record_label_contract_start_date IS NOT NULL AND
art.record_label_contract_end_date IS NOT NULL;

/* 8 */
SELECT
    SUM(CASE
        WHEN alb.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date THEN 0 ELSE 1
	END) AS number_of_mismatches
FROM
    artists art
        JOIN
	albums alb ON art.artist_id = alb.artist_id
WHERE
    art.record_label_contract_start_date IS NOT NULL AND
art.record_label_contract_end_date IS NOT NULL;

/* 9 */
SELECT 
    record_label_id, COUNT(*)
FROM
    albums
WHERE
    record_label_id IS NOT NULL
GROUP BY record_label_id
ORDER BY record_label_id;

/* 10 */
SELECT
    DISTINCT artist_id
FROM
    albums
    WHERE genre_id IN ('g03', 'g07', 'g12') AND release_date BETWEEN ('1997-01-01') AND ('2004-12-31')
    ORDER BY artist_id;

/* 15 */
SELECT
    *
FROM
    artists
WHERE
    no_weeks_top_100 > 15 AND TIMESTAMPDIFF(YEAR, record_label_contract_start_date, record_label_contract_end_date) > 10;

/* 16 */
SELECT
    a.artist_id, a.artist_first_name, a.artist_last_name
FROM
    artists a
    JOIN
    albums al ON a.artist_id = al.artist_id
GROUP BY artist_id
HAVING(COUNT(DISTINCT(al.genre_id))) > 1;

/* 17 */
/* This was my resolution */
SELECT
    al.artist_id, al.genre_id, g.genre_name
FROM
    artists a
    JOIN
    albums al ON a.artist_id = al.artist_id
    JOIN
    genre g ON al.genre_id = g.genre_id
    WHERE artist_first_name = 'Keala' AND artist_last_name = 'Thompson'
GROUP BY g.genre_id;

/* We can have two different type of query that will return the genres of the albums that the artist has released */
/* 1 */
SELECT
    art.artist_id,
    art.artist_first_name,
    art.artist_last_name,
    g.genre_id,
    g.genre_name
FROM
    artists art
    JOIN
    albums alb ON art.artist_id = alb.artist_id
    JOIN
    genre g ON alb.genre_id = g.genre_id
WHERE
    art.artist_id = 1152
GROUP BY g.genre_id
ORDER BY g.genre_id;

/* 2 Alternatively, you can obtain the genre_id after referring to the relevant artist_id in the 'albums' table */
SELECT
    *
FROM
    albums
WHERE
    artist_id = 1152
GROUP BY genre_id;

/* Then, you can find the genre names corresponding to these genre IDs in the 'genre' table by executing the following query */
SELECT
    *
FROM
    genre;

/* 18 */
SELECT
    a.artist_id, a.artist_first_name, a.artist_last_name, a.start_date_ind_artist
FROM
    (SELECT
        MAX(start_date_ind_artist) as start_date_ind_artist
	FROM
        artists) aa
        JOIN artists a ON a.start_date_ind_artist = aa.start_date_ind_artist
WHERE
dependency = 'independent artist';

/* 21 */
DROP TRIGGER IF EXISTS trig_artist;
DELIMITER $$
CREATE TRIGGER tri_artist
BEFORE INSERT ON artists
FOR EACH ROW
BEGIN
    IF (YEAR(DATE(SYSDATE())) - YEAR((NEW.birth_date))) < 18 THEN
	SET NEW.dependency = 'Not Professional Yet'
    AND
    NEW.no_weeks_top_100 = 0;
    END IF;
END $$
DELIMITER ;

/* 22 */
INSERT INTO artists VALUES (1275, 'John', 'Johnson', '2009-01-18', 4, 10, 'signed to a record label', '2014-2-2', '2018-5-14', NULL);

/* 23 */
DROP TABLE IF EXISTS artist_managers;
CREATE TABLE IF NOT EXISTS artist_managers (
    artist_id INTEGER NOT NULL,
    artist_first_name VARCHAR(30) NOT NULL,
    artist_last_name VARCHAR(30) NOT NULL,
    manager_id INTEGER NOT NULL
);

SELECT
    art.artist_id,
    artist_first_name,
    artist_last_name,
    (SELECT
        artist_id
        FROM
            albums
		WHERE
            artist_id = 1012) AS manager_id
FROM
    artists art
    JOIN
    albums alb ON art.artist_id = alb.artist_id
WHERE art.artist_id < 1025
UNION
SELECT
    art.artist_id,
    artist_first_name,
    artist_last_name,
    (SELECT
        artist_id
        FROM
            albums
		WHERE
            artist_id = 1012) AS manager_id
FROM
    artists art
    JOIN
    albums alb ON art.artist_id = alb.artist_id
WHERE art.artist_id < 1250;

/* 24 */
SELECT 
    m1.*
FROM
    artist_managers m1
        JOIN
    artist_managers m2 ON m1.artist_id = m2.manager_id
WHERE
    m2.manager_id IN (SELECT 
            artist_id
        FROM
            artist_managers)
GROUP BY artist_id;

/* 25 */
SELECT 
    a.artist_first_name,
    a.artist_last_name,
    rl.record_label_name
FROM
    artists a
        CROSS JOIN
    record_labels rl
HAVING a.artist_id < 1016;

/* 26 */
/* To ensure you refer to the artist IDs stored in the 'albums' table, you can either use a subquery or an inner join combined with the relevant GROUP BY clause */
SELECT
    art.artist_id,
    art.artist_first_name,
    art.artist_last_name,
    art.no_weeks_top_100
FROM
    artists art
WHERE
    art.artist_id IN (SELECT
        alb.artist_id
	FROM
        albums alb)
ORDER BY no_weeks_top_100 DESC;

SELECT
    art.artist_id,
    art.artist_first_name,
    art.artist_last_name,
    art.no_weeks_top_100
FROM
    artists art
        JOIN
	albums alb ON art.artist_id = alb.artist_id
GROUP BY art.artist_id
ORDER BY no_weeks_top_100 DESC;

SELECT
    COUNT(DISTINCT artist_id)
FROM
    albums;

/* 27 */
DROP FUNCTION IF EXISTS f_avg_no_weeks_100;

DELIMITER $$
CREATE FUNCTION f_avg_no_weeks_100 (p_start_year INTEGER) RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
    DECLARE v_avg_no_weeks_100 DECIMAL(10,4);
    SELECT
    AVG(no_weeks_top_100)
    INTO v_avg_no_weeks_100 FROM
    artists
WHERE
    YEAR(birth_date) BETWEEN p_start_year AND p_End_year;
    RETURN v_avg_no_weeks_100;
END$$

DELIMITER ;

/* 28 */
CREATE OR REPLACE VIEW albums_multiple_genres AS
    SELECT 
        art.artist_id, COUNT(DISTINCT genre_id) AS no_of_genres
    FROM
        albums alb
            JOIN
        artists art ON alb.artist_id = art.artist_id
    GROUP BY artist_id
    HAVING no_of_genres > 1;

SELECT * FROM albums.albums_multiple_genres;

/* 29 */
CREATE INDEX i_composite ON artists(record_label_contract_start_date, record_label_contract_end_date, start_date_ind_artist);