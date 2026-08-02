--Copy csv data
INSERT INTO `games` (
	title, console, genre, publisher, developer, critic_score, total_sales, na_sales,
	jp_sales, pal_sales, other_sales, release_date, last_update
)
SELECT title, console, genre, publisher, developer, critic_score, total_sales, na_sales,
jp_sales, pal_sales, other_sales, release_date, last_update
FROM `vgchartz-2024`
ORDER BY title ASC;

-- At this stage, in the games table the id columns temporarily contain text values imported from the CSV.
-- The following updates replace those names with the corresponding IDs.

-- Replace publisher names in the games table with publisher IDs from the publishers table
UPDATE `games`
JOIN `publishers` ON `publishers`.`publisher_name` = `games`.`publisher_id`
SET `games`.`publisher_id` = `publishers`.`id`;

-- Replace developer names in the games table with developer IDs from the developers table
UPDATE `games`
JOIN `developers` ON `developers`.`dev_name` = `games`.`developer_id`
SET `games`.`developer_id` = `developers`.`id`;

-- Replace console names in the games table with console IDs from the consoles table
UPDATE `games`
JOIN `consoles` ON `consoles`.`console_name` = `games`.`console_id`
SET `games`.`console_id` = `consoles`.`id`;

-- Replace genre names in the games table with genre IDs from the genres table
UPDATE `games`
JOIN `genres` ON `genres`.`game_genre` = `games`.`genre_id`
SET `games`.`genre_id` = `genres`.`id`;

-- Number of games
SELECT COUNT(*) AS total_games FROM games;

-- Games with critic score greater than 9
SELECT title, critic_score  FROM games WHERE critic_score >= 9
ORDER BY critic_score DESC, title;

-- Top 100 highest selling games
SELECT title, total_sales FROM games
ORDER BY total_sales DESC LIMIT 100;

-- games with missing data
SELECT * FROM games WHERE
	critic_score IS NULL
	OR critic_score = 0
	OR total_sales IS NULL
	OR na_sales IS NULL
	OR jp_sales IS NULL
	OR euro_african_sales IS NULL
	OR other_sales IS NULL
	OR release_date IS NULL;

-- Developers ranked by number of games created
SELECT developers.dev_name, COUNT(*) AS games_created FROM games
JOIN developers ON games.developer_id = developers.id
WHERE developers.dev_name IS NOT NULL AND developers.dev_name <> 'Unknown'
GROUP BY developers.dev_name
ORDER BY games_created DESC;

-- Publishers ranked by number of games published
SELECT publishers.publisher_name, COUNT(*) AS games_published FROM games
JOIN publishers ON games.publisher_id = publishers.id
WHERE publishers.publisher_name IS NOT NULL AND publishers.publisher_name <> 'Unknown'
GROUP BY publishers.publisher_name
ORDER BY games_published DESC;

-- Average critic score by genre
SELECT genres.game_genre, ROUND(AVG(games.critic_score),2) AS avg_score FROM games
JOIN genres ON games.genre_id = genres.id
WHERE games.critic_score > 0
GROUP BY genres.game_genre
ORDER BY avg_score DESC;

-- Total sales by genre
SELECT genres.game_genre, ROUND(SUM(games.total_sales),2) AS genre_sales FROM games
JOIN genres ON games.genre_id = genres.id
GROUP BY genres.game_genre
ORDER BY genre_sales DESC;

-- Total game sales by console
SELECT consoles.console_name, ROUND(SUM(games.total_sales),2) AS game_sales FROM games
JOIN consoles ON games.console_id = consoles.id
GROUP BY consoles.console_name
ORDER BY game_sales DESC;

-- Top-selling game for each genre from all consoles
SELECT overall_sales.title, overall_sales.game_genre, overall_sales.total_sales FROM (
	SELECT games.title, games.genre_id, genres.game_genre, ROUND(SUM(games.total_sales),2)  AS total_sales FROM games
    JOIN genres ON games.genre_id = genres.id
    GROUP BY games.title, games.genre_id, genres.game_genre) AS overall_sales
WHERE (overall_sales.genre_id, overall_sales.total_sales) IN (
	SELECT game_sales.genre_id, MAX(game_sales.total_sales) FROM (
		SELECT games.title, games.genre_id, SUM(games.total_sales) AS total_sales FROM games
        GROUP BY title, genre_id) AS game_sales
    GROUP BY game_sales.genre_id
)
ORDER BY overall_sales.game_genre;

