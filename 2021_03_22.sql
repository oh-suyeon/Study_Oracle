SELECT *
FROM lprod;

SELECT *
FROM prod;

SELECT *
FROM buyer;

--erd&join1
SELECT l.lprod_gu, l.lprod_nm, p.prod_id, p.prod_name   -- 데이터 명이 nm, name 다르다. 통일하는 게 좋다. 
FROM lprod l, prod p
WHERE p.prod_lgu = l.lprod_gu;

--erd&join2
SELECT b.buyer_id, b.buyer_name, p.prod_id, p.prod_name
FROM buyer b, prod p
WHERE p.prod_buyer = b.buyer_id;

--erd&join3
SELECT m.mem_id, m.mem_name, p.prod_id , p.prod_name, c.cart_qty
FROM member m, cart c, prod p
WHERE m.mem_id = c.cart_member AND c.cart_prod = p.prod_id;

SELECT member.mem_id, member.mem_name, prod.prod_id, prod.prod_name, cart.cart_qty
FROM member JOIN cart ON (member.mem_id = cart.cart_member)
            JOIN prod ON (cart.cart_prod =- prod.prod_id);

--erd&join4
SELECT *
FROM customer;

SELECT *
FROM product;

SELECT *
FROM cycle; -- 1번 고객이 100번 제품을 몇 요일에 몇 개씩 먹는다. 

SELECT cy.cid, cu.cnm, cy.pid, cy.day, cy.cnt
FROM cycle cy,customer cu
WHERE cy.cid = cu.cid;

--erd&join4
SELECT cy.cid, cu.cnm, cy.pid, cy.day, cy.cnt
FROM cycle cy, customer cu
WHERE cy.cid = cu.cid AND cu.cnm IN ('brown', 'sally');

--erd&join5
SELECT cy.cid, cu.cnm, cy.pid, p.pnm, cy.day, cy.cnt
FROM cycle cy,customer cu, product p
WHERE cy.cid = cu.cid AND cy.pid = p.pid AND cu.cnm IN ('brown', 'sally');

--erd&join6
SELECT cy.cid, cu.cnm, cy.pid, p.pnm, SUM(cy.cnt) cnt
FROM customer cu, cycle cy, product p
WHERE cy.cid = cu.cid AND cy.pid = p.pid
GROUP BY cy.cid, cu.cnm, cy.pid, p.pnm;

--erd&join7
SELECT p.pid, p.pnm, SUM(cy.cnt) cnt
FROM product p, cycle cy
WHERE cy.pid = p.pid
GROUP BY p.pid, p.pnm;


---데이터 결합 
--(지금까지 inner join)
--outer join (상사 연결시키기에서 결과가 나오지 않았던 king)
--연결조건에 실패한 값도 두 개 중 한 개 테이블에 나온다.

SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+);  -- 오라클에서는 방향이 아니라 누락되는 쪽에(+)를 붙여준다.

SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m.empno);  --null이 나오는 부서번호

SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m.empno AND m.deptno = 10); -- join의 조건 안에 부서번호 조건을 넣었을 때. 

SELECT e.ename, m.ename, m.deptno
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
    AND m.deptno(+) = 10;               -- 오라클에서는 join조건도 행위 조건도 where절에 들어간다. 실패해도 나오도록 하는 방법.

SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m.empno)        -- 행 조회 행위를 제한하는 조건으로 넣었을 때. 행의 수 자체가 줄어든다. 
WHERE m.deptno = 10;

SELECT e.ename, m.ename, m.deptno
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
    AND m.deptno = 10;
    
--full outer join
SELECT e.ename, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);      -- RIGHT와 중복되지 않는  king null 값.

SELECT e.ename, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);     -- LEFT에 있는 값들은 제거. 없는 값만 살리기. 

-- outerjoin1
SELECT *
FROM buyprod;

SELECT *
FROM prod;

SELECT *
FROM buyprod
WHERE buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD');

모든 제품 다 보여주고, 실제 구매가 잇을 때는구매수량을 조회, 없을 경우 null

SELECT *
FROM buyprod
WHERE buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD');

SELECT COUNT(*)
FROM prod;

SELECT b.buy_date, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b RIGHT OUTER JOIN prod p ON(p.prod_id = b.buy_prod AND buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));

SELECT b.buy_date, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b, prod p
WHERE p.prod_id = b.buy_prod(+) AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');