--sub6 
SELECT a.cid, a.pid, a.day, a.cnt
FROM cycle a
WHERE a.cid = 1
    AND a.pid IN (SELECT pid        -- IN을 써야 하는데 = 비교연산자를 쓰려고 해서 출력행 수에 대한 에러가 생겼다
             FROM cycle
             WHERE cid = 2);

--sub7
SELECT *
FROM customer; -- cid, cnm
SELECT *
FROM cycle; -- cid, pid, day, cnt
SELECT *
FROM product; -- pid, pnm

-- 익숙하게 떠올릴 때까지 엑셀에 그려볼것.
SELECT a.cid, c.cnm, a.pid, p.pnm, a.day, a.cnt
FROM cycle a, customer c, product p
WHERE a.cid = 1
    AND a.pid IN (SELECT pid        
             FROM cycle
             WHERE cid = 2)
    AND a.cid = c.cid
    AND a.pid = p.pid;

--

--EXISTS
-- 매니저가 존재하는 직원
SELECT *
FROM emp
WHERE mgr IS NOT NULL;

SELECT *
FROM emp e
WHERE EXISTS (SELECT empno
              FROM emp m
              WHERE m.empno = e.mgr);
              
SELECT *
FROM emp e
WHERE EXISTS (SELECT *
              FROM dual); -- 이 조건은 항상 참 - > 14건 모두 조회
              
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'  -- EXISTS 서브 쿼리의 셀렉트절에는 관습적으로 x를 쓴다. 
              FROM dual); 
        
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'
              FROM emp m
              WHERE m.empno = e.mgr);
              
SELECT *
FROM emp e
WHERE e.mgr IN (SELECT m.empno
                FROM emp m);              
              
--비상호연관서브쿼리와 사용할 수는 있지만 많이 쓰지 않는다. ALL OR NOTHING     

SELECT COUNT(*) cnt
FROM emp
WHERE deptno = 10; -- 데이터가 존재하는지 보려고 이렇게 하긴 함. 그런데 데이터 수가 늘어나면 비효율적이다. EXISTS를 사용하ㅡㄴ 게 좋다. 

SELECT *
FROM dual
WHERE EXISTS (SELECT 'x' FROM emp WHERE deptno = 10); -- 존재여부를 따질 때는. 

--sub9
--cycle product테이블로 cid 1인 고객 애음제품 조회. exists 연산자 이용

SELECT product.pid, product.pnm
FROM product
WHERE EXISTS (SELECT 'X'
              FROM cycle
              WHERE cycle.cid = 1
              AND cycle.pid = product.pid);

SELECT product.pid, product.pnm
FROM product
WHERE NOT EXISTS (SELECT 'X'
              FROM cycle
              WHERE cycle.cid = 1
              AND cycle.pid = product.pid);

-- UNION


 -- 
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7499) 

UNION

SELECT empno, ename, deptno -- 컬럼의 수가 달라서 에러 (수가 다른 쿼리를 합치려면 가짜 컬럼 NULL을 만들어준다. )
FROM emp
WHERE empno IN (7369, 7521);

SELECT empno, ename, deptno
FROM emp
WHERE empno IN (7369, 7499) 

UNION

SELECT empno, ename, NULL 
FROM emp
WHERE empno IN (7369, 7521);

-- UNION ALL
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7499) 

UNION ALL

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7521);

--INTERSECT
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7499) 

INTERSECT

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7521);

--MINUS
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7499) 

MINUS

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7521);


-- 특징
SELECT empno e, ename en
FROM emp
WHERE empno IN (7369, 7499) 

UNION

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7521);
-
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7499) 

UNION

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7521)
ORDER BY empno;

-- INSERT

INSERT INTO 테이블명 [((컬럼명,))] VALUES ((value, )) 

-- SELECT * 쿼리로 확인하지 말것. 컬럼 순서를 바꿀 수 있으니까. 
DESC dept;
INSERT INTO dept VALUES (99, 'ddit', 'daejeon'); -- 이미 입력했던 데이터. 한번더 입력하면? 입력은 된다. (DBMS는 중복을 방지하긴 하는데, 우리가 그 기능을 안 킴)
INSERT INTO dept (deptno, dname, loc) VALUES (99, 'ddit', 'daejeon');

SELECT *
FROM dept;

INSERT INTO emp (ename, job) VALUES ('brown', 'RANGER'); -- empno컬럼은 NOT NULL인데, 행을 넣어주지 않는다면 에러가 난다. ORA-01400: cannot insert NULL into ("DJS02061"."EMP"."EMPNO")

INSERT INTO emp (empno, ename, job) VALUES (9999, 'brown', 'RANGER');

SELECT *
FROM emp;

INSERT INTO emp (empno, ename, job, hiredate, sal, comm) 
         VALUES (9998, 'sally', 'RANGER', TO_DATE('2021-03-24', 'YYYY-MM-DD'), 1000, NULL);
         
-- 여러건 한번에입력
INSERT INTO 테이블명
SELECT 쿼리

INSERT INTO dept
SELECT 90, 'DDIT', '대전' FROM dual
UNION ALL
SELECT 80, 'DDIT8', '대전' FROM dual;     -- 셀렉트쿼리로 짤 수 있는 데이터면 이렇게 한 번에 넣는게 훨씬 빠르다. 한 건씩 INSERT 하기보다는.
-- 테이블을 가공해서 다른 테이블에 넣는 작업이 흔하다

ROLLBACK;
UPDATE 테이블명 SET 컬럼명1 = 값1, 컬럼명2 = 값2, ...
WHERE     ;          -- 이런 조건을 만족하는 데이터의 컬럼 값을 바꾸겠다.

SELECT *
FROM dept;

부서번호 99번 부서정보를 부서명=대덕IT로, 장소 = 영민빌딩 --여기서 그냥 해버리면 테이블 모든 행들이 바뀐다. WHERE 절 누락을 주의!
UPDATE dept SET dname = '대덕IT', loc = '영민빌딩'    
WHERE deptno = 99;
