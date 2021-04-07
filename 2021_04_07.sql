 --반복문 LOOP) 구구단의 7단을 출력
 
DECLARE
    v_cnt   NUMBER := 1;
    v_res   NUMBER := 0;
    
BEGIN 
    LOOP
        v_res := 7 * v_cnt;
        EXIT WHEN v_cnt > 9;
        DBMS_OUTPUT.PUT_LINE(7 || '*' || v_cnt || '=' || v_res);
        v_cnt := v_cnt + 1;
    END LOOP;

END;
    
 -- 1~50사이의 피보나치 수를 구하여 출력하시오. 
 -- (첫째 및 둘째 항이 1이며 그 뒤의 모든 항은 바로 앞 두 항의 합인 수열)
 -- 검색 알고리즘 (피보나치 서치)로 많이 쓰인다. 
 
DECLARE
    v_pnum      NUMBER := 1; -- 앞 항
    v_ppnum     NUMBER := 1; -- 앞 앞 항
    v_currnum   NUMBER := 0;
    v_res       VARCHAR(100);
BEGIN
    v_res := v_pnum || ', ' || v_ppnum;
    
    LOOP
        v_currnum := v_ppnum + v_pnum;
        EXIT WHEN v_currnum >= 50;
        v_res := v_res || ', ' || v_currnum;
        v_ppnum := v_pnum;      -- 중요한 줄 (32-33)    두 행 순서를 바꾸면 안된다!
        v_pnum := v_currnum;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('1~50 사이의 피보나치 수 : ' || v_res);
END;

-- 반복문 WHILE ) 첫 날에 100원 둘째날 부터 전날의 2배 씩 저축할 경우최초로 100만원을 넘는 날과 저축한 금액을 구하시오.

DECLARE
    v_days  NUMBER := 1;
    v_amt   NUMBER := 100;
    v_sum   NUMBER := 0; -- 저축한 금액 합계
BEGIN
    WHILE v_sum < 1000000 LOOP
        v_sum := v_sum + v_amt;
            DBMS_OUTPUT.PUT_LINE('날수 : ' || v_days);
            DBMS_OUTPUT.PUT_LINE('저축 총합 : ' || v_sum);
            DBMS_OUTPUT.PUT_LINE('당일 저축 금액 : ' || v_amt);
        v_days := v_days + 1;
        v_amt := v_amt * 2;
    END LOOP;
END;

-- while과 커서를 함께 사용할 때 주의할 점
-- 회원 테이블member에서 마일리지가 3000이상인 회원들 찾아 
-- cart테이블과 연결해 그들이 2005년 5월에 구매한 횟수, prod 테이블과 연결해 구매금액 합계 구하기(커서 사용 -- 마일리지 3000이상 회원 뽑기)
-- 출력 : 회원 번호, 회원 명, 구매횟수, 구매금액 (변수)

DECLARE
    v_memid     member.mem_id%TYPE;
    v_memnm     member.mem_name%TYPE;
    v_memqty    cart.cart_qty%TYPE := 0;
    v_memprice  prod.prod_price%TYPE := 0;
    
    CURSOR cur_mem_info IS
        SELECT mem_id, mem_name
        FROM member
        WHERE mem_mileage >= 3000;
BEGIN 
    OPEN cur_mem_info;
    
    WHILE cur_mem_info%FOUND LOOP
        FETCH cur_mem_info INTO v_memid, mem_nm;
        -- EXIT WHEN 없어도 되는 건가?
        SELECT SUM(cart.cart_qty * prod.prod_price), 
               COUNT(cart.cart_prod)
               INTO v_memprice, v_memqty
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id 
        GROUP BY cart_member;
        
    END LOOP;
    CLOSE cur_mem_info;
    
END;
    
-- 정답 (LOOP를 사용)
DECLARE
    v_mid   member.mem_id%TYPE;
    v_mname   member.mem_name%TYPE;
    v_cnt   NUMBER:= 0;
    v_amt   NUMBER:= 0;
    
    CURSOR cur_cart_amt IS 
        SELECT mem_id, mem_name
        FROM member
        WHERE mem_mileage >= 3000;
BEGIN 
    OPEN cur_cart_amt;
    LOOP
        FETCH cur_cart_amt INTO v_mid, v_mname;
        EXIT WHEN cur_cart_amt%NOTFOUND;
        
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(cart.cart_prod)
               INTO v_amt, v_cnt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = v_mid AND  -- 이런 식으로 커서 값을 받은 v_mid 변수를 활용하는 것.
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        
        DBMS_OUTPUT.PUT_LINE(v_mid || ', ' || v_mname || ', ' || v_cnt || ', ' || v_amt);
    END LOOP;
    CLOSE cur_cart_amt;
END;

-- 실수하기 좋은 예 (WHILE을 사용)
DECLARE
    v_mid   member.mem_id%TYPE;
    v_mname   member.mem_name%TYPE;
    v_cnt   NUMBER:= 0;
    v_amt   NUMBER:= 0;
    
    CURSOR cur_cart_amt IS 
        SELECT mem_id, mem_name
        FROM member
        WHERE mem_mileage >= 3000;
BEGIN 
    OPEN cur_cart_amt;
    WHILE cur_cart_amt%FOUND LOOP       -- FALSE가 나온다. 아직 FETCH로 값을 읽기 전이라서... 
        FETCH cur_cart_amt INTO v_mid, v_mname;
        
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(cart.cart_prod)
               INTO v_amt, v_cnt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = v_mid AND  
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        
        DBMS_OUTPUT.PUT_LINE(v_mid || ', ' || v_mname || ', ' || v_cnt || ', ' || v_amt);
    END LOOP;
    CLOSE cur_cart_amt;
