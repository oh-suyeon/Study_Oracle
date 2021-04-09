DESC member;

-- USER DEFINED FUNCTION

-- 사용예1. 장바구니 테이블에서 2005년 6월 5일 판매된 상품 코드를 입력받아 상품명을 출력하는 함수를 작성하시오.
-- 1. 함수명 fn_pname_output,
-- 2. 매개변수 : 입력용 - 상품코드
-- 3. 반환값 : 상품명

CREATE OR REPLACE FUNCTION fn_pname_output(
    p_code IN prod.prod_id%TYPE)
    RETURN VARCHAR2     --';'이나 ',' 쓰지 않는 것 주의.
IS 
    v_pname prod.prod_name%TYPE; -- 이름을 구해서 밖으로 빼내기 전에 잠시 저장할 공간
BEGIN
    SELECT prod_name INTO v_pname
    FROM prod
    WHERE prod_id = p_code;
    
    RETURN v_pname;
END;

SELECT cart_member, fn_pname_output(cart_prod)   -- 함수가 3번 호출된다. 커서를 쓰지 않아도된다. 프로시저에서 커서를 쓰는것과 다르다. 
FROM cart
WHERE cart_no LIKE '20050605%';

-- 사용예2. 2005년 5월 모든 상품별 매입현황을 조회하시오 -- 일반outer조인 쓰면 안된다. 조건이 있기 때문에. ansi outer조인을 쓰던지, 서브쿼리를 써야한다. 

-- 일반 OUTER JOIN
SELECT p.prod_id 상품코드, --양쪽이 다 갖고 있는 컬럼일 경우 많은 쪽을 써야 한다. COUNT함수에는 *를 쓰면 안된다. null도 1로 친다. 해당 컬럼 명을 써줘야 한다.
       p.prod_name 상품명, 
       SUM(b.buy_qty) 매입수량, 
       SUM(b.buy_cost * b.buy_qty) 매입금액    
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id AND
      buy_date BETWEEN '20050501' AND '20050531'    -- 이 조건이 들어가니까 내부 조인으로 변했다. 이 일반조건이 외부 조인 조건과 함께 결합되면, 외부조인 결과가 나오지 않는다. 
GROUP BY p.prod_id, p.prod_name;

-- ansi OUTER JOIN
SELECT p.prod_id 상품코드, 
       p.prod_name 상품명, 
       NVL(SUM(b.buy_qty), 0) 매입수량, 
       NVL(SUM(b.buy_cost * b.buy_qty), 0) 매입금액    
FROM buyprod b RIGHT OUTER JOIN prod p ON (b.buy_prod = p.prod_id
     AND buy_date BETWEEN '20050501' AND '20050531') -- WHERE절의 조건도 함께 묶어준다. 조인되는 두 테이블에 대한 조건이기 때문에
GROUP BY p.prod_id, p.prod_name;

-- 서브 쿼리 (날짜 계산만 따로 해주기)
SELECT p.prod_id 상품코드,
       p.prod_name 상품명,
       NVL(qamt, 0) 매입수량,
       NVL(hamt, 0) 매입금액
FROM (SELECT buy_prod bid, 
             SUM(buy_qty) qamt,
             SUM(buy_qty * buy_cost) hamt
      FROM buyprod
      WHERE buy_date BETWEEN '20050501' AND '20050531'
      GROUP BY buy_prod) bp, prod p
WHERE bp.bid(+) = p.prod_id;

--함수 사용 -- 반환 값은 하나뿐이다. 그래서 출력할 값인 수량, 금액을 하나의문자열로 만들어준다.
CREATE OR REPLACE FUNCTION fn_buyprod_amt(
    p_code  IN prod.prod_id%TYPE)
    RETURN VARCHAR2
IS
    v_res VARCHAR2(100);    -- 매입수량합 || ' ,' ||매입금액합
    v_qty NUMBER := 0;  -- 매입수량합
    v_sum NUMBER := 0;  -- 매입금액합
