#Retake_Exam_15.04.2022
#1
CREATE DATABASE `softuni_imdb`;
USE `softuni_imdb`;

CREATE TABLE `countries` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    `continent` VARCHAR(30) NOT NULL,
    `currency` VARCHAR(5) NOT NULL
);

CREATE TABLE `genres` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE `actors` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `birthdate` DATE NOT NULL,
    `height` INT,
    `awards` INT,
    `country_id` INT NOT NULL,
    CONSTRAINT `fk_people_countries` 
    FOREIGN KEY (`country_id`)
    REFERENCES countries (`id`)
);

CREATE TABLE `movies_additional_info` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `rating` DECIMAL(10, 2) NOT NULL,
    `runtime` INT NOT NULL,
    `picture_url` VARCHAR(80) NOT NULL,
    `budget` DECIMAL(10, 2),
    `release_date` DATE NOT NULL,
    `has_subtitles` TINYINT(1),
    `description` TEXT
);

CREATE TABLE `movies` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(70) UNIQUE,
    `country_id` INT NOT NULL,
    `movie_info_id` INT NOT NULL UNIQUE,
    CONSTRAINT `fk_movies_countries`
    FOREIGN KEY (`country_id`)
    REFERENCES countries (`id`),
    CONSTRAINT `fk_movies_movie_info` 
    FOREIGN KEY (`movie_info_id`)
    REFERENCES movies_additional_info (id)
);

CREATE TABLE `movies_actors` (
    `movie_id` INT,
    `actor_id` INT,
    KEY `pk_movie_actor` (`movie_id` , `actor_id`),
    CONSTRAINT `fk_movies_actors_movies` 
    FOREIGN KEY (`movie_id`)
    REFERENCES movies (id),
    CONSTRAINT `fk_movies_actors_actors` 
    FOREIGN KEY (`actor_id`)
    REFERENCES actors (id)
);

CREATE TABLE `genres_movies` (
    `genre_id` INT,
    `movie_id` INT,
    KEY `pk_genre_movies` (`genre_id` , `movie_id`),
    CONSTRAINT `fk_genres_movies_genres` 
    FOREIGN KEY (`genre_id`)
    REFERENCES genres (id),
    CONSTRAINT `fk_genres_movies_movies` 
    FOREIGN KEY (`movie_id`)
    REFERENCES movies (id)
);

#2 INSERT
INSERT INTO `actors` (`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT REVERSE(`first_name`), REVERSE(`last_name`), date_sub(`birthdate`, INTERVAL 2 DAY), (`height` + '10'), `country_id`, '3'  
FROM `actors`
WHERE `id` <= 10;

#3 UPDATE
UPDATE `movies_additional_info`
SET `runtime` = `runtime` - 10
WHERE `id` >= 15 AND `id` <= 25;

#4 DELETE
DELETE FROM `countries`
WHERE `id` NOT IN (SELECT `country_id` FROM `movies`);

#5
SELECT * 
FROM `countries`
ORDER BY `currency` DESC, `id` ASC;

#6
SELECT mai.`id`, m.`title`, mai.`runtime`, mai.`budget`, mai.`release_date`
FROM `movies` AS m
JOIN `movies_additional_info` AS mai
ON m.movie_info_id = mai.id
WHERE YEAR(mai.`release_date`) BETWEEN 1996 AND 1999
ORDER BY mai.`runtime` ASC, mai.`id` ASC
LIMIT 20;

#7
SELECT CONCAT(`first_name`, ' ', `last_name`) AS 'full_name', 
		CONCAT(REVERSE(`last_name`), CHAR_LENGTH(`last_name`), '@cast.com') AS 'email',
        (2022 - YEAR(`birthdate`)) AS 'age', `height`
FROM `actors`
WHERE `id` NOT IN (SELECT `actor_id` FROM `movies_actors`)
ORDER BY `height` ASC;

#7.2
SELECT CONCAT(a.`first_name`, ' ', a.`last_name`) AS 'full_name', 
	CONCAT(REVERSE(a.`last_name`), char_length(a.`last_name`), '@cast.com')	AS 'email', 
	(2022- YEAR(a.`birthdate`))	AS `age`, a.`height`
FROM `actors` AS a
LEFT JOIN `movies_actors` AS ma
ON a.`id` = ma.`actor_id`
WHERE ma.`actor_id` IS NULL
ORDER BY a.`height` ASC;

#8
SELECT c.`name`, COUNT(m.`country_id`) AS 'movies_count'
FROM `countries` AS c
RIGHT JOIN `movies` AS m
ON c.`id` = m.`country_id`
GROUP BY m.`country_id`
HAVING `movies_count` >= 7
ORDER BY c.`name` DESC;

#9
SELECT m.`title`, 
CASE  
		WHEN mai.`rating` <= 4 THEN 'poor'
		WHEN mai.`rating` <= 7 THEN 'good'
		ELSE 'excellent'
END AS 'raiting', 
IF(mai.`has_subtitles` = 1, 'english', '-') AS 'subtitles', mai.`budget`
FROM `movies_additional_info` AS mai
JOIN `movies` AS m
ON m.`movie_info_id` = mai.`id`
ORDER BY mai.`budget` DESC;

#10
DELIMITER $$
CREATE FUNCTION `udf_actor_history_movies_count` (full_name VARCHAR(50)) 
RETURNS INT
    DETERMINISTIC
BEGIN
	RETURN		(SELECT COUNT(ma.`movie_id`)
				FROM `actors` AS a
                JOIN `movies_actors` AS ma
                ON a.`id` = ma.`actor_id`
                JOIN `movies` AS m
                ON m.`id` = ma.`movie_id`
                JOIN `genres_movies` AS gm
                ON gm.`movie_id` = m.`id`
                JOIN `genres` AS g
                ON g.`id` = gm.`genre_id`
				WHERE CONCAT(a.`first_name`, ' ', a.`last_name`) = full_name AND g.`name` = 'History'
                GROUP BY ma.`actor_id`);
END $$
DELIMITER ;

SELECT udf_actor_history_movies_count('Stephan Lundberg')  AS 'history_movies';

SELECT udf_actor_history_movies_count('Jared Di Batista')  AS 'history_movies';

#11
DELIMITER $$
CREATE PROCEDURE `udp_award_movie` (movie_title VARCHAR(50)) 
BEGIN
        UPDATE `actors` AS a
		JOIN `movies_actors` AS ma
		ON a.`id` = ma.`actor_id`
		JOIN `movies` AS m
		ON m.`id` = ma.`movie_id`
        SET a.`awards` = a.`awards`+ 1 
		WHERE m.`title` = movie_title;
END$$
DELIMITER ;

CALL udp_award_movie('Tea For Two');
				
                SELECT concat(a.`first_name`, ' ', a.`last_name`) AS 'full_name', a.`awards` 
				FROM `actors` AS a
                JOIN `movies_actors` AS ma
                ON a.`id` = ma.`actor_id`
                JOIN `movies` AS m
                ON m.`id` = ma.`movie_id`
                WHERE m.`title` = 'Tea For Two';