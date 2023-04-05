#Exam_09.02.2020
#1
CREATE DATABASE `fsd`;
USE fsd;

CREATE TABLE `countries`(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL);

CREATE TABLE `towns`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`country_id` INT NOT NULL,
CONSTRAINT fk_towns_countries
FOREIGN KEY (`country_id`)
REFERENCES `countries`(`id`)); 

CREATE TABLE `stadiums`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`capacity` INT NOT NULL,
`town_id` INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`)); 

CREATE TABLE `teams`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT 0,
`stadium_id` INT NOT NULL,
CONSTRAINT fk_teams_stadiums
FOREIGN KEY (`stadium_id`)
REFERENCES `stadiums`(`id`));

CREATE TABLE `skills_data`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`dribbling` INT DEFAULT 0,
`pace` INT DEFAULT 0,
`passing` INT DEFAULT 0,
`shooting` INT DEFAULT 0,
`speed` INT DEFAULT 0,
`strength` INT DEFAULT 0);

CREATE TABLE `coaches`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL (10,2) NOT NULL DEFAULT 0,
`coach_level` INT NOT NULL DEFAULT 0);

CREATE TABLE `players_coaches`
(`player_id` INT, 
 `coach_id` INT, 
CONSTRAINT pk_players_coaches
PRIMARY KEY (`player_id`, `coach_id`),
CONSTRAINT fk_pc_coaches
FOREIGN KEY (`coach_id`)
REFERENCES `coaches`(`id`));

CREATE TABLE `players`
(`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`age` INT NOT NULL DEFAULT 0,
`position` CHAR(1) NOT NULL,
`salary` DECIMAL (10,2) NOT NULL DEFAULT 0,
`hire_date` DATETIME,
`skills_data_id` INT NOT NULL,
`team_id` INT,
CONSTRAINT fk_players_skills_data
FOREIGN KEY (`skills_data_id`)
REFERENCES `skills_data`(`id`),
CONSTRAINT fk_players_teams
FOREIGN KEY (`team_id`)
REFERENCES `teams`(`id`));

ALTER TABLE `players_coaches`
ADD CONSTRAINT fk_pc_players
FOREIGN KEY (`player_id`)
REFERENCES `players`(`id`);

#2 Insert
INSERT INTO `coaches`(first_name, last_name, salary, coach_level)
SELECT p.first_name, p.last_name, p.salary*2, char_length(p.`first_name`) 
FROM `players` AS p
WHERE p.`age` >= 45;

#3 Update
UPDATE `coaches` AS c
SET c.coach_level = c.coach_level +1
WHERE c.first_name LIKE 'A%' 
AND (SELECT COUNT(pc.player_id) != 0 FROM players_coaches AS pc WHERE pc.coach_id = c.id);

#4 Delete
DELETE FROM `players`
WHERE `age` >= 45;

#5 Players
SELECT first_name, age, salary
FROM players
ORDER BY salary DESC;

#6
SELECT p.id, concat(p.first_name, ' ', p.last_name) AS 'full_name', p.age, p.position, p.hire_date
FROM players AS p
JOIN skills_data AS s
ON p.skills_data_id = s.id
WHERE p.age < 23 AND p.position = 'A' AND p.hire_date IS NULL AND s.strength > 50
ORDER BY p.salary, p.age;

#7
SELECT t.`name` AS 'team_name', t.established, t.fan_base, COUNT(p.team_id) AS 'players_count'
FROM teams AS t
LEFT JOIN players AS p
ON t.id = p.team_id
GROUP BY t.id
ORDER BY players_count DESC, t.fan_base DESC;

#8
SELECT MAX(sd.`speed`) AS `max_speed`, (t.`name`) AS `town_name` 
FROM `players` AS p 
RIGHT JOIN `skills_data` AS sd
ON p.`skills_data_id` = sd.`id`
RIGHT JOIN `teams` AS team
ON team.`id` = p.`team_id`
RIGHT JOIN `stadiums` AS s
ON s.`id` = team.`stadium_id`
JOIN `towns` AS t
ON t.`id` = s.`town_id`
WHERE team.`name` != 'Devify'
GROUP BY t.`id`
ORDER BY `max_speed` DESC, `town_name`;

#9
SELECT c.`name`, count(p.id) AS 'total_count_of_players', SUM(p.`salary`) AS 'total_sum_of_salaries'
FROM `players` AS p 
RIGHT JOIN `teams` AS team
ON team.`id` = p.`team_id`
RIGHT JOIN `stadiums` AS s
ON s.`id` = team.`stadium_id`
RIGHT JOIN `towns` AS t
ON t.`id` = s.`town_id`
RIGHT JOIN `countries` AS c
ON c.`id` = t.`country_id`
GROUP BY c.`id`
ORDER BY `total_count_of_players` DESC, c.`name`;

#10
DELIMITER $$
CREATE FUNCTION `udf_stadium_players_count`(stadium_name VARCHAR(30)) 
RETURNS INT
    DETERMINISTIC
BEGIN

RETURN 
		(SELECT count(p.id) AS 'count'
		FROM `players` AS p 
		RIGHT JOIN `teams` AS t
		ON t.`id` = p.`team_id`
		RIGHT JOIN `stadiums` AS s
		ON s.`id` = t.`stadium_id`
        WHERE s.`name` = stadium_name);

END $$
DELIMITER ;

SELECT `udf_stadium_players_count`('Jaxworks');

#11
DELIMITER $$
CREATE PROCEDURE `udp_find_playmaker`(min_dribble_points INT, team_name VARCHAR(45))
BEGIN

		SELECT concat_ws(' ', p.first_name, p.last_name) AS 'full_name', p.age, p.salary,
		sd.dribbling, sd.speed, t.`name` AS 'team_name' 
		FROM `players` AS p 
		JOIN `teams` AS t
		ON t.`id` = p.`team_id`
		JOIN `skills_data` AS sd
		ON sd.`id` = p.`skills_data_id`
        WHERE sd.`dribbling` > min_dribble_points 
				AND t.`name` = team_name 
				AND sd.`speed` > (SELECT AVG(sd.speed) 
								FROM `players` AS p 
								JOIN `skills_data` AS sd
								ON sd.`id` = p.`skills_data_id`)
		ORDER BY sd.`speed` DESC
        LIMIT 1;
END$$
DELIMITER ;

CALL `udp_find_playmaker` (20, 'Skyble');