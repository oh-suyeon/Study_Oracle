 -- FUCNTION
 
 -- 장바구니 테이블에서 특정 일에 판매된 상품의 이름을 출력하기 
 -- 함수(특정일) =return> 상품명

 SELECT p.prod_name
 FROM cart c, prod p
 WHERE c.cart_prod = p.prod_id AND
       c.cart_no LIKE '20050605%';
 
 CREATE OR REPLACE FUNCTION fn_prod_name(
    p_date  IN VARCHAR2,
    p_code  IN VARCHAR2)
    RETURN  VARCHAR2
 IS
    v_name  prod.prod_name%TYPE;
 BEGIN
    SELECT p.prod_name INTO v_name
    FROM cart c, prod p
    WHERE c.cart_prod = p.prod_id AND
          p_code = c.cart_prod AND
          c.cart_no LIKE 'p_date%';
    RETURN v_name;
 END;
 
 ---------------------------
 
 CREATE OR REPLACE FUNCTION fn_prod_name2(
    p_code  IN VARCHAR2)
    RETURN VARCHAR2
 IS
    v_name  prod.prod_name%TYPE;
 BEGIN 
    SELECT prod_name INTO v_name
    FROM prod
    WHERE p_code = prod_id;
    RETURN v_name;
 END;
 
 SELECT fn_prod_name2(cart_prod)
 FROM cart
 WHERE cart_no LIKE '20050605%';
 
 ------------------------------
 -- 2005년 5월 '모든' 상품별 매입 현황

 SELECT p.prod_id, SUM(bp.buy_qty), SUM(bp.buy_qty * bp.buy_cost)
 FROM buyprod bp RIGHT OUTER JOIN prod p 
        ON (p.prod_id = bp.buy_prod AND 
            bp.buy_date BETWEEN TO_DATE('20050501', 'yyyymmdd') AND 
                                LAST_DAY(TO_DATE('200505', 'yyyymm')))
 GROUP BY p.prod_id;
 --
 CREATE OR REPLACE FUNCTION fn_buyprod_info01(
    p_code  IN prod.prod_id%TYPE)
    RETURN  NUMBER
 IS
    v_qty   NUMBER := 0;
 BEGIN
    SELECT SUM(bp.buy_qty) INTO v_qty
     FROM buyprod bp RIGHT OUTER JOIN prod p 
          ON (p.prod_id = bp.buy_prod AND 
              bp.buy_date BETWEEN TO_DATE('20050501', 'yyyymmdd') AND 
                                  LAST_DAY(TO_DATE('200505', 'yyyymm')))
    WHERE p_code = p.prod_id;
    RETURN NVL(v_qty, 0);
 END;
 --
 CREATE OR REPLACE FUNCTION fn_buyprod_info02(
    p_code  IN prod.prod_id%TYPE)
    RETURN  NUMBER
 IS
    v_amt   NUMBER := 0;
 BEGIN
    SELECT SUM(bp.buy_qty * bp.buy_cost) INTO v_amt
     FROM buyprod bp RIGHT OUTER JOIN prod p 
          ON (p.prod_id = bp.buy_prod AND 
              bp.buy_date BETWEEN TO_DATE('20050501', 'yyyymmdd') AND 
                                  LAST_DAY(TO_DATE('200505', 'yyyymm')))
     WHERE p_code = p.prod_id;
    RETURN NVL(v_amt, 0);
 END;
 --
 SELECT prod_name, fn_buyprod_info01(prod_id) 수량, fn_buyprod_info02(prod_id) 금액
 FROM prod;
 
 
 