BEGIN
    SELECT SUM(buy_qty), SUM(buy_qty * buy_cost)
        INTO v_qty, v_sum
    FROM buyprod
    WHERE buy_prod = p_code AND         -- 여기에서 하나의 상품만 출력되도록 제한되었기때문에 GROUP BY가 필요하지 않다. 
          buy_date BETWEEN '20050501' AND '20050531';
    
    IF v_qty IS NULL THEN
        v_res := '0';
    ELSE
        v_res := '수량: ' || TO_CHAR(v_qty, '999') || ' / ' || '구매금액: ' || TO_CHAR(v_sum, '99,999,999');
    END IF;
    RETURN v_res;
END;

SELECT *
FROM buyprod;

-- 함수 실행
SELECT prod_id 상품코드,
       prod_name 상품명,
       fn_buyprod_amt(prod_id) 구매내역
FROM prod;




-- 문제. 상품코드를 입력 받아 2005년도 상품별 평균판매횟수, 판매수량합계, 판매금액합계를 출력하는 함수를 작성
-- 1. 함수명 : fn_cart_qavg, fn_cart_qamt, fn_cart_famt
-- 2. 매개변수 : 입력-상품코드,년도 

SELECT *
FROM cart;

CREATE OR REPLACE FUNCTION fn_cart_qavg(
    p_code  cart.cart_prod%TYPE,
    p_year  CHAR)
    RETURN  NUMBER
IS
    v_qavg  NUMBER := 0;
    v_year  CHAR(5) := p_year || '%';
BEGIN 
    SELECT ROUND(AVG(cart_qty)) INTO v_qavg
    FROM cart
    WHERE cart_no LIKE v_year
      AND cart_prod = p_code;
    RETURN v_qavg;
END;

SELECT prod_id, prod_name, fn_cart_qavg(prod_id, '2005')
FROM prod;

-- 문제. 2005년 2~3월(buy_date) 제품별(buy_prod) 구매수량(buy_qty)을 구하여 remain테이블을 UPDATE하기
-- 처리일자는 2005년 3월 마지막일. 함수를 이용하기.
-- 매개변수 : 일자, 제품코드

SELECT LAST_DAY(TO_DATE('200503', 'yyyymm'))
FROM dual;

SELECT *
FROM buyprod;

SELECT *
FROM remain;

-- 함수 생성 : 제품코드 입력 -> 2005년 2~3월 구매수량 반환
CREATE OR REPLACE FUNCTION fn_remain_inqty(
    p_code  buyprod.buy_prod%TYPE)
    RETURN  buyprod.buy_qty%TYPE
IS
    v_qty   buyprod.buy_qty%TYPE := 0;
BEGIN
    SELECT SUM(buy_qty) INTO v_qty
    FROM buyprod
    WHERE p_code = buy_prod AND
          TO_CHAR(buy_date, 'yyyymm') IN ('200502', '200503');
    RETURN v_qty;
END;

-- 익명블록으로 업데이트 : 2005년 2~3월 구매수량이 있는 제품 커서 생성 -> 함수로 구매수량 구하면서 업데이트 (FOR문으로 반복)
DECLARE
BEGIN
    FOR rec_remain_update IN (SELECT buy_prod bp
                              FROM buyprod
                              WHERE TO_CHAR(buy_date, 'yyyymm') IN ('200502', '200503'))
    LOOP
        UPDATE remain SET
            remain_i = remain_i + fn_remain_inqty(rec_remain_update.bp),
            remain_j_99 = remain_j_99 + fn_remain_inqty(rec_remain_update.bp),
            remain_date = TO_DATE('20050331', 'yyyymmdd')
        WHERE rec_remain_update.bp = prod_id;
    END LOOP;
END;
    
SELECT *
FROM remain;

-------------------------------------------------(선생님 답안 -- 자습시간에 쓰기)
-- remain_j_99을 정확히 구하려면 : remain_j_00 + remain_i + fn_remain_inqty - remain_o
CREATE OR REPLACE FUNCTION fn_remain_update( 
        





-------------------------------------------------------------------------------































