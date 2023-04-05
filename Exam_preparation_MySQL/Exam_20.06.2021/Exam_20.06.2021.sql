#Exam_20.06.2021

#1
CREATE DATABASE `stc`;
USE `stc`;

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL);

CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`phone_number` VARCHAR(20) NOT NULL);

CREATE TABLE `drivers`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`rating` FLOAT DEFAULT(5.5));

CREATE TABLE `cars`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT NOT NULL DEFAULT 0,
`mileage` INT DEFAULT 0,
`condition` CHAR(1) NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_cars_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`));

CREATE TABLE `courses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`from_address_id` INT NOT NULL,
`start` DATETIME NOT NULL,
`bill` DECIMAL(10,2) DEFAULT 10,
`car_id` INT NOT NULL,
`client_id` INT NOT NULL,
CONSTRAINT fk_courses_addresses
FOREIGN KEY (`from_address_id`)
REFERENCES `addresses`(`id`),
CONSTRAINT fk_courses_cars
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_courses_clients
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `cars_drivers`(
`car_id` INT NOT NULL,
`driver_id` INT NOT NULL,
CONSTRAINT pk_cars_drivers
PRIMARY KEY (`car_id`, `driver_id`),
CONSTRAINT fk_cars_drivers_cars
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_cars_drivers_drivers
FOREIGN KEY (`driver_id`)
REFERENCES `drivers`(`id`));

#2 Insert
INSERT INTO `clients` (`full_name`, `phone_number`)
(SELECT concat_ws(' ', d.`first_name`, d.`last_name`) AS 'full_name', 
CONCAT('(088) 9999', d.`id`*2) AS 'phone_number'
FROM `drivers` AS d
WHERE d.id BETWEEN 10 AND 20);

#3 Update
UPDATE `cars`
SET `condition` = 'C'
WHERE (`mileage` >= 800000 OR `mileage` IS NULL) 
		AND `year` <= 2010 
        AND `model` != 'Mercedes-Benz';

#4 Delete
DELETE FROM `clients`
WHERE char_length(`full_name`) > 3 
		AND `id` NOT IN	(SELECT `client_id`FROM courses);
		
#5
SELECT `make`, `model`, `condition`
FROM `cars`
ORDER BY `id`;

#6
SELECT d.`first_name`, d.`last_name`, c.`make`, c.`model`, c.`mileage`
FROM `drivers` AS d
JOIN `cars_drivers` AS cd
ON d.`id` = cd.`driver_id`
JOIN `cars` AS c
ON cd.`car_id` = c.`id`
WHERE c.`mileage` IS NOT NULL
ORDER BY c.`mileage` DESC, d.`first_name` ASC;

#7
SELECT cars.`id` AS 'car_id', cars.`make`, cars.`mileage`, 
count(c.`id`) AS 'count_of_courses', format(AVG(c.`bill`), 2) AS 'avg_bill'
FROM `courses` AS c
RIGHT JOIN `cars`
ON c.`car_id` = cars.`id`
GROUP BY cars.`id`
HAVING `count_of_courses` != 2
ORDER BY `count_of_courses` DESC, `car_id` ASC;

#8
SELECT cl.`full_name`, count(cars.`id`) AS 'count_of_cars', SUM(c.`bill`) AS 'total_sum'
FROM `courses` AS c
JOIN `cars`
ON c.`car_id` = cars.`id`
JOIN `clients` AS cl
ON cl.`id` = c.`client_id`
WHERE cl.`full_name` LIKE '_a%'
GROUP BY cl.`id`
HAVING `count_of_cars` > 1
ORDER BY cl.`full_name` ASC;

#9
SELECT a.`name`, 
IF(TIME(c.`start`) BETWEEN '06:00:00' AND '20:59:59', 'Day', 'Night') AS 'day_time', 
c.`bill`, cl.`full_name`, cars.`make`, cars.`model`, cat.`name` AS 'category_name'
FROM `courses` AS c
JOIN `addresses` AS a
ON a.`id` = c.`from_address_id`
JOIN `clients` AS cl
ON cl.`id` = c.`client_id`
JOIN `cars`
ON c.`car_id` = cars.`id`
JOIN `categories` AS cat
ON cat.`id` = cars.`category_id`
ORDER BY c.`id` ASC;

#10 
DELIMITER $$
CREATE FUNCTION `udf_courses_by_client`(phone_num VARCHAR (20)) 
RETURNS INT
    DETERMINISTIC
BEGIN

RETURN 
		(SELECT COUNT(c.`id`) 
        FROM `courses` AS c
		JOIN `clients` AS cl
		ON cl.`id` = c.`client_id`
        WHERE cl.`phone_number` = phone_num);

END $$
DELIMITER ;

SELECT `udf_courses_by_client`('(704) 2502909') as `count`;

#11
DELIMITER $$
CREATE PROCEDURE `udp_courses_by_address`(address_name VARCHAR(100))
BEGIN
			SELECT a.`name`, cl.`full_name`, 
            (CASE 
				WHEN c.`bill` <= 20 THEN 'Low'
				WHEN c.`bill` <= 30 THEN 'Medium'
				WHEN c.`bill` > 30 THEN 'High'
			END) AS 'level_of_bill', 
            cars.`make`, cars.`condition`, cat.`name` AS 'cat_name'
			FROM `courses` AS c
			JOIN `addresses` AS a
			ON a.`id` = c.`from_address_id`
			JOIN `clients` AS cl
			ON cl.`id` = c.`client_id`
			JOIN `cars`
			ON c.`car_id` = cars.`id`
			JOIN `categories` AS cat
			ON cat.`id` = cars.`category_id`
            WHERE a.`name` = address_name
			ORDER BY cars.`make` ASC, cl.`full_name` ASC;

END$$
DELIMITER ;

CALL `udp_courses_by_address` ('700 Monterey Avenue');