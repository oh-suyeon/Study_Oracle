-- 테이블 생성
CREATE TABLE tb_jdbc_board2(
    board_no    NUMBER NOT NULL,
    title       VARCHAR2(500),
    content     VARCHAR2(2000),
    user_id     VARCHAR2(50),
    reg_date    DATE,
    CONSTRAINT pk_jdbc_board2 PRIMARY KEY(board_no));
    
-- 테이블 확인
SELECT *
FROM tb_jdbc_board2
ORDER BY board_no;

-- 테이블 행 삭제
DELETE FROM tb_jdbc_board2;
DELETE FROM tb_jdbc_user2;

-- 시퀀스 생성
CREATE SEQUENCE sq_board_no2
START WITH 1
INCREMENT BY 1;

-- 시퀀스 삭제
DROP SEQUENCE sq_board_no2;

-- 커밋
commit;

-- 기본 행 삽입
INSERT INTO tb_jdbc_board2 
    VALUES (sq_board_no2.NEXTVAL, '제목1', '내용1', '오수연', SYSDATE);
    
INSERT INTO tb_jdbc_board2 
    VALUES (sq_board_no2.NEXTVAL, '제목2', '내용2', '오수연', SYSDATE);
    
INSERT INTO tb_jdbc_board2 
    VALUES (sq_board_no2.NEXTVAL, '제목3', '내용3', '오수연', SYSDATE);
    
INSERT INTO tb_jdbc_board2 
    VALUES (sq_board_no2.NEXTVAL, '제목4', '내용4', '오수연', SYSDATE);


-- 유저 정보 테이블 생성
CREATE TABLE tb_jdbc_user2(
    user_id    VARCHAR2(50),
    password   VARCHAR2(200),
    user_name  VARCHAR2(500));
    
-- 유저 정보 테이블 조회
SELECT *
FROM tb_jdbc_user2;


SELECT a.board_no, a.title, a.content, b.user_name, a.reg_date
FROM tb_jdbc_board2 a LEFT OUTER JOIN tb_jdbc_user2 b
    ON a.user_id = b.user_id
ORDER BY a.board_no DESC;

SELECT A.BOARD_NO, A.TITLE, A.CONTENT, B.USER_NAME, A.REG_DATE
FROM TB_JDBC_BOARD2 A, TB_JDBC_USER2 B
WHERE A.USER_ID = B.USER_ID AND
BOARD_NO = 1;

SELECT COUNT(*)
FROM TB_JDBC_USER2
WHERE user_id = '789';
