-- 저장프로시저

--- ** 사용예1.
-- 오늘이 2005년 1월 31일이라고 가정. 오늘까지 발생한 상품입고정보를 이용해 
-- 재고 수불 테이블 UPDATE 프로시저 생성
-- 1. 프로시저명 : proc_remain_in
-- 2. 매개변수 : 상품코드, 매입수량
-- 3. 처리 내용 : 해당 상품코드에 대한 입고수량, 전체재고수량, 처리일자 UPDATE

-- 1) 2005년 상품별 매입수량 집계 (프로시저 외부)
-- 2) 1의 결과 각 행을 프로시저에 전달 --> 하나씩 꺼내서 줘야 하니까 커서가 필요.
-- 3) 프로시저에서 재고수불테이블 UPDATE

--(프로시저 생성)
CREATE OR REPLACE PROCEDURE proc_remain_in( 
        p_code IN prod.prod_id%TYPE,        
        p_cnt IN NUMBER)
IS

BEGIN
    UPDATE remain
        SET (remain_i, remain_j_99, remain_date) = (SELECT remain_i + p_cnt, 
                                                           remain_j_99 + p_cnt,
                                                           TO_DATE('20050130')
                                                    FROM remain
                                                    WHERE remain_year = '2005' AND
                                                          prod_id = p_code )
        WHERE remain_year = '2005' AND
              prod_id = p_code;
END;

--(2005년 1월 상품별 매입집계)
SELECT buy_prod bcode,
       SUM(buy_qty) bamt -- sum이라는 함수가 쓰여졌으니까 그냥 넘겨줄 수 없다. 컬럼 별칭이 필요.
FROM buyprod
WHERE buy_date BETWEEN '20050101' AND '20050131'
GROUP BY buy_prod;

--(익명 블록 작성)

DECLARE
    CURSOR cur_buy_amt
    IS
      SELECT buy_prod bcode,
             SUM(buy_qty) bamt
      FROM buyprod
      WHERE buy_date BETWEEN '20050101' AND '20050131'
      GROUP BY buy_prod;
BEGIN
    FOR rec01 IN cur_buy_amt LOOP
        proc_remain_in(rec01.bcode, rec01.bamt);
    END LOOP;
END;

--(검증 : remain 테이블의 내용을 VIEW로 만들기)

CREATE OR REPLACE VIEW v_remain01
AS
    SELECT *
    FROM remain;
                
CREATE OR REPLACE VIEW v_remain02
AS
    SELECT *
    FROM remain;
                
SELECT *
FROM v_remain01;                    
SELECT *
FROM v_remain02;

SELECT *
FROM member;



--- ** 사용예2.
-- 회원 아이디를 입력받아 그 회원의 이름, 주소, 직업 반환하는 프로시저 (반환 값이 없는 프로시저. 매개 변수를 통해 반환할 수는 있다. )
-- 1. 프로시저명 : proc_mem_info
-- 2. 매개변수 : 입력용 - 아이디 / 출력용 - 이름, 주소, 직업

--(프로시저 생성)
CREATE OR REPLACE PROCEDURE proc_mem_info( p_id     IN member.mem_id%TYPE,
                                           p_name   OUT member.mem_name%TYPE,
                                           p_addr   OUT VARCHAR2,
                                           p_job    OUT member.mem_job%TYPE)                                        
IS
BEGIN
    SELECT mem_name, mem_add1 || ' ' || mem_add2, mem_job
      INTO p_name, p_addr, p_job
    FROM member
    WHERE mem_id = p_id;
END;
    
--(프로시저 실행)

ACCEPT pid PROMPT '아이디 입력>'
DECLARE
    v_name  member.mem_name%TYPE;
    v_addr  VARCHAR2(200);
    v_job   member.mem_job%TYPE;
BEGIN
    proc_mem_info(LOWER('&pid'), v_name, v_addr, v_job);
    DBMS_OUTPUT.PUT_LINE( '아이디 : ' || '&pid');
    DBMS_OUTPUT.PUT_LINE( '이름 : ' || v_name);
    DBMS_OUTPUT.PUT_LINE( '주소 : ' || v_addr);
    DBMS_OUTPUT.PUT_LINE( '직업 : ' || v_job);
