/* Используя транзакцию, написать функцию, которая удаляет всю информацию об указанном пользователе из БД vk. Пользователь задается по id. Удалить нужно все сообщения, лайки, медиа записи, профиль и запись из таблицы users. Функция должна возвращать номер пользователя.*/

USE vk;

ALTER TABLE feed DROP CONSTRAINT `feed_ibfk_2`;
ALTER TABLE feed ADD CONSTRAINT media_fk FOREIGN KEY (media_id) REFERENCES media(id)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE media DROP CONSTRAINT `location_fk`;
ALTER TABLE media ADD CONSTRAINT location_fk FOREIGN KEY (location_id) REFERENCES feed(id)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE profiles DROP CONSTRAINT `profiles_ibfk_2`;


DROP FUNCTION IF EXISTS user_deletion;

DELIMITER \\
CREATE FUNCTION user_deletion(deleted_user_id BIGINT UNSIGNED)
RETURNS VARCHAR(20) READS SQL DATA
BEGIN
	DELETE FROM likes l WHERE l.who_likes = deleted_user_id; #сменить потом на who_likes
	WITH cte_feed as (
		SELECT feed_id from likes l 
		JOIN feed f ON f.id = l.feed_id
		WHERE f.user_id = deleted_user_id
	)
	DELETE FROM likes l WHERE feed_id in (select * from cte_feed);
	
	WITH cte_pleer AS (
		SELECT item_id from pleer p
		join media m on item_id=m.id
		join feed f on m.id = f.media_id
		where f.user_id = deleted_user_id
	)
	DELETE FROM pleer WHERE item_id in (select * from cte_pleer);
	
	DELETE FROM feed f WHERE f.user_id = deleted_user_id;
	DELETE FROM users_communities uc WHERE uc.user_id = deleted_user_id;
	DELETE FROM messages WHERE deleted_user_id = from_user_id OR deleted_user_id = to_user_id;
	DELETE FROM friend_requests fr WHERE deleted_user_id = fr.initiator_user_id OR target_user_id;
	DELETE FROM profiles p WHERE  p.user_id = deleted_user_id;
	DELETE FROM users WHERE id = deleted_user_id;
RETURN CONCAT(deleted_user_id, ' успешно удален');
END \\
DELIMITER ;

START TRANSACTION;
	SELECT user_deletion(1);
COMMIT;


/*Предыдущую задачу решить с помощью процедуры.*/

DROP PROCEDURE IF EXISTS `delete_user`;
DELIMITER \\
CREATE PROCEDURE `delete_user`(deleted_user_id BIGINT UNSIGNED, 
OUT proc_result varchar(20))
BEGIN
	START TRANSACTION;
		DELETE FROM likes l WHERE l.who_likes = deleted_user_id; #сменить потом на who_likes
		WITH cte_feed as (
			SELECT feed_id from likes l 
			JOIN feed f ON f.id = l.feed_id
			WHERE f.user_id = deleted_user_id
		)
		DELETE FROM likes l WHERE feed_id in (select * from cte_feed);
		
		WITH cte_pleer AS (
			SELECT item_id from pleer p
			join media m on item_id=m.id
			join feed f on m.id = f.media_id
			where f.user_id = deleted_user_id
		)
		DELETE FROM pleer WHERE item_id in (select * from cte_pleer);
		
		DELETE FROM feed f WHERE f.user_id = deleted_user_id;
		DELETE FROM users_communities uc WHERE uc.user_id = deleted_user_id;
		DELETE FROM messages WHERE deleted_user_id = from_user_id OR deleted_user_id = to_user_id;
		DELETE FROM friend_requests fr WHERE deleted_user_id = fr.initiator_user_id OR target_user_id;
		DELETE FROM profiles p WHERE  p.user_id = deleted_user_id;
		DELETE FROM users WHERE id = deleted_user_id;
	COMMIT;
SET proc_result = CONCAT(deleted_user_id, ' успешно удален');
END \\
DELIMITER ;

call delete_user(2, @proc_res);
select @proc_res;


/** Написать триггер, который проверяет новое появляющееся сообщество. Длина названия сообщества (поле name) должна быть не менее 5 символов. Если требование не выполнено, то выбрасывать исключение с пояснением.
*/

DROP TRIGGER IF EXISTS new_commun_check;

DELIMITER \\
CREATE TRIGGER new_commun_check
BEFORE INSERT ON communities
FOR EACH ROW
BEGIN
	IF CHAR_LENGTH(NEW.name) < 5 THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Сообщество не добавлено. Имя должно быть длиннее 5 символов.';
	END IF;
END \\
DELIMITER ;

INSERT INTO communities (name, commun_type) VALUES ('hrec','public');































