-- 반복문 & 저장 프로시저 복습

--1. LOOP 구구단 출력하기
ACCEPT p_base PROMPT '구구단 몇 단? > '
DECLARE
    v_cnt   NUMBER := 1;
    v_res   NUMBER := 0;
    v_base  NUMBER := TO_NUMBER('&p_base');
BEGIN
    LOOP
    EXIT WHEN v_cnt > 9;
    v_res := v_base * v_cnt;
    DBMS_OUTPUT.PUT_LINE(v_base || '*' || v_cnt || '=' || v_res);
    v_cnt := v_cnt + 1;
    END LOOP;
END;

--2. LOOP 피보나치 수열 출력
ACCEPT p_limit PROMPT '1~n까지 피보나치 수열 구하기! n 입력 > '
DECLARE
v_nn    NUMBER := 0;
v_bn    NUMBER := 1;
v_bbn   NUMBER := 1;
v_limit NUMBER := TO_NUMBER('&p_limit');
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_bn);
    DBMS_OUTPUT.PUT_LINE(v_bbn);
    LOOP
    v_nn := v_bn + v_bbn;
    EXIT WHEN v_nn > v_limit;
    DBMS_OUTPUT.PUT_LINE(v_nn);
    v_bbn := v_bn;
    v_bn := v_nn;
    END LOOP;
END;

--3. WHILE & CURSOR로 회원 마일리지 3000이상 회원의 회원번호, 이름, 구매횟수, 구매금액 구하기
DECLARE 
v_id        member.mem_id%TYPE;
v_name      member.mem_name%TYPE;
v_qty       NUMBER := 0;
v_price     NUMBER := 0;

CURSOR cur_mile IS
    SELECT mem_id, mem_name
    FROM member
    WHERE mem_mileage >= 3000;
    
BEGIN
    
    OPEN cur_mile;
    FETCH cur_mile INTO v_id, v_name;
    
    WHILE cur_mile%FOUND LOOP
    
        SELECT COUNT(cart.cart_prod), SUM(cart.cart_prod * prod.prod_price)
               INTO v_qty, v_price
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              v_id = cart.cart_member AND
              SUBSTR(cart.cart_no, 1, 6) = '200505';
          
        DBMS_OUTPUT.PUT_LINE(v_id || ', ' || v_name || ', ' || v_qty || ', ' || v_price);
    
        FETCH cur_mile INTO v_id, v_name;
    
    END LOOP;
    
    CLOSE cur_mile;

END;
    
-- 4. for 일반
DECLARE
v_cnt NUMBER := 1;
v_res NUMBER := 0;
BEGIN
    FOR i IN 1..9 LOOP
        v_res := 7 * v_cnt;
        DBMS_OUTPUT.PUT_LINE(7 || '*' || v_cnt || '=' || v_res);
        v_cnt := v_cnt + 1;
    END LOOP;
    
END;
    
    
DECLARE
v_cnt NUMBER := 0;
v_amt NUMBER := 0;
BEGIN
    FOR rec_cart IN (SELECT mem_id, mem_name
                     FROM member
                     WHERE mem_mileage >= 3000)            
    LOOP
        SELECT SUM(cart.cart_qty * prod.prod_price),
               COUNT(prod.prod_price)
               INTO v_cnt, v_amt
        FROM cart, prod
        WHERE cart.cart_prod = prod.prod_id AND
              cart.cart_member = rec_cart.mem_id AND
              SUBSTR(cart.cart_no, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(rec_cart.mem_id || ', ' || rec_cart.mem_name || ', ' || v_cnt || v_amt);
   END LOOP;
END;
    
CREATE TABLE remain_test(
    remain_year     CHAR(10),
    prod_id         VARCHAR2(10),
    remain_j_00     NUMBER(5)      DEFAULT 0,
    remain_i        NUMBER(5)      DEFAULT 0,
    remain_o        NUMBER(5)      DEFAULT 0,
    remain_j_99     NUMBER(5)      DEFAULT 0,
    remain_date     DATE,
    
    CONSTRAINT pk_remain_test PRIMARY KEY(remain_year, prod_id),
    CONSTRAINT fk_remain_test_prod FOREIGN KEY(prod_id)
        REFERENCES prod(prod_id));
    
INSERT INTO remain_test(remain_year, prod_id, remain_j_00, remain_j_99, remain_date)
    SELECT '2005', prod_id, prod_properstock, prod_properstock, TO_DATE('20041231')
    FROM prod;
    
SELECT *
FROM remain_test;
    
ROLLBACK;
    
