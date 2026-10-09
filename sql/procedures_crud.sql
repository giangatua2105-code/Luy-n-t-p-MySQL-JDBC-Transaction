USE demo;

-- 1. Lấy danh sách tất cả User
DROP PROCEDURE IF EXISTS get_all_users;
DELIMITER $$
CREATE PROCEDURE get_all_users()
BEGIN
    SELECT users.id, users.name, users.email, users.country
    FROM users;
END$$
DELIMITER ;

-- 2. Sửa thông tin User (OUT affected_rows: số dòng bị thay đổi)
-- Lưu ý: tên tham số có tiền tố p_ để KHÔNG trùng tên cột, tránh lỗi "WHERE id = id" luôn đúng
DROP PROCEDURE IF EXISTS update_user;
DELIMITER $$
CREATE PROCEDURE update_user(
    IN p_id INT,
    IN p_name VARCHAR(120),
    IN p_email VARCHAR(220),
    IN p_country VARCHAR(120),
    OUT affected_rows INT
)
BEGIN
    UPDATE users
    SET name = p_name, email = p_email, country = p_country
    WHERE users.id = p_id;
    SET affected_rows = ROW_COUNT();
END$$
DELIMITER ;

-- 3. Xoá User
-- Phải xoá user_permission trước (khoá ngoại), gói trong 1 transaction để lỗi thì rollback
DROP PROCEDURE IF EXISTS delete_user;
DELIMITER $$
CREATE PROCEDURE delete_user(
    IN p_id INT,
    OUT affected_rows INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    DELETE FROM user_permission WHERE user_permission.user_id = p_id;
    DELETE FROM users WHERE users.id = p_id;
    SET affected_rows = ROW_COUNT();
    COMMIT;
END$$
DELIMITER ;
