#LAB
#1
SELECT `title` 
FROM books
WHERE `title` LIKE 'The%'
ORDER BY `id`;

#2
SELECT REPLACE(`title`, 'The', '***') 
AS 'title'
FROM `books`
WHERE `title` LIKE 'The%';

#3
SELECT ROUND(SUM(cost), 2) AS 'costs'
FROM books;

#4
SELECT  concat_ws(' ', `first_name`, `last_name`) AS 'Full Name',
TIMESTAMPDIFF(DAY, `born`, `died`) AS 'Days Lived'
FROM `authors`;

#5
SELECT `title`
FROM `books`
WHERE `title` LIKE '%Harry Potter%'
ORDER BY `id`;

#Exercises
#1
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `first_name` LIKE 'Sa%'
ORDER BY `employee_id`;

#2
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `last_name` LIKE '%ei%'
ORDER BY `employee_id`;

#3.1
SELECT `first_name`
FROM `employees`
WHERE `department_id` IN (3,10)
AND YEAR(`hire_date`) BETWEEN 1995 AND 2005
ORDER BY `employee_id`;
#3.2
SELECT `first_name` 
FROM `employees`
WHERE `department_id` IN (3, 10) 
AND extract(YEAR FROM `hire_date`) BETWEEN 1995 AND 2005
ORDER BY `employee_id`;

#4
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `job_title` NOT LIKE '%engineer%'
ORDER BY `employee_id`;

#5
SELECT `name`
FROM towns
WHERE char_length(`name`) IN (5,6)
ORDER BY `name` ASC;

#6
SELECT *
FROM towns
WHERE left(`name`, 1) IN ('M', 'K', 'B', 'E')
ORDER BY `name` ASC;

#7
SELECT *
FROM towns
WHERE left(`name`, 1) NOT IN ('R', 'B', 'D')
ORDER BY `name` ASC;

#8
CREATE VIEW `v_employees_hired_after_2000` AS
SELECT `first_name`, `last_name`
FROM `employees`
WHERE year(`hire_date`) > 2000;

SELECT * FROM `v_employees_hired_after_2000`;

#9
SELECT `first_name`, `last_name`
FROM `employees`
WHERE CHAR_LENGTH(`last_name`) = 5;

#10
SELECT `country_name`, `iso_code`
FROM `countries`
WHERE `country_name` LIKE '%A%A%A%'
ORDER BY `iso_code`;

#11.1
SELECT `peak_name`, `river_name`, concat(LOWER(`peak_name`), SUBSTRING(LOWER(`river_name`), 2)) AS 'mix'
FROM `peaks`, `rivers`
WHERE RIGHT (`peak_name`, 1) = LEFT(`river_name`, 1)
ORDER BY `mix`;

#11.2
SELECT `peak_name`, `river_name`, lower(concat(`peak_name`, substring(`river_name`, 2))) AS 'mix' 
FROM `peaks`, `rivers`
WHERE right(`peak_name`, 1) = left(`river_name`, 1)
ORDER BY `mix` ASC;

#12.1
SELECT `name`, SUBSTRING(`start`, 1, 10) AS 'start' 
FROM `games`
WHERE YEAR(`start`) BETWEEN 2011 AND 2012
ORDER BY `start`, `name`
LIMIT 50;

#12.2
SELECT `name`, date_format(`start`, '%Y-%m-%d') AS `start` FROM `games`
WHERE YEAR(`start`) BETWEEN 2011 AND 2012
ORDER BY `start` ASC, `name` ASC
LIMIT 50;

#13
SELECT `user_name`, SUBSTRING(`email`, LOCATE('@', `email`) + 1) AS 'Email Provider'
FROM `users`
ORDER BY `Email Provider`, `user_name`;

#14
SELECT `user_name`, `ip_address` 
FROM `users`
WHERE `ip_address` LIKE '___.1%.%.___'
ORDER BY `user_name`;

#15
SELECT `name` AS 'game',
CASE
WHEN HOUR(`start`) < 12 THEN 'Morning'
WHEN HOUR(`start`) < 18 THEN 'Afternoon'
ELSE 'Evening'
END 
AS 'Part of the Day',
CASE
WHEN `duration` < 4 THEN 'Extra Short'
WHEN `duration` < 7 THEN 'Short'
WHEN `duration` < 11 THEN 'Long'
ELSE 'Extra Long'
END 
AS 'Duration'
FROM `games`;

#16
SELECT `product_name`, `order_date`, 
DATE_ADD(`order_date`, INTERVAL 3 DAY) AS 'pay_due',
DATE_ADD(`order_date`, INTERVAL 1 MONTH) AS 'deliver_due'
FROM `orders`;