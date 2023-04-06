USE vk;

/*Показать список имен (только firstname) пользователей без повторений в алфавитном порядке.
 */
SELECT DISTINCT firstname FROM users ORDER BY firstname;


/*Выведите количество мужчин старше 35 лет.
 */
SELECT COUNT(*) AS quantity
FROM profiles p WHERE (gender = 'm') AND DATEDIFF(NOW(), birthday)>35;


/*Показать среднее арифметическое дат рождения пользователей в форме даты
 */
SELECT FROM_DAYS(AVG(birthday)) from vk.profiles;


/*Сколько заявок в друзья в каждом статусе? (таблица friend_requests)
*/
SELECT status, COUNT(*) AS r_count FROM friend_requests GROUP BY status;



/*Выведите номер пользователя, который отправил больше всех заявок в друзья (таблица friend_requests)
*/
SELECT DISTINCT initiator_user_id, firstname, lastname, COUNT(*) AS r_count 
FROM friend_requests, users WHERE initiator_user_id = users.id GROUP BY initiator_user_id LIMIT 1;


/*Выведите названия и номера групп, имена которых состоят из 5 символов
*/
SELECT name FROM communities WHERE name LIKE '_____';


/* Подсчитать количество групп, в которые вступил каждый пользователь. 
*/
SELECT user_id, COUNT(*) AS group_count
FROM users_communities
GROUP BY user_id;


/*Подсчитать количество пользователей в каждом сообществе.
*/
SELECT c.id, COUNT(*) AS followers FROM communities c
JOIN users_communities uc ON uc.community_id = c.id
GROUP BY c.id;


/*Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем (написал ему сообщений).
*/
SELECT from_user_id, CONCAT(u2.firstname, ' ', u2.lastname) AS from_name, COUNT(*) FROM messages m
JOIN users AS u2 ON (from_user_id = u2.id)
WHERE to_user_id = 100
GROUP BY m.from_user_id
ORDER BY COUNT(*) DESC
LIMIT 1;


/*Собрать статистику по типам файлов (как типам новостей), какие пользователи их лайкали
*/
SELECT media_id, filetype, who_likes
FROM likes l 
RIGHT JOIN feed f ON f.id = l.feed_id
JOIN media m ON m.id = media_id
WHERE who_likes IS NOT NULL
ORDER BY filetype;