END;
--WHILE 정답
DECLARE
    v_mid   member.mem_id%TYPE;
    v_mname   member.mem_name%TYPE;
    v_cnt   NUMBER:= 0;
    v_amt   NUMBER:= 0;
    
    CURSOR cur_cart_amt IS 
        SELECT mem_id, mem_name
        FROM member
        WHERE mem_mileage >= 3000;
BEGIN 
    OPEN cur_cart_amt;
    FETCH cur_cart_amt INTO v_mid, v_mname; -- FETCH의 위치를 변경해준다. 첫번째 값을 읽고 시작한다. 
    WHILE cur_cart_amt%FOUND LOOP             
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(cart.cart_prod)
               INTO v_amt, v_cnt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = v_mid AND  
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(v_mid || ', ' || v_mname || ', ' || v_cnt || ', ' || v_amt);
        FETCH cur_cart_amt INTO v_mid, v_mname; -- 다음 값을 읽어오는 FETCH는 마지막에 위치한다. 
    END LOOP;
    CLOSE cur_cart_amt;
END;

-- for 일반

DECLARE
    /*v_cnt NUMBER := 1; --승수 1~9*/
    /*v_res NUMBER := 0; --결과값*/
BEGIN
    FOR i IN 1..9 LOOP
        /*v_res := 7 * i;*/
        DBMS_OUTPUT.PUT_LINE(7 || '*' || i || '=' || 7 * i);
    END LOOP;
END;

-- 커서와 사용하는 for

DECLARE
    /*v_mid   member.mem_id%TYPE;
    v_mname   member.mem_name%TYPE;*/
    v_cnt   NUMBER:= 0;
    v_amt   NUMBER:= 0;
    
    CURSOR cur_cart_amt IS 
        SELECT mem_id, mem_name
        FROM member
        WHERE mem_mileage >= 3000;
BEGIN 
    /*OPEN cur_cart_amt;
    FETCH cur_cart_amt INTO v_mid, v_mname; */
    FOR rec_cart IN cur_cart_amt LOOP             
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(cart.cart_prod)
               INTO v_amt, v_cnt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = rec_cart.mem_id AND -- 레코드에 저장된 행 한줄 중에서 mem_id 컬럼의 값
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(rec_cart.mem_id || ', ' || rec_cart.mem_name || ', ' || v_cnt || ', ' || v_amt);
        /*FETCH cur_cart_amt INTO rec_cart.mem_id, rec_cart.mem_name; */
    END LOOP;
    /*CLOSE cur_cart_amt;*/
END;

-- for문에서 inline사용
DECLARE
    v_cnt   NUMBER:= 0;
    v_amt   NUMBER:= 0;
        
BEGIN 
    FOR rec_cart IN (SELECT mem_id, mem_name
                     FROM member
                     WHERE mem_mileage >= 3000) -- 더 간단하게 커서를 생성하지도 않기. 제일 많이 사용한다. 
    LOOP             
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(cart.cart_prod)
               INTO v_amt, v_cnt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = rec_cart.mem_id AND
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(rec_cart.mem_id || ', ' || rec_cart.mem_name || ', ' || v_cnt || ', ' || v_amt);
    END LOOP;
END;


--===============================================================================================

-- 프로시저

-- 다음조건에맞는 재고수불테이블을 생성하시오.
--1. 테이블명 : remain
--2. 컬럼 : remain_year/VARCHAR2(10)/pk (년도별로 중복되지 않게 저장해서 관리하려고. 기본키가 연도와 제품코드니까. )       
--         prod_id/VARCHAR2(10)/pk&fk          
--         remain_j_00/NUMBER(5)/DEFAULT 0 (기초재고) 기준 일자에 파악한 재고 properstock -- prod_totalstock(총재고량)/properstock(오늘 판매된 양의 130%)/properstock-totalstock(자동발주할양)
--         remain_i/NUMBER(5)/DEFAULT 0 (입고수량)  얼마나 사서
--         remain_o/NUMBER(5)/DEFAULT 0 (출고수량)  얼마나 팔았는지
--         remain_j_99/NUMBER(5)/DEFAULT 0 (기말재고) 마지막 날의 재고
--         remain_date/date/DEFAULT SYSDATE (처리일자)
        
CREATE TABLE remain(
     remain_year    CHAR(10), 
     prod_id        VARCHAR2(10),          
     remain_j_00    NUMBER(5)       DEFAULT 0, 
     remain_i       NUMBER(5)       DEFAULT 0, 
     remain_o       NUMBER(5)       DEFAULT 0, 
     remain_j_99    NUMBER(5)       DEFAULT 0, 
     remain_date    DATE            DEFAULT SYSDATE,
     
     CONSTRAINT pk_remain PRIMARY KEY(remain_year, prod_id), 
     CONSTRAINT fk_remain_prod FOREIGN KEY(prod_id)
        REFERENCES prod(prod_id));

/*ALTER TABLE prod
    ADD CONSTRAINT pk_prod PRIMARY KEY(prod_id);*/

-- 테이블에 기초자료 집어넣기
    -- 년도 :2005 / 상품코드: prod.prod_id / 기초재고: prod.prod_properstock / 입고수량, 출고수량 : 0 / 처리일자 : 2004/12/31 / 

INSERT INTO remain(remain_year, prod_id, remain_j_00, remain_j_99, remain_date)
    SELECT '2005', prod_id, prod_properstock, prod_properstock, TO_DATE('20041231', 'yyyymmdd')
    FROM prod;





    