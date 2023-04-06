USE vk;

/*Создайте представление с произвольным SELECT-запросом*/

CREATE OR REPLACE VIEW Preferences AS
	SELECT l.who_likes,
	CASE
		WHEN m.filetype = '.jpg' THEN 'картинки'
		WHEN m.filetype = '.mp3' THEN 'музыка'
		WHEN m.filetype = '.mp4' OR m.filetype = '.avi' THEN 'видеo'	
	END AS content_type
	FROM likes l
	JOIN media m on m.location_id = l.feed_id
	ORDER BY l.who_likes;

SELECT * FROM Preferences;

DROP VIEW Preferences;
	

/** Сколько новостей (записей в таблице media) у каждого пользователя? Вывести поля: news_count (количество новостей), user_id (номер пользователя), user_email (email пользователя). Попробовать решить с помощью CTE или с помощью обычного JOIN.*/

WITH news_cte as
(
	SELECT
		user_id,
		COUNT(*) AS news_count
	FROM feed
	GROUP BY user_id
)
SELECT email AS user_email, news_cte.*
FROM users u, news_cte
WHERE u.id = news_cte.user_id;


