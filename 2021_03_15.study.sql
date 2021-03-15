

---???--- NOT IN 사용 시 주의점
            --> 내용의 문제가 아니라 표현의 문제? 
            --> mgr != 7698 AND mgr != 7839 AND mgr != NULL
            --> 7698도 아니고 7893도 아니고 NULL도 아닌 값은 NOT IN으로는 못 찾지만 다른 방식으로는 찾을 수 있다. 

SELECT *
FROM emp
WHERE mgr != 7698 AND 
        mgr != 7839 AND 
           mgr IS NOT NULL;  -- 값이 나온다. 
           
SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839, NULL);  -- NOT IN 연산자. 값이 나오지 않는다. 
                                        -- NOT IN이 NULL과는 맞지 않는 연산자이기 때문.
                                        
                                
--- 교재 예제 풀기 ---

-- 1. 
SELECT *
FROM prod;

SELECT prod_id, prod_name
FROM prod;

-- 2. 
SELECT prod_id, prod_name, prod_cost * 55 AS "판매금액"
FROM prod;

-- 3. 
SELECT prod_name, prod_sale
FROM prod
WHERE prod_sale = 170000;

SELECT prod_name, prod_sale
FROM prod
WHERE prod_sale > 170000 OR prod_sale <170000;

SELECT prod_name, prod_sale
FROM prod
WHERE prod_sale >= 170000 OR prod_sale <= 170000;

-- 4.
SELECT prod_id 상품코드, prod_name 상품명, prod_cost 매입가
FROM prod
WHERE prod_cost <= 200000;

-- 5. 
SELECT *
FROM member;

SELECT mem_id "회원ID", mem_name "회원 명", mem_regno1 "주민등록번호 앞자리"
FROM member
WHERE mem_regno1 >= 760101;

-- 6.
SELECT *
FROM prod
WHERE prod_lgu = 'P201' AND prod_sale = 170000;

SELECT *
FROM prod
WHERE prod_lgu = 'P201' OR prod_sale = 170000;

SELECT *
FROM prod
WHERE prod_lgu != 'P201' AND prod_sale != 170000;

SELECT prod_id 상품코드, prod_name 상품명, prod_sale 판매가
FROM prod
WHERE prod_sale BETWEEN 300000 AND 500000;

-- 7.
SELECT *
FROM prod
WHERE prod_sale IN (150000, 170000, 330000);

SELECT mem_id "회원ID", mem_name "회원명"
FROM member
WHERE mem_id IN ('c001', 'f001', 'w001');

-- 8.
SELECT *
FROM prod
WHERE prod_sale BETWEEN 100000 AND 300000;

SELECT mem_id "회원ID", mem_name "회원 명", mem_bir "생일"
FROM member
WHERE mem_bir BETWEEN TO_DATE('19750101', 'YYMMDD') AND TO_DATE('19761231', 'YYMMDD');

SELECT prod_name 상품명, prod_cost 매입가, prod_sale 판매가
FROM prod
WHERE (prod_cost BETWEEN 300000 AND 1500000) AND (prod_sale BETWEEN 800000 AND 2000000);

SELECT mem_id "회원ID", mem_name "회원 명", mem_bir "생일"
FROM member
WHERE mem_bir NOT BETWEEN TO_DATE('19750101', 'YYMMDD') AND TO_DATE('19751231', 'YYMMDD');

-- 9. 
SELECT prod_id 상품코드, prod_name 상품명
FROM prod
WHERE prod_name LIKE '_삼%';

SELECT prod_id 상품코드, prod_name 상품명
FROM prod
WHERE prod_name LIKE '삼%';

SELECT prod_id 상품코드, prod_name 상품명
FROM prod
WHERE prod_name LIKE '%치';

SELECT mem_id "회원ID", mem_name 성명
FROM member
WHERE mem_name LIKE '김%';

SELECT mem_id "회원ID", mem_name 성명, mem_regno1
FROM member
WHERE mem_name NOT LIKE '75%'; 

SELECT *
FROM member;