END;

SELECT *
FROM cart;
SELECT *
FROM prod;
SELECT *
FROM member;

--- ** 문제.
-- 년도를 입력 받아 해당년도에 구매를 가장 많이 한 회원 이름과 구매액을 반환하는 프로시저를 작성
-- 1. 프로시저명 : proc_mem_ptop
-- 2. 매개변수 : 입력용 - 년도 / 출력용 - 이름, 구매액

-- (년도별로 구매를 가장 많이 한 사람의 이름, 구매총액 조회)
SELECT b.mem_name, b.pp
FROM 
    (SELECT ROWNUM rn, a.mem_name, a.pp
     FROM
         (SELECT m.mem_name, SUM(p.prod_price * c.cart_qty) pp
          FROM member m, cart c, prod p
          WHERE m.mem_id = c.cart_member AND
                c.cart_prod = p.prod_id AND -- 상품코드가 같은 것의 가격을 갖고 오기
                SUBSTR(c.cart_no, 1, 4) = '2005'
          GROUP BY m.mem_name
          ORDER BY pp DESC) a) b
WHERE b.rn = 1;
    
-- (프로시저 작성)    
CREATE OR REPLACE PROCEDURE proc_mem_ptop(
                            p_year    IN NUMBER, 
                            p_name    OUT member.mem_name%TYPE,
                            p_price   OUT NUMBER)
IS
BEGIN
    SELECT b.mem_name, b.pp
      INTO p_name, p_price
    FROM 
        (SELECT ROWNUM rn, a.mem_name, a.pp
         FROM
             (SELECT m.mem_name, SUM(p.prod_price * c.cart_qty) pp
              FROM member m, cart c, prod p
              WHERE m.mem_id = c.cart_member AND
                    c.cart_prod = p.prod_id AND
                    SUBSTR(c.cart_no, 1, 4) = p_year
              GROUP BY m.mem_name
              ORDER BY pp DESC) a) b
    WHERE b.rn = 1; 
END;

-- (프로시저 실행)
ACCEPT pyear PROMPT '년도 입력 : '

DECLARE
    v_name      member.mem_name%TYPE;
    v_price     NUMBER := 0;
BEGIN
    proc_mem_ptop('&pyear', v_name, v_price);
    DBMS_OUTPUT.PUT_LINE('회원이름 : ' || v_name);
    DBMS_OUTPUT.PUT_LINE('구매금액 : ' || TO_CHAR(v_price, '99,999,999'));
END;

-------------- (선생님 답안)
--(2005년도 회원별 구매금액 계산)
SELECT m.mem_name, a.amt
FROM (SELECT c.cart_member mid, SUM(c.cart_qty * p.prod_price) amt
      FROM cart c, prod p
      WHERE c.cart_prod = p.prod_id AND
            SUBSTR(c.cart_no, 1, 4) = '2005'        -- 문자열로 변수를 받으면 비교하기 좋겠다.
      GROUP BY c.cart_member
      ORDER BY 2 DESC) a, member m
WHERE m.mem_id = a.mid AND
      ROWNUM = 1;

--(프로시저 만들기)
CREATE OR REPLACE PROCEDURE proc_mem_ptop(
    p_year  IN CHAR, 
    p_name  OUT member.mem_name%TYPE,
    p_amt   OUT NUMBER)
IS
BEGIN
     SELECT m.mem_name, a.amt
       INTO p_name, p_amt
     FROM (SELECT c.cart_member mid, SUM(c.cart_qty * p.prod_price) amt
            FROM cart c, prod p
            WHERE c.cart_prod = p.prod_id AND
            SUBSTR(c.cart_no, 1, 4) = p_year
            GROUP BY c.cart_member
            ORDER BY 2 DESC) a, member m
      WHERE m.mem_id = a.mid AND
      ROWNUM = 1;
END;

--(프로시저 실행)
DECLARE
    v_name  member.mem_name%TYPE;
    v_amt   NUMBER := 0;    -- NUMBER의 경우 크기를 지정하지 않아도 된다. 초기화는 반드시 필요하지만.