-- Top 10 publishers by total sales
SELECT publishers.publisher_name, ROUND(SUM(games.total_sales), 2) AS total_sales FROM games
JOIN publishers ON games.publisher_id = publishers.id
WHERE publishers.publisher_name IS NOT NULL AND publishers.publisher_name <> 'Unknown'
GROUP BY publishers.publisher_name
ORDER BY total_sales DESC
LIMIT 10;

-- Consoles ranked by average critic score
SELECT consoles.console_name, ROUND(AVG(critic_score),2) AS avg_critic_score FROM games
JOIN consoles ON games.console_id = consoles.id
WHERE games.critic_score > 0
GROUP BY consoles.console_name
ORDER BY avg_critic_score DESC;

-- Games that sold more than the average
SELECT title, console_name, total_sales FROM games
JOIN consoles ON games.console_id = consoles.id
WHERE total_sales > (SELECT AVG(total_sales) FROM games WHERE games.total_sales > 0)
ORDER BY total_sales DESC;

-- Top 100 games in Japan
SELECT title, console_name, game_genre, jp_sales FROM games
JOIN genres ON games.genre_id = genres.id
JOIN consoles ON games.console_id = consoles.id
WHERE games.jp_sales > 0
ORDER BY jp_sales DESC
LIMIT 100;

-- Top 100 games in North America
SELECT title, console_name, game_genre, na_sales FROM games
JOIN genres ON games.genre_id = genres.id
JOIN consoles ON games.console_id = consoles.id
WHERE games.na_sales > 0
ORDER BY na_sales DESC
LIMIT 100;

-- Which region has the highest total sales
SELECT 'North America' AS region, ROUND(SUM(na_sales), 2) AS total_sales FROM games
UNION ALL
SELECT 'Japan', ROUND(SUM(jp_sales), 2) FROM games
UNION ALL
SELECT 'Europe & Africa', ROUND(SUM(euro_african_sales), 2) FROM games
UNION ALL
SELECT 'Other Regions', ROUND(SUM(other_sales), 2) FROM games
ORDER BY total_sales DESC;

-- Compare regional sales by genre
SELECT genres.game_genre, ROUND(SUM(games.na_sales),2) AS na_sales, ROUND(SUM(games.jp_sales),2) AS jp_sales,
 ROUND(SUM(games.euro_african_sales),2) AS euro_african_sales, ROUND(SUM(games.other_sales),2) AS other_sales FROM games
JOIN genres ON games.genre_id = genres.id
GROUP BY genres.game_genre
ORDER BY genres.game_genre;

-- Which genres have the largest number of games with recorded sales but relatively low average sales
SELECT genres.game_genre, COUNT(*) AS total_games, ROUND(SUM(games.total_sales),2) AS total_sales,
 ROUND(AVG(games.total_sales), 2) AS avg_sales_per_game FROM games
JOIN genres ON games.genre_id = genres.id
WHERE games.total_sales > 0
GROUP BY genres.game_genre
ORDER BY total_games DESC, avg_sales_per_game ASC;

-- Which developers create the highest-selling games on average with recorded sales
SELECT developers.dev_name, COUNT(*) AS games_created,
SUM(CASE WHEN games.total_sales = 0 THEN 1 ELSE 0 END) AS excluded_games,
SUM(CASE WHEN games.total_sales > 0 THEN 1 ELSE 0 END) AS games_with_sales,
ROUND(AVG(CASE WHEN games.total_sales > 0 THEN games.total_sales END), 2) AS avg_sales_per_game FROM games
JOIN developers ON games.developer_id = developers.id
WHERE developers.dev_name IS NOT NULL AND developers.dev_name <> 'Unknown'
GROUP BY developers.dev_name
ORDER BY avg_sales_per_game DESC;

-- Total games available for each console
SELECT * FROM total_console_games
ORDER BY total_games DESC;

-- Developers who achieved more than 50 million in total sales
SELECT * FROM developer_sales WHERE total_sales > 50
ORDER BY total_sales DESC;

-- Top 10 publishers by total sales
SELECT * FROM publisher_sales
ORDER BY total_sales DESC
LIMIT 10;
