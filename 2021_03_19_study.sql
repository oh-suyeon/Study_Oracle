SELECT *
FROM prod;

SELECT *
FROM lprod;

SELECT *
FROM buyer;

SELECT *
FROM buyprod;

SELECT p.prod_id 상품코드, p.prod_name 상품명, l.lprod_nm 분류명
FROM prod p, lprod l
WHERE p.prod_lgu = l.lprod_gu;

SELECT p.prod_id, p.prod_name, b.buyer_name
FROM prod p, buyer b
WHERE p.prod_buyer = b.buyer_id AND b.buyer_name LIKE '%삼성전자%';

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

SELECT *
FROM emp, dept
WHERE emp.deptno != dept.deptno
ORDER BY emp.ename;
