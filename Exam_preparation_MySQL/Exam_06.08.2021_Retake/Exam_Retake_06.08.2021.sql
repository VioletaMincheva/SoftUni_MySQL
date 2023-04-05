#Exam_Retake_06.08.2021
#1

CREATE DATABASE `sgd`;
USE `sgd`;

CREATE TABLE `addresses`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(50) NOT NULL);

CREATE TABLE `categories`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(10) NOT NULL);

CREATE TABLE `offices`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`workspace_capacity` INT NOT NULL,
`website` VARCHAR(50),
`address_id` INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY (`address_id`)
REFERENCES `addresses`(`id`));

CREATE TABLE `employees`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`salary` DECIMAL(10,2) NOT NULL,
`job_title` VARCHAR(20) NOT NULL,
`happiness_level` CHAR(1) NOT NULL);

CREATE TABLE `teams`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(40) NOT NULL,
`office_id` INT NOT NULL,
`leader_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_teams_offices
FOREIGN KEY (`office_id`)
REFERENCES `offices`(`id`),
CONSTRAINT fk_teams_employees
FOREIGN KEY (`leader_id`)
REFERENCES `employees`(`id`));

CREATE TABLE `games`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(50) NOT NULL UNIQUE,
`description` TEXT,
`rating` FLOAT DEFAULT 5.5 NOT NULL,
`budget` DECIMAL(10,2) NOT NULL,
`release_date` DATE,
`team_id` INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY (`team_id`)
REFERENCES `teams`(`id`));

CREATE TABLE `games_categories`(
`game_id` INT NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT pk_games_categories
PRIMARY KEY (`game_id`, `category_id`),
CONSTRAINT fk_games_categories_games
FOREIGN KEY (`game_id`)
REFERENCES `games`(`id`),
CONSTRAINT fk_games_categories_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`));

#2 Insert
INSERT INTO `games` (`name`, `rating`, `budget`, `team_id`)
SELECT REVERSE(substr((LOWER(t.`name`)), 2)) , t.`id`, (t.`leader_id` * 1000), t.`id`
FROM `teams` AS t
WHERE t.`id` BETWEEN 1 AND 9;

#3 Update
UPDATE `employees` AS e
SET e.`salary` = e.`salary` + 1000
WHERE e.`salary` < 5000 AND e.`age` < 40 AND e.`id` IN (SELECT `leader_id` FROM `teams`);

#4 Delete
DELETE FROM `games` AS g
WHERE g.`release_date` IS NULL AND g.`id` NOT IN (SELECT `game_id` FROM `games_categories`);

#5
SELECT `first_name`, `last_name`, `age`, `salary`, `happiness_level`
FROM `employees`
ORDER BY `salary`, `id`;

#6
SELECT t.`name` AS 'team_name', a.`name` AS 'address_name', char_length(a.`name`) AS 'count_of_characters'
FROM `teams` AS t
JOIN `offices` AS o
ON t.`office_id` = o.`id`
JOIN `addresses` AS a
ON o.`address_id` = a.`id`
WHERE o.`website` IS NOT NULL
ORDER BY `team_name`, `address_name`;

#7
SELECT c.`name`, COUNT(gc.`game_id`) AS 'games_count',
 ROUND(AVG(g.`budget`), 2) AS 'avg_budget', MAX(g.`rating`) AS 'max_rating'
FROM `categories` AS c
JOIN `games_categories` AS gc
ON c.`id` = gc.`category_id`
JOIN `games` AS g
ON gc.`game_id` = g.`id`
GROUP BY gc.`category_id`
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC, c.`name` ASC;

#8
SELECT g.`name`, g.`release_date`, 
	CONCAT(SUBSTRING(g.`description`, 1, 10), '...') AS 'summary',
   CASE
		WHEN MONTH(g.`release_date`) IN ('01', '02', '03') THEN 'Q1'
		WHEN MONTH(g.`release_date`) IN ('04', '05', '06') THEN 'Q2'
		WHEN MONTH(g.`release_date`) IN ('07', '08', '09') THEN 'Q3'
		WHEN MONTH(g.`release_date`) IN ('10', '11', '12') THEN 'Q4'
    END AS 'quarter', t.`name` AS 'team_name'
FROM `games` AS g
JOIN `teams` AS t
ON g.`team_id` = t.`id`
WHERE g.`name` LIKE '%2' AND YEAR(g.`release_date`) = '2022' 
		AND MONTH(g.`release_date`) % 2 = 0
ORDER BY g.`release_date`;
        
#9
SELECT g.`name`, IF( g.`budget` < 50000, 'Normal budget', 'Insufficient budget') AS 'budget_level', 
		t.`name` AS 'team_name', a.`name` AS 'address_name'
FROM `games` AS g
LEFT JOIN `teams` AS t
ON g.`team_id` = t.`id`
LEFT JOIN `offices` AS o
ON t.`office_id` = o.`id`
LEFT JOIN `addresses` AS a
ON o.`address_id` = a.`id`
LEFT JOIN `games_categories` AS gc
ON gc.`game_id` = g.`id`
LEFT JOIN `categories` AS c
ON gc.`category_id` = c.`id`
WHERE g.`release_date` IS NULL AND g.`id` NOT IN (SELECT `game_id` FROM `games_categories`)
ORDER BY g.`name`;

#10
DELIMITER $$
CREATE FUNCTION `udf_game_info_by_name` (game_name VARCHAR (20)) 
RETURNS VARCHAR(1000)
    DETERMINISTIC
BEGIN
		RETURN 	
				(SELECT CONCAT('The ', g.`name`, ' is developed by a ',
                t.`name`, ' in an office with an address ', a.`name`) AS 'info'
				FROM `games` AS g
				LEFT JOIN `teams` AS t
				ON g.`team_id` = t.`id`
				LEFT JOIN `offices` AS o
				ON t.`office_id` = o.`id`
                LEFT JOIN `addresses` AS a
				ON o.`address_id` = a.`id`
                WHERE g.`name` = game_name);
END $$
DELIMITER ;

SELECT `udf_game_info_by_name` ('Bitwolf') AS info;

#11
DELIMITER $$
CREATE PROCEDURE `udp_update_budget`(min_game_rating FLOAT)
BEGIN
		UPDATE `games` AS g
		LEFT JOIN `games_categories` AS gc
		ON gc.`game_id` = g.`id`
		LEFT JOIN `categories` AS c
		ON gc.`category_id` = c.`id`
        SET g.`budget` = g.`budget` + 100000 
		WHERE g.`id` NOT IN (SELECT `game_id` FROM `games_categories`) 
           AND g.`rating` > min_game_rating 	
           AND g.`release_date` IS NOT NULL;

END$$
DELIMITER ;

CALL `udp_update_budget` (8);

