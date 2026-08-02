--TABLES
CREATE TABLE `games` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `console_id` int DEFAULT NULL,
  `genre_id` int DEFAULT NULL,
  `publisher_id` int DEFAULT NULL,
  `developer_id` int DEFAULT NULL,
  `critic_score` double DEFAULT NULL,
  `total_sales` double DEFAULT NULL,
  `na_sales` double DEFAULT NULL,
  `jp_sales` double DEFAULT NULL,
  `euro_african_sales` double DEFAULT NULL,
  `other_sales` double DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `publisher_id_idx` (`publisher_id`),
  KEY `developer_id_idx` (`developer_id`),
  KEY `console_id_idx` (`console_id`),
  KEY `genre_id_idx` (`genre_id`),
  CONSTRAINT `console_id` FOREIGN KEY (`console_id`) REFERENCES `consoles` (`id`),
  CONSTRAINT `developer_id` FOREIGN KEY (`developer_id`) REFERENCES `developers` (`id`),
  CONSTRAINT `genre_id` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`id`),
  CONSTRAINT `publisher_id` FOREIGN KEY (`publisher_id`) REFERENCES `publishers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65536 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `genres` (
  `id` int NOT NULL AUTO_INCREMENT,
  `game_genre` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `consoles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `console_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `developers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dev_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8820 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `publishers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `publisher_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- VIEWS
-- Total sales by publisher
CREATE VIEW publisher_sales AS
SELECT publishers.publisher_name, ROUND(SUM(games.total_sales), 2) AS total_sales FROM games
JOIN publishers ON games.publisher_id = publishers.id
GROUP BY publishers.publisher_name;

-- Total sales by developer
CREATE VIEW developer_sales AS
SELECT developers.dev_name, ROUND(SUM(games.total_sales), 2) AS total_sales FROM games
JOIN developers ON games.developer_id = developers.id
GROUP BY developers.dev_name;

-- Total number of games available for each console
CREATE VIEW total_console_games AS
SELECT consoles.console_name, COUNT(games.title) AS total_games FROM games
JOIN consoles ON games.console_id = consoles.id
GROUP BY consoles.console_name;


