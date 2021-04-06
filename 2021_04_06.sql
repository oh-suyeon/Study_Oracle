 -- 쿼리를 뷰로 만들기
 
SELECT f.*
FROM 
    (SELECT a.cart_member memid, 
            b.mem_name memnm, 
            SUM(c.prod_price * a.cart_qty) price
     FROM cart a, member b, prod c
     WHERE c.prod_id = a.cart_prod AND
           b.mem_id = a.cart_member
     GROUP BY a.cart_member, b.mem_name
     ORDER BY price DESC) f
WHERE ROWNUM = 1;

CREATE OR REPLACE VIEW v_maxamt
AS
(
SELECT f.*
FROM 
    (SELECT a.cart_member memid, 
            b.mem_name memnm, 
            SUM(c.prod_price * a.cart_qty) price
     FROM cart a, member b, prod c
     WHERE c.prod_id = a.cart_prod AND
           b.mem_id = a.cart_member
     GROUP BY a.cart_member, b.mem_name
     ORDER BY price DESC) f
WHERE ROWNUM = 1
);

SELECT *
FROM v_maxamt;

-- 익명 블록에 뷰 활용하기 (저장이 되지 않기 때문에, 수행 가능 여부를 검증할 때 사용한다. 계속 불러서 사용하려면 이름이 있는 프로시저, 패키지, 함수로 만든다.)

DECLARE
    v_mid   v_maxamt.memid%TYPE;
    v_name  v_maxamt.memnm%TYPE;
    v_amt   v_maxamt.price%TYPE;
    v_res   VARCHAR2(100);  -- 자동으로 null로 초기화
BEGIN 
    SELECT memid, memnm, price      -- plsql의 셀렉트절 SELECT INTO(변수에 전부 할당) FROM WHERE
    INTO v_mid, v_name, v_amt
    FROM v_maxamt;
    
    v_res := v_mid || ', ' || v_name || ', ' || TO_CHAR(v_amt, '99,999,999');
    DBMS_OUTPUT.PUT_LINE(v_res);
END;

-- 상수 (선언시 반드시 값을 갖고 있어야 함) 고정된 특정한 값을 불러올 때 의미를 알 수 있는 이름으로 부를 수 있다.
-- 키보드로 수 하나를 입력 받아 그 값을 반지름으로하는 원의 넓이를 구하시오

ACCEPT p_num PROMPT '원의 반지름 : '

DECLARE 
    v_radius    NUMBER := TO_NUMBER('&p_num');
    v_pi        CONSTANT NUMBER := 3.1415926;
    v_res       NUMBER := 0;
    
BEGINㄴ
    v_res := v_radius * v_radius * v_pi;
    DBMS_OUTPUT.PUT_LINE('원의 너비 = ' || v_res);
END;
      
-- 커서
-- 생성하기 (상품 매입 테이블에서 BUYPROD 2005년 3월(bp.buy_date) 
--              상품별 매입현황(상품코드(bp.buy_prod = p.prod_id), 
--                            상품명(p.prod_name), 거래처명(p.prod_buyer = b.buyer_id / b.buyer_name), 
--                            매입수량(bp.buy_qty))을 출력하는 쿼리를 커서 사용해 작성)
-- (커서 없이 해보기)
SELECT bp.buy_prod 상품코드, p.prod_name 상품명, b.buyer_name 거래처명, bp.buy_qty 매입수량
FROM buyprod bp, prod p, buyer b
WHERE bp.buy_prod = p.prod_id AND
      p.prod_buyer = b.buyer_id AND
      TO_CHAR(bp.buy_date, 'yyyymm') = '200503';

-- (커서로 해보기)
DECLARE
    v_pcode     prod.prod_id%TYPE;
    v_pname     prod.prod_name%TYPE;
    v_bname     buyer.buyer_name%TYPE;
    v_amt       NUMBER := 0;      --크기를 모르겠으면 괄호를 안 쓰면 된다. 숫자를 0으로 초기화하는 걸 잊으면 안됨
    
    CURSOR cur_buy_info IS
        SELECT buy_prod, 
               SUM(buy_qty) amt
        FROM buyprod
        WHERE buy_date BETWEEN '20050301' AND '20050331'
        GROUP BY buy_prod;

BEGIN 
    OPEN cur_buy_info;      --자동으로 1번 행에 와 있다.  행의 수 만큼 반복해읽어와야 한다.
    
    LOOP 
        FETCH cur_buy_info INTO v_pcode,v_amt;  --커서에 들어있는 값을 여기에집어넣어라.
        EXIT WHEN cur_buy_info%NOTFOUND;
        
        SELECT prod_name, buyer_name INTO v_pname, v_bname
        FROM prod, buyer
        WHERE prod_id = v_pcode 
          AND prod_buyer = buyer_id;
          
        DBMS_OUTPUT.PUT_LINE('상품코드 : ' || v_pcode);
        DBMS_OUTPUT.PUT_LINE('상품명 : ' || v_pname);
        DBMS_OUTPUT.PUT_LINE('거래처명 : ' || v_bname);
        DBMS_OUTPUT.PUT_LINE('매입수량 : ' || v_amt);
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('자료 수 : ' || cur_buy_info%ROWCOUNT);
         
    CLOSE cur_buy_info; -- 닫아줘야 실행된다. 

