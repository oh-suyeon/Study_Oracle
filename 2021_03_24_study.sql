SELECT ename, deptno, mgr
FROM emp
WHERE ename IN ('ALLEN', 'CLARK');


SELECT mgr, deptno
FROM emp
WHERE ename IN ('ALLEN', 'CLARK');

SELECT empno, ename, (SELECT SYSDATE FROM dual)
FROM emp;

EXPLAIN plan FOR
SELECT ename, job, deptno, (SELECT dname FROM dept WHERE deptno = emp.deptno) dname
FROM emp;

SELECT*
FROM TABLE(dbms_xplan.display);

DESC emp;

DESC prod;
DESC lprod;

SELECT *
FROM prod;

SELECT *
FROM lprod;

--1.
SELECT p.prod_id 상품코드, p.prod_name 상품명,
(SELECT l.lprod_NM FROM lprod l WHERE l.lprod_gu = p.prod_lgu) 분류명
FROM prod p;

--2.

SELECT prod_name, prod_cost, 
FROM prod;

SELECT a.prod_name 상품명, TO_CHAR(a.prod_sale, '999,999,999') 판매가, 
        TO_CHAR((SELECT AVG(prod_sale) FROM prod), '999,999,999') 평균판매가
FROM prod a
WHERE prod_sale > (SELECT AVG(prod_sale) FROM prod);

SELECT a.prod_name 상품명,
       TO_CHAR(a.prod_sale, '999,999,999L') 판매가,
       TO_CHAR(b.avg_sale, '999,999,999L') 평균판매가
FROM prod a, 
    (SELECT AVG(prod_sale) avg_sale FROM prod) b
WHERE a.prod_sale > b.avg_sale;

--3.
SELECT mem_mileage
FROM member;

SELECT m.mem_name 회원명, 
       TO_CHAR(m.mem_mileage, '999,999,999.00L') 마일리지,
       TO_CHAR(a.avg_mileage, '999,999,999.00L') 평균마일리지
FROM member m,
     (SELECT ROUND(AVG(NVL(mem_mileage, 0)), 2) avg_mileage FROM member) a
WHERE m.mem_mileage > a.avg_mileage;

--4.
SELECT *
FROM buyer;
SELECT *
FROM buyprod;
SELECT prod_insdate
FROM prod;
SELECT *
FROM prod;

SELECT p.prod_buyer 거래처코드, b.buyer_name 거래처명, 
       b.in_amt 매입금액합계
FROM prod p, 
    (SELECT buyer_name, buyer_id, SUM(buy_qty * buy_cost) in_amt 
     FROM buyer, buyprod, prod
     WHERE buy_date BETWEEN '2005-01-01' AND '2005-12-31'
            AND buy_prod = prod_id
            AND buyer_id = prod_buyer
     GROUP BY buyer_name, buyer_id
     ORDER BY buyer_id) b
WHERE b.buyer_id = b.buyer_id(+)
ORDER by b.buyer_name;

--
SELECT *
FROM member;
SELECT *
FROM buyer;
--buyer_add1
--mem_add2

SELECT mem_name 회원명, mem_add1 지역
FROM member
WHERE SUBSTR(mem_add1, 1, 2) IN (SELECT SUBSTR(buyer_add1, 1, 2)
                                FROM buyer);

--
SELECT mem_mileage
FROM member
WHERE mem_job = '공무원';

SELECT mem_name, mem_job, mem_mileage
FROM member
WHERE mem_job != '공무원' AND
      mem_mileage > (SELECT MIN(mem_mileage)
                     FROM member
                     WHERE mem_job = '공무원');
                               
SELECT mem_name 회원명, mem_job 직원, mem_mileage 마일리지
FROM member
WHERE mem_job != '공무원' AND
      mem_mileage > (SELECT MIN(mem_mileage)
                     FROM member
                     WHERE mem_job = '공무원');
                     
SELECT mem_name 회원명, mem_job 직원, mem_mileage 마일리지
FROM member
WHERE mem_job != '공무원'
      AND mem_mileage > ALL (SELECT mem_mileage
                               FROM member
                               WHERE mem_job = '공무원');
                               
--
SELECT *
FROM buyer; -- buyer_id, buyer_name

SELECT *
FROM prod; -- prod_buyer, prod_id

SELECT *
FROM buyprod; -- buy_date, buy_prod, buy_qty, buy_cost 

SELECT buyer_id, buyer_name
FROM buyer;

SELECT cart_member, SUM(cart_qty)
FROM cart
GROUP BY cart_member;

SELECT *
FROM cart;

DESC cart;

SELECT b.buyer_id 거래처코드, b.buyer_name 거래처명, NVL(SUM(bp.buy_cost * bp.buy_qty), 0) 매입금액합계
FROM buyer b, prod p, buyprod bp
WHERE b.buyer_id = p.prod_buyer AND
      p.prod_id = bp.buy_prod AND
      bp.buy_date BETWEEN '2005-01-01' AND LAST_DAY('2005-12-01')
GROUP BY b.buyer_id, b.buyer_name
ORDER BY b.buyer_id;

SELECT a.buyer_id 거래처코드, a.buyer_name 거래처명, NVL(b.in_amt, 0) 매입금액합계
FROM (SELECT DISTINCT BUYER_ID, BUYER_NAME
      FROM buyer) a,
     (SELECT buyer_id, buyer_name, SUM(buy_cost * buy_qty) in_amt
      FROM buyprod, buyer, prod
      WHERE buy_date BETWEEN '2005-01-01' AND '2005-12-31'
      AND buy_prod = prod_buyer
      AND buyer_id = prod_buyer
      GROUP BY buyer_id, buyer_name
      ORDER BY buyer_id) b
WHERE a.buyer_id = b.buyer_id(+)
      a.buyer_name;


SELECT deptno
FROM emp
GROUP BY deptno
HAVING COUNT(*) >= 4;