BEGIN
    proc_mem_ptop('2005', v_name, v_amt);
    DBMS_OUTPUT.PUT_LINE('회원명 : ' || v_name);
    DBMS_OUTPUT.PUT_LINE('구매금액 : ' || TO_CHAR(v_amt, '99,999,999'));

END;


--** 문제2. 2005년도 구매금액이 없는 회원을 찾아 
---- >> 커서에서 회원번호 생성해 하나씩 읽어서 멤버 테이블과 비교하고, delete를 Y로 업데이트
---- >>>> 값이 없는 회원도 불러온 후, 값이 없는 회원을 커서로 하나씩 읽기
-- 회원테이블의 삭제여부 컬럼(mem_delete)의 값을 'Y'로 변경하는 프로시저 작성

-- ?? 2005년도 구매금액이 없는 회원 조회 쿼리 중 WHERE 절에 SUBSTR(c.cart_no, 1, 4) = '2005' 쓸 수 없다. 
--    구매 기록이 없는 회원은 cart_no가 없기 때문에, 아무런 결과도 나오지 않는다. 
--    cart 테이블이 2005년도 뿐 아니라 여러 년도의 구매 기록을 저장하고 있다면, 
--    어떻게 2005년에 구매 기록이 없는 회원만 조회할 수 있지? 차집합으로 전체 회원 - 2005년도 구매 기록 있는 회원?

-- 구매 기록이 없는 회원 조회 
SELECT m.mem_id, SUM(c.cart_qty)
FROM cart c, member m
WHERE m.mem_id = c.cart_member(+) AND
      SUBSTR(c.cart_no, 1, 4) = '2005' -- 이 조건이 있으면 구매 기록이 없는 회원은 조회할 수 없다. 
GROUP BY m.mem_id
HAVING SUM(c.cart_qty) IS NULL;

-- 구매 기록이 없는 회원 조회 (수정)
SELECT m.mem_id, SUM(c.cart_qty)
FROM cart c, member m
WHERE m.mem_id = c.cart_member(+)
GROUP BY m.mem_id, c.cart_no
HAVING SUM(c.cart_qty) IS NULL;

-- 프로시저 생성
CREATE OR REPLACE PROCEDURE proc_mem_delete (
    p_mid IN member.mem_id%TYPE)
IS
BEGIN
    UPDATE member SET 
        mem_delete = 'Y'
    WHERE p_mid = mem_id;
END;

-- 프로시저 실행
DECLARE
BEGIN
    FOR rec5 IN (SELECT m.mem_id mid, SUM(c.cart_qty) qyt
                 FROM cart c, member m
                 WHERE m.mem_id = c.cart_member(+)
                 GROUP BY m.mem_id, c.cart_no
                 HAVING SUM(c.cart_qty) IS NULL)
    LOOP
        proc_mem_delete(rec5.mid);
    END LOOP;
END;
------------------------- (선생님 답안)
-- 프로시저 : 입력 받은 회원번호로 해당 회원 삭제여부 컬럼값 변경
CREATE OR REPLACE PROCEDURE proc_mem_update(
    p_mid   IN member.mem_id%TYPE)
IS
BEGIN
    UPDATE member
        SET mem_delete = 'Y'
    WHERE mem_id = p_mid;   
    COMMIT;
END;

-- 구매기록 없는 회원
-- 2005년에 구매 사실이 있는 회원 아이디와 일치하지 않는 회원
SELECT mem_id
FROM member
WHERE mem_id NOT IN (SELECT cart_member 
                     FROM cart
                     WHERE cart_no LIKE '2005%');

-- 프로시저 실행 (FOR문 & 커서) 
DECLARE
BEGIN
    FOR rec_mid IN (SELECT mem_id
                 FROM member
                 WHERE mem_id NOT IN (SELECT cart_member 
                                      FROM cart
                                      WHERE cart_no LIKE '2005%'))
    LOOP
        proc_mem_update(rec_mid.mem_id);
    END LOOP;
END;

SELECT *
FROM member;