END;

--- 상품분류코드 'P102' 에 속한 상품의 상품명, 매입가격, 마일리지를 출력하는 커서를 작성하시오

--(커서안쓰고) --> 조건에 맞는 7개행을 한번에 출력한다. 이걸 plsql에서 출력하려고 하면 커서가 필요하다. 
SELECT prod_name 상품명, prod_cost 매입가격, prod_mileage 마일리지 
FROM prod
WHERE prod_lgu = 'P102';

--(익명블록, 커서 쓰고)

ACCEPT p_lcode PROMPT '분류코드 입력 : '

DECLARE
    v_pname     prod.prod_name%TYPE;
    v_pcost     prod.prod_cost%TYPE;
    v_pmile     prod.prod_mileage%TYPE;
    CURSOR cur_prod_cost(p_lgu lprod.lprod_gu%TYPE) IS      -- 매개변수 사용하는 예
        SELECT prod_name, prod_cost, prod_mileage 
        FROM prod
        WHERE prod_lgu = p_lgu;
BEGIN 
    OPEN cur_prod_cost ('&p_lcode'); 
    DBMS_OUTPUT.PUT_LINE('상품명         ' || '       단 가   ' || '마일리지');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
    LOOP
        FETCH cur_prod_cost INTO v_pname, v_pcost, v_pmile;
        EXIT WHEN cur_prod_cost%NOTFOUND;    
        DBMS_OUTPUT.PUT_LINE(v_pname || '   ' || v_pcost || '   ' || NVL(v_pmile, 0));
    END LOOP;
    CLOSE cur_prod_cost; 
END;

-------
-------
-- 조건문
-- 상품 테이블에서 P201분류에 속한 상품들의 평균 단가를 구하고 
-- 해당 분류에 속한 상품들 판매단가와 비교하여
-- 같으면 '평균가격 상품', 
-- 적으면 '평균가격 이하 상품',
-- 많으면 '평균가격 이상 상품'을 비고난에 출력하시오.
-- 출력은 상품코드, 상품명, 가격, 비고이다. 

SELECT *
FROM prod;

DECLARE
    v_pcode     prod.prod_id%TYPE;
    v_pname     prod.prod_name%TYPE;
    v_pcost     prod.prod_price%TYPE;
    v_remarks   VARCHAR2(50);
    v_avg_price prod.prod_price%TYPE;
    
    CURSOR cur_prod_price IS
        SELECT prod_id, prod_name, prod_price
        FROM prod
        WHERE prod_lgu = 'P201';
    
BEGIN
    SELECT ROUND(AVG(prod_price)) INTO v_avg_price
    FROM prod
    WHERE prod_lgu = 'P201';
    
    /*SELECT prod_id, prod_name, prod_price INTO v_pcode, v_pname, v_pcost        -- 다수의 행 값을 하나의 변수에 넣을수 없기 때문에 커서가 필요
    FROM prod
    WHERE prod_lgu = 'P201'; */
    
    OPEN cur_prod_price;
    
    LOOP
        FETCH cur_prod_price INTO v_pcode, v_pname, v_pcost;
        EXIT WHEN cur_prod_price%NOTFOUND;
        
        IF v_pcost > v_avg_price THEN
            v_remarks := '평균가격이상상품';
        ELSIF v_pcost < v_avg_price THEN
            v_remarks := '평균가격이하상품';
        ELSE 
            v_remarks := '평균가격상품';
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(v_pcode || ',  ' || v_pname || ',  ' || v_pcost || ',  ' || v_remarks);
    END LOOP;
    
    CLOSE cur_prod_price;
END;

--- CASE
-- 수도요금계산 (톤 당 단가)
-- 1-10 : 350원
-- 11-20 : 550원
-- 21-30 : 900원
-- 그 이상 : 1500원
-- 하수도사용료 : 사용량 * 450원 
-- 26톤 사용시 요금
-- (10 * 350) + (10 * 350) + (6 * 900) + (26 * 450) = 3500 + 5500 + 5400 + 11,700 = 26,100

ACCEPT p_amount PROMPT '물 사용량 : '

DECLARE 
    v_amt   NUMBER := TO_NUMBER('&p_amount');
    v_wa1   NUMBER := 0;    -- 물사용요금
    v_wa2   NUMBER := 0;    -- 하수도사용요금
    v_hap   NUMBER := 0;    -- 요금 합계
    
BEGIN
    CASE WHEN v_amt BETWEEN 1 AND 10 THEN
                v_wa1 := v_amt * 350;
         WHEN v_amt BETWEEN 11 AND 20 THEN
                v_wa1 := 3500 + (v_amt - 10) * 550;
         WHEN v_amt BETWEEN 21 AND 30 THEN
                v_wa1 := 3500 + 5500 + (v_amt - 20) * 900;
         ELSE
                v_wa1 := 3500 + 5500 + 9000 + (v_amt - 30) * 1500;            
    END CASE;
    
        v_wa2 := v_amt * 450;
        v_hap := v_wa1 + v_wa2;
    
    DBMS_OUTPUT.PUT_LINE(v_amt || '톤의 수도요금 : ' || TO_CHAR(v_hap, '999,999') || '원');
    
END;
    
















