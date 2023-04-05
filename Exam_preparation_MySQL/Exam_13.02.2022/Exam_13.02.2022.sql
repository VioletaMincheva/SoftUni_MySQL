#Exam_13.02.2022
#1
CREATE DATABASE `online_stores`;
USE `online_stores`;

CREATE TABLE `brands`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(40) NOT NULL UNIQUE);

CREATE TABLE `categories`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(40) NOT NULL UNIQUE);

CREATE TABLE `reviews`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`content` TEXT,
`rating` DECIMAL(10,2) NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`published_at` DATETIME NOT NULL);

CREATE TABLE `products`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(40) NOT NULL,
`price` DECIMAL(19,2) NOT NULL,
`quantity_in_stock` INT,
`description` TEXT,
`brand_id` INT NOT NULL,
`category_id` INT NOT NULL,
`review_id` INT,
CONSTRAINT fk_products_brands
FOREIGN KEY (`brand_id`)
REFERENCES `brands`(`id`),
CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`),
CONSTRAINT fk_products_reviews
FOREIGN KEY (`review_id`)
REFERENCES `reviews`(`id`));

CREATE TABLE `customers`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`phone` VARCHAR(30) NOT NULL UNIQUE,
`address` VARCHAR(60) NOT NULL,
`discount_card` BIT NOT NULL DEFAULT FALSE);

CREATE TABLE `orders`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`order_datetime` DATETIME NOT NULL,
`customer_id` INT NOT NULL,
CONSTRAINT fk_orders_customers
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`id`));

CREATE TABLE `orders_products`(
`order_id` INT,
`product_id` INT,
 KEY pk_orders_products(`order_id`, `product_id`),
CONSTRAINT fk_orders_products_orders
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`id`),
CONSTRAINT fk_orders_products_products
FOREIGN KEY (`product_id`)
REFERENCES `products`(`id`));

#2 Insert
INSERT INTO `reviews` (`content`,`rating`, `picture_url`, `published_at`)
SELECT LEFT(p.`description`, 15), p.`price`/8, reverse(p.`name`), DATE('2010-10-10')
FROM `products` AS p
WHERE p.`id` >= 5;

#3 Update
UPDATE `products`
SET `quantity_in_stock` = `quantity_in_stock` - 5
WHERE `quantity_in_stock` BETWEEN 60 AND 70;

#4 Delete
DELETE FROM `customers` AS c
WHERE c.`id` NOT IN (SELECT o.`customer_id` FROM `orders` AS o);

#5
SELECT *
FROM `categories`
ORDER BY `name` DESC;

#6
SELECT `id`, `brand_id`, `name`, `quantity_in_stock`
FROM `products`
WHERE `price` > 1000 AND `quantity_in_stock` < 30		
ORDER BY `quantity_in_stock`, `id`;

#7
SELECT * 
FROM `reviews`
WHERE `content` LIKE 'My%' AND char_length(`content`) > 61
ORDER BY `rating` DESC;

#8
SELECT concat_ws(' ', c.`first_name`, c.`last_name`) AS 'full_name', 
		c.`address`, o.`order_datetime` AS 'order_date'
FROM `customers` AS c
JOIN `orders` AS o
ON o.`customer_id` = c.`id`
WHERE YEAR(o.`order_datetime`) <= 2018
ORDER BY `full_name` DESC;

#9
SELECT COUNT(p.`id`) AS 'items_count', c.`name`, SUM(p.`quantity_in_stock`) AS 'total_quantity'
FROM `categories` AS c
JOIN `products` AS p
ON p.`category_id` = c.`id`
GROUP BY p.`category_id`
ORDER BY `items_count` DESC, `total_quantity` ASC
LIMIT 5;

#10
DELIMITER $$
CREATE FUNCTION `udf_customer_products_count` (`name` VARCHAR(30))
RETURNS INT
    DETERMINISTIC
BEGIN

RETURN 
		(SELECT COUNT(p.`id`)
		FROM `customers` AS c
		JOIN `orders` AS o
		ON o.`customer_id` = c.`id` 
        JOIN `orders_products` AS op
        ON o.`id` = op.`order_id`
        JOIN `products` AS p
        ON op.`product_id` = p.`id`
		WHERE c.`first_name` = `name`);
END $$
DELIMITER ;

SELECT c.first_name, c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';

#11
DELIMITER $$
CREATE PROCEDURE `udp_reduce_price`(category_name VARCHAR(50))
BEGIN
		UPDATE `products` AS p
		JOIN `categories` AS c
		ON p.`category_id` = c.`id`
        JOIN `reviews` AS r
        ON r.`id` = p.`review_id`
        SET p.`price`  = p.`price` - 0.3 * p.`price`
		WHERE c.`name` = category_name AND r.`rating` < 4;

END$$
DELIMITER ;

CALL `udp_reduce_price` ('Phones and tablets');
