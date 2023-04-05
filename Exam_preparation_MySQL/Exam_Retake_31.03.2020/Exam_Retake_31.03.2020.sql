#Exam_Retake_31.03.2020
#1
CREATE DATABASE `instd`;
USE `instd`;

CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
`email` VARCHAR(50) NOT NULL,
`gender` CHAR(1) NOT NULL,
`age` INT NOT NULL,
`job_title` VARCHAR(40) NOT NULL,
`ip` VARCHAR(30) NOT NULL);

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address` VARCHAR(30) NOT NULL,
`town` VARCHAR(30) NOT NULL,
`country` VARCHAR(30) NOT NULL,
`user_id` INT NOT NULL,
CONSTRAINT fk_addresses_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`));

CREATE TABLE `photos`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
`views` INT NOT NULL DEFAULT 0);

CREATE TABLE `comments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`));

CREATE TABLE `users_photos`(
`user_id` INT NOT NULL,
CONSTRAINT fk_users_photos_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`),
`photo_id` INT NOT NULL,
CONSTRAINT fk_users_photos_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`));

CREATE TABLE `likes`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`photo_id` INT,
`user_id` INT,
CONSTRAINT fk_likes_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`),
CONSTRAINT fk_likes_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`));

#2 Insert
INSERT INTO `addresses`(`address`, `town`, `country`, `user_id`)
SELECT u.`username`, u.`password`, u.`ip`, u.`age`
FROM `users` AS u
WHERE u.`gender` = 'M';

#3 Update
UPDATE `addresses`
SET `country` = 'Blocked'
WHERE  LEFT(`country`, 1) = 'B';
UPDATE `addresses`
SET `country` = 'Test'
WHERE  LEFT(`country`, 1) = 'T';
UPDATE `addresses`
SET `country` = 'In Progress'
WHERE  LEFT(`country`, 1) = 'P';

#4 Delete
DELETE FROM `addresses`
WHERE `id` % 3 = 0;

#5
SELECT `username`, `gender`, `age`
FROM `users`
ORDER BY `age` DESC, `username` ASC;

#6
SELECT p.`id`, p.`date` AS 'date_and_time', p.`description`, COUNT(c.`id`) AS 'commentsCount'
FROM `photos` AS p
JOIN `comments` AS c
ON p.`id` = c.`photo_id`
GROUP BY c.`photo_id`
ORDER BY `commentsCount` DESC, p.`id` ASC
LIMIT 5;

#7
SELECT CONCAT(u.`id`, ' ', u.`username`) AS 'id_username', u.`email`
FROM `users` AS u
JOIN `users_photos` AS up
ON u.`id` = up.`user_id`
JOIN `photos` AS p
ON p.`id` = up.`photo_id`
WHERE u.`id` = p.`id`
ORDER BY u.`id` ASC;

#8
SELECT p.`id` AS 'photo_id', 
		COUNT(DISTINCT l.`id`) AS 'likes_count', 
        COUNT(DISTINCT c.`id`) AS 'comments_count'
FROM `photos` AS p
LEFT JOIN `comments` AS c
ON c.`photo_id` = p.`id`
LEFT JOIN `likes` AS l
ON l.`photo_id` = p.`id`
GROUP BY p.`id`
ORDER BY `likes_count` DESC, `comments_count` DESC, `photo_id` ASC;

#9
SELECT CONCAT(SUBSTR(`description`, 1, 30), '...') AS 'summury', `date`
FROM `photos`
WHERE DAY(`date`) = '10'
ORDER BY `date` DESC;

#10
DELIMITER $$
CREATE FUNCTION `udf_users_photos_count` (username VARCHAR(30)) 
RETURNS INT
    DETERMINISTIC
BEGIN
	RETURN 	(SELECT COUNT(p.`id`)
			FROM `users` AS u
			JOIN `users_photos` AS up
			ON u.`id` = up.`user_id`
			JOIN `photos` AS p
			ON p.`id` = up.`photo_id`
			WHERE u.`username` = username);
END $$
DELIMITER ;

SELECT udf_users_photos_count('ssantryd') AS photosCount;

#11
DELIMITER $$
CREATE PROCEDURE `udp_modify_user` (address VARCHAR(30), town VARCHAR(30)) 
BEGIN
        UPDATE `users` AS u
        JOIN `addresses` AS a
        ON u.`id` = a.`user_id`
        SET u.`age` = u.`age` + 10
		WHERE a.`address` = address AND a.`town` = town;
END$$
DELIMITER ;

CALL `udp_modify_user` ('97 Valley Edge Parkway', 'Divinópolis');
SELECT u.username, u.email, u.gender, u.age, u.job_title FROM users AS u
WHERE u.username = 'eblagden21';
