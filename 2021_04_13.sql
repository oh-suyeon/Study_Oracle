-- 패키지
-- 사용예) 상품테이블에 신규 상품을 등록하는 업무를 패키지로 구성하시오.
--- 1. 분류코드 선택/생성 -> 함수 (분류명은 아는데 분류코드를 모를때는 함수를 쓰겠지만)
--- 2. 상품코드 생성 반환 -> 함수
--- 3. 상품테이블에 등록 -> 프로시저
--- 4. 재고수불테이블에 등록 -> 프로시저

-- 선언부
CREATE OR REPLACE PACKAGE prod_newitem_pkg
IS  
    -- 분류코드가 존재한다면 변수에 넣기
    v_prod_lgu  lprod.lprod_gu%TYPE;
    v_prod_id   prod.prod_id%TYPE;
    
    -- 분류코드 생성
    FUNCTION fn_insert_lprod(   -- 함수 개수가 반드시 같아야 한다.
        p_gu    IN lprod.lprod_gu%TYPE,
        p_nm    IN lprod.lprod_nm%TYPE)
        RETURN lprod.lprod_gu%TYPE;
    
    -- 상품코드 생성 및 상품 등록
    PROCEDURE proc_create_prod_id(
        p_gu        IN lprod.lprod_gu%TYPE,
        p_name      IN prod.prod_name%TYPE,
        p_buyer     IN prod.prod_buyer%TYPE,
        p_cost      IN NUMBER,
        p_price     IN NUMBER,
        p_sale      IN NUMBER,
        p_outline   IN prod.prod_outline%TYPE,
        p_img       IN prod.prod_img%TYPE,
        p_totalstock    IN prod.prod_totalstock%TYPE,
        p_properstock   IN prod.prod_properstock%TYPE,
        p_id        OUT prod.prod_id%TYPE);
    
    -- 재고수불테이블 삽입
    PROCEDURE proc_insert_remain(
        p_id    IN prod.prod_id%TYPE,
        p_amt   NUMBER);    -- 처음 어떤 상품 5개 입고받았다면 '5'는 기초재고, 입고수량, 현재고가 된다.  
        
END prod_newitem_pkg;

    
    
    
    
-- 본문부
CREATE OR REPLACE PACKAGE BODY prod_newitem_pkg
IS
    v_lprod_gu  lprod.lprod_gu%TYPE;    --상품분류코드 변수 생성
    v_prod_id   prod.prod_id%TYPE;      --상품코드 변수 생성

    FUNCTION fn_insert_lprod(            --분류 코드 가져오기 / 상품분류테이블에 분류 코드 생성
        p_gu    IN lprod.lprod_gu%TYPE, -- 분류 코드 입력받고
        p_nm    IN lprod.lprod_nm%TYPE) -- 분류 이름 입력받으면
        RETURN lprod.lprod_gu%TYPE  -- 분류 코드를 돌려준다
    IS
        v_id    NUMBER := 0;
    BEGIN  
        SELECT MAX(lprod_id) + 1 INTO v_id  -- id에는 1을 더해준다. 
        FROM lprod;
        
        INSERT INTO lprod (lprod_id, lprod_gu, lprod_nm)  -- 삽입하고
            VALUES(v_id, p_gu, p_nm);
            
        RETURN p_gu;    -- 분류코드를 돌려준다. 
    END fn_insert_lprod;
    
    -- 상품코드 생성 및 상품 등록  -- 분류 코드 + (가장 큰 상품 번호 + 1)
    PROCEDURE proc_create_prod_id(
        p_gu        IN lprod.lprod_gu%TYPE,
        p_name      IN prod.prod_name%TYPE,
        p_buyer     IN prod.prod_buyer%TYPE,
        p_cost      IN NUMBER,
        p_price     IN NUMBER,
        p_sale      IN NUMBER,
        p_outline   IN prod.prod_outline%TYPE,
        p_img       IN prod.prod_img%TYPE,
        p_totalstock    IN prod.prod_totalstock%TYPE,
        p_properstock   IN prod.prod_properstock%TYPE,
        p_id        OUT prod.prod_id%TYPE)
    IS
        v_pid   prod.prod_id%TYPE;
        v_cnt NUMBER := 0;
    BEGIN
        SELECT COUNT(*) v_cnt
        FROM prod
        WHERE prod_id LIKE p_gu || '%';
        
        IF v_cnt = 0 THEN
            v_pid := p_gu || '000001';
        ELSE
            SELECT 'P' || TO_CHAR(SUBSTR(MAX(prod_id), 2) + 1)
                INTO v_pid
            FROM prod
            WHERE prod_lgu = p_gu;
        END IF;
        p_id := v_pid;
        
        INSERT INTO prod (prod_id, prod_gu, prod_name, prod_cost, prod_price, prod_sale, prod_outline, prod_img, prod_totalstock, prod_properstock) 
                  VALUES (v_pid, p_gu, p_name, p_buyer, p_cost, p_price, p_sale, p_outline, p_img, p_totalstock, p_properstock);    
    END proc_create_prod_id;
    
    -- 재고수불테이블 삽입
    PROCEDURE proc_insert_remain(
        p_id    IN prod.prod_id%TYPE,
        p_amt   NUMBER)
    IS
    BEGIN
        INSERT INTO remain (remain_year, prod_id, remain_j_00, remain_i, remain_j_99, remain_date)
            VALUES('2005', p_id, p_amt, p_amt, p_amt, SYSDATE);    
    END proc_insert_remain;
    
