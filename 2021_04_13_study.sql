-- 문제1 ) 2005년 1월 ~ 3월 거래처별 매입정보를 조회하시오
-- 거래처코드(buyer.buyer_id / prod.prod_buyer), 거래처명(buyer.buyer_name), 매입금액(prod.prod_cost * buyprod.buy_qty)
-- 매입금액 합계가 500만원 이상인 거래처만 검색하시오

SELECT b.buyer_id 거래처코드, b.buyer_name 거래처명, SUM(bp.buy_cost * bp.buy_qty) 매입금액
FROM buyer b, prod p, buyprod bp
WHERE b.buyer_id = p.prod_buyer AND
      bp.buy_prod = p.prod_id AND
      bp.buy_date BETWEEN TO_DATE('20050101') AND LAST_DAY(TO_DATE('20050301'))
GROUP BY b.buyer_id, b.buyer_name
HAVING SUM(bp.buy_cost * bp.buy_qty) >= 5000000
ORDER BY 1;
      

      
-- 문제2 ) 사원 테이블(EMPLOYEES)에서 부서(department_id) 별 평균 급여(salary)보다 급여를 많이 받는 직원employee_id 수를 부서별로 조회
-- 부서코드(e.department_id), 부서명(departments.department_name), 평균급여(AVG(salary)), 인원(COUNT(*))

SELECT e.department_id 부서코드, d.department_name 부서명, ROUND(AVG(e.salary)) 평균급여
FROM employees e, departments d
WHERE e.department_id = d.department_id 
GROUP BY e.department_id, d.department_name
ORDER BY 1;

SELECT a.부서코드, a.부서명, a.평균급여, COUNT(*) cnt           
FROM employees ep, 
     (SELECT e.department_id 부서코드, d.department_name 부서명, ROUND(AVG(e.salary)) 평균급여
      FROM employees e, departments d
      WHERE e.department_id = d.department_id 
      GROUP BY e.department_id, d.department_name) a
WHERE ep.department_id = a.부서코드 AND
      ep.salary >= a.평균급여
GROUP BY a.부서코드, a.부서명, a.평균급여
ORDER BY 1;

SELECT department_id, COUNT(*)
FROM employees
GROUP BY department_id;

-- 풀이

SELECT department_id, ROUND(AVG(salary)) asal
FROM employees
GROUP BY department_id;

SELECT b.department_id, c.department_name, a.asal, COUNT(*) cnt
FROM employees b, (SELECT department_id, ROUND(AVG(salary)) asal
                   FROM employees
                   GROUP BY department_id) a, departments c
WHERE a.department_id = b.department_id AND
      b.department_id = c.department_id AND
      b.salary >= a.asal
GROUP BY b.department_id, c.department_name, a.asal
ORDER BY 1;









--------------------------------------
SELECT *
FROM remain;

SELECT *
FROM lprod;

SELECT *
FROM prod;

-- 패키지

CREATE OR REPLACE PACKAGE prod_newitem2_pkg
IS
    v_lp_id     lprod.lprod_id%TYPE; -- proc_insert_lprod2에서 사용할 변수
    v_lp_gu     lprod.lprod_gu%TYPE; -- fn_create_prod_id2에서 사용할 변수
    
    -- LPROD에 데이터 입력 : IN (lprod_gu, lprod_nm) --> lprod_id(v_lp_id) --> INSERT (v_lp_id, lprod_gu, lprod_nm) --> v_lp_gu으로 값 내보내기
    PROCEDURE proc_insert_lprod2(
        p_lp_gu  IN lprod.lprod_gu%TYPE,
        p_lp_nm  IN lprod.lprod_nm%TYPE);
    
    -- PROD에 입력할 prod_id 생성 : IN lprod_gu --> (lprod_gu || MAX + 1) OR (lprod_gu || 001) --> OUT prod_id
    FUNCTION fn_create_prod_id2(
END;     
            
            
            
            
            
            
            
            
SELECT *
FROM products
            
            
            
--

CREATE OR REPLACE PACKAGE ex_pkg IS -- 선언부

    FUNCTION func_1(p_product_id IN NUMBER)
    RETURN VARCHAR2;
    
    PROCEDURE proc_1;
    
    PROCEDURE proc_2(p_product_id IN NUMBER);

END ex_pkg;


CREATE OR REPLACE PACKAGE BODY ex_pkg IS    -- 실행부
    
    FUNCTION func_1(p_product_id IN NUMBER) -- 아이디 입력하면 이름을 반환하는 함수
    RETURN VARCHAR2
    IS
        v_product_name  VARCHAR2(100);
    BEGIN 
        SELECT prod_name
        FROM products
        WHERE prod_id = p_product_id;
        
    RETURN NVL(prod_name, '존재하지 않는 제품');
    END func_1;
    
    
    PROCEDURE proc_1      -- 제품아이디와 제품명을 모두 출력하는 프로시저
    IS  
    BEGIN
        FOR rec_i IN (SELECT prod_id, prod_name
                      FROM products)
        LOOP
            DBMS_OUTPUT.PUT_LINE(' 제품ID : ' || rec_i.prod_id);
            DBMS_OUTPUT.PUT_LINE(' 제품명 : ' || rec_i.prod_name);
        END LOOP;
        
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM || '에러 발생 ');
            
    END proc_1;
    
    
    PROCEDURE proc_2(p_product_id IN NUMBER)    -- 제품아이디를 입력받으면 아이디 이름 출력하는 프로시저
    IS
    BEGIN
        FOR rec_i IN (SELECT prod_id, prod_name
                      FROM products
                      WHERE prod_id = p_product_id)
        LOOP
            DBMS_OUTPUT.PUT_LINE(' 제품ID : ' || rec_i.prod_id);
            DBMS_OUTPUT.PUT_LINE(' 제품명 : ' || rec_i.prod_name);
        END LOOP;
        
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM || '에러 발생 ');
            
    END proc_2;
    
END ex_pkg;
            
            
EXEC ex_pkg.func_1(148);

EXEC ex_pkg.proc_1;

EXEC ex_pkg.proc_2(148);
















    
    
    
    
    
    
    
    
    











