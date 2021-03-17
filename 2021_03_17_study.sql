DESC member;

SELECT mem_id "변환 전ID", UPPER(mem_id) "변환 후ID"
FROM member;

SELECT prod_price, LPAD(prod_price, 10, '*')
FROM prod;

DESC prod;

SELECT INSTR(prod_name, '칼라', 4) 상품명
FROM prod;

SELECT prod_name, prod_id
FROM prod
WHERE INSTR(prod_name, '칼라', 4) > 0;

SELECT *
FROM prod;

SELECT prod_id 상품코드, SUBSTR(prod_id, 4, 1) 대분류, SUBSTR(prod_id, -6, 1) 순번 
FROM prod;

SELECT REPLACE(mem_name, '이', '리') 회원명치환, mem_name 회원명
FROM member;

SELECT * 
FROM member;

SELECT mem_mileage / 12, ROUND(mem_mileage / 12, 2) 반올림, TRUNC(mem_mileage / 12, 2) 절삭 
FROM member;