END prod_newitem_pkg;
    

-- 실행
DECLARE 
    v_lgu   lprod.lprod_gu%TYPE;
    v_pid   prod.prod_id%TYPE;
    v_amt   NUMBER := 0;
BEGIN
    v_lgu := prod_newitem_pkg.fn_insert_lprod('P701', '농축산물', v_pid);
    PROD_NEWITEM_PKG.PROC_CREATE_PROD_ID(v_lgu, '소시지', 'P20101', 10000, 13000, 11000, ' ', ' ', 0, 0);
    PROD_NEWITEM_PKG.proc_insert_remain(v_pid, 10);
END;

SELECT *
FROM lprod;





----------------------------------
----------------------------------


-- 상품테이블에서 상품의 분류별 상품의 수를 조회하시오
-- 분류코드, 분류명, 상품의 수

-- 상품테이블에서 사용한 분류 코드의 종류 (중복을 막는 DISTINCT를 사용)
SELECT DISTINCT prod_lgu
FROM prod;

SELECT prod_lgu
FROM prod
GROUP BY prod_lgu;

-- 내부 조인
SELECT l.lprod_gu 분류코드, l.lprod_nm 분류명, COUNT(*) 상품의수 -- 분류코드의 경우, 외부조인인 경우 기준이 되는 컬럼을 써줄것! 모두 나와야 하니까. 
FROM prod p, lprod l                                            -- 내부조인은 null이 없기 때문에 *로 카운트해도 된다. 
WHERE p.prod_lgu = l.lprod_gu
GROUP BY l.lprod_gu, l.lprod_nm
ORDER BY 1;

-- 외부 조인
SELECT l.lprod_gu, l.lprod_nm, COUNT(*)
FROM prod p, lprod l
WHERE p.prod_lgu(+) = l.lprod_gu
GROUP BY l.lprod_gu, l.lprod_nm
ORDER BY 1;





-- 사용예 2
--2005년 5월 매출자료와 거래처테이블(매입)을 이용해 거래처별 상품매출정보를 조회
-- 거래처코드, 거래처명, 매출액(거래처가 납품한 상품이 얼만큼 판매되었는가? cart_qty판매개수 * prod_price가격)

SELECT b.buyer_id 거래처코드, b.buyer_name 거래처명, SUM(c.cart_qty * p.prod_price) 매출액
FROM buyer b, cart c, prod p
WHERE p.prod_id = c.cart_prod AND
      p.prod_buyer = b.buyer_id AND
      SUBSTR(c.cart_no, 1, 6) = '200505' 
GROUP BY b.buyer_id, b.buyer_name
ORDER BY 1;
      
SELECT b.buyer_id 거래처코드, b.buyer_name 거래처명, SUM(c.cart_qty * p.prod_price) 매출액
FROM cart c 
INNER JOIN prod p ON (p.prod_id = c.cart_prod AND
                      SUBSTR(c.cart_no, 1, 6) = '200505')
INNER JOIN buyer b ON (p.prod_buyer = b.buyer_id)
GROUP BY b.buyer_id, b.buyer_name
ORDER BY 1;

SELECT 컬럼 list
FROM 테이블명1
INNER JOIN 테이블명2 ON (조인조건
    [AND 일반조건]) -- 테이블1과 2 조인 결과에 대한 조건 
INNER JOIN 테이블명3 ON (조인조건   -- 테이블1과 2의 조인 결과와 조인된다. 
    [AND 일반조건]) -- 모든 테이블에 관여되기 때문에 WHERE절에 써도 괜찮다.


-----

SELECT *
FROM buyprod;

-- 문제 ) 2005년 1월 ~ 3월 거래처별 매입정보를 조회하시오
-- 거래처코드(buyer.buyer_id / prod.prod_buyer), 거래처명(buyer.buyer_name), 매입금액(prod.prod_cost * buyprod.buy_qty)
-- 매입금액 합계가 500만원 이상인 거래처만 검색하시오
SELECT b.buyer_id 거래처코드, b.buyer_name 거래처명, SUM(bp.buy_cost * bp.buy_qty)매입금액
FROM buyer b, prod p, buyprod bp
WHERE b.buyer_id = p.prod_buyer AND
      bp.prod_


SELECT 
FROM 

-- 문제 ) 사원 테이블(EMPLOYEES)에서 부서별 평균급여보다 급여를 많이 받는 직원 수를 부서별로 조회
-- 





























        