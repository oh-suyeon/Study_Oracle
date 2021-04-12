-- (참고)시간 돌리기
SELECT *
FROM MEMBER AS OF TIMESTAMP(SYSTIMESTAMP - TNTERVAL '10' MINUTE)
WHERE mem_di = 'a001';

-- 테이블 생성
CREATE TABLE tb_jdbc_board(
    board_no    NUMBER NOT NULL,
    title       VARCHAR2(500),
    content     VARCHAR2(2000),
    user_id     VARCHAR2(50),
    reg_date    DATE,
    CONSTRAINT pk_jdbc_board PRIMARY KEY(board_no));
    
-- 비밀번호 컬럼 추가
ALTER TABLE tb_jdbc_board
    ADD password VARCHAR2(10) DEFAULT '0000' NOT NULL;

-- 테이블 확인
SELECT *
FROM tb_jdbc_board
ORDER BY board_no;

-- 테이블 행 삭제
DELETE FROM tb_jdbc_board;

-- 시퀀스 생성
CREATE SEQUENCE sq_board_no
START WITH 1
INCREMENT BY 1;

-- 시퀀스 삭제
DROP SEQUENCE sq_board_no;

-- 커밋
commit;

-- 기본 행 삽입
INSERT INTO tb_jdbc_board 
    VALUES (sq_board_no.NEXTVAL, '제목1', '내용1', '오수연', SYSDATE, '0000');
    
INSERT INTO tb_jdbc_board 
    VALUES (sq_board_no.NEXTVAL, '제목2', '내용2', '오수연', SYSDATE, '0000');
    
INSERT INTO tb_jdbc_board 
    VALUES (sq_board_no.NEXTVAL, '제목3', '내용3', '오수연', SYSDATE, '0000');
    
INSERT INTO tb_jdbc_board 
    VALUES (sq_board_no.NEXTVAL, '제목4', '내용4', '오수연', SYSDATE, '0000');