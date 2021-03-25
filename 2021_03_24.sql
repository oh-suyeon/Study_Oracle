-- SMITH가 속한 부서에 있는 직원들을 조회하기
SELECT ename, deptno 
FROM emp
WHERE ename = 'SMITH';

SELECT *
FROM emp
WHERE deptno = 20;          -- SMITH의 부서번호가 바뀌어도 동일한 쿼리로 검색하려면?

-- SUBQUERY 서브 쿼리 : 쿼리의 결과를 가져다 쓰는 방법

SELECT *
FROM emp
WHERE deptno = (SELECT deptno 
                FROM emp
                WHERE ename = 'SMITH'); -- 서브쿼리 / 단일행단일컬럼 / 비상호연관

-- 잘못된 예 문법 주의
SELECT *
FROM emp
WHERE deptno = (SELECT deptno 
                FROM emp
                WHERE ename = 'SMITH' OR ename = 'ALLEN'); --연산자에 따라서 오류. IN을 사용하면 가능 

-- subquery1
-- 평균 급여보다 급여가 높은 직원의 수
-- 평균 값은 언제든 바뀔 수 있으니까, 하드 코딩은 적절하지 않다. 
SELECT COUNT(*)
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp);
             
-- subquery2
-- 평균 급여보다 높은 급여 받는 직원 정보
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp);

-- subquery3
-- SMITH나 WARD의 부서에 속하는 직원 조회
SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
        FROM emp
        WHERE ename IN ('SMITH', 'WARD'));

-- 참고하기MULTI ROW
-- ANY : 직원 중 급여값이 스미스(800)나 워드(1250)의 급여보다 작은 직원 --> 워드보다 작은 직원을 구한다.
SELECT *
FROM emp m
WHERE m.sal < ANY(
                SELECT s.sal
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD')
                );
-- 우리가 아는 개념으로 치환 가능하다. 그래서 그리 중요하지 않은 것. 
SELECT *
FROM emp m
WHERE m.sal < (SELECT MAX(s.sal)
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD'));
                
-- ALL
-- 직원 급여가 800보다 작고 1250보다 작아야 한다.  --> 800보다 작아야 한다. 
SELECT *
FROM emp m
WHERE m.sal < ALL( SELECT s.sal
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD'));

-- 우리가 아는 개념으로 치환 가능하다. 그래서 그리 중요하지 않은 것.                 
SELECT *
FROM emp m
WHERE m.sal < (SELECT MIN(s.sal)
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD'));

-- 사용시 주의 점
SELECT *
FROM emp
WHERE deptno IN (10, 20, NULL);

SELECT *
FROM emp
WHERE deptno NOT IN (10, 20, NULL);
--> !(deptno = 10 OR deptno = 20 OR deptno = NULL)

-- 누군가의 상사가 아닌 사람
SELECT *
FROM emp
WHERE empno NOT IN (SELECT mgr
                    FROM emp);  

SELECT *                    
FROM emp
WHERE empno NOT IN (SELECT NVL(mgr, 9999) -- NULL 처리를 해야 한다. ** 시험 문제 **
                    FROM emp);
                    
-- PAIR WISE
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
                FROM emp
                WHERE empno IN(7499, 7782))
        AND deptno IN (SELECT deptno
                    FROM emp
                    WHERE empno IN(7499, 7782));
-- 앨런(30, 7698), 클락(10, 7839)                    
SELECT ename, mgr, deptno
FROM emp
WHERE empno IN(7499, 7782);

SELECT *
FROM emp
WHERE mgr IN (7698, 7839)
        AND deptno IN (10, 30);
-- mgr, deptno
-- (7698, 10), (7698, 30) , (7839, 10), (7839, 30) -- 경우의 수 - 아래의 요구사항에서 불필요한 값들이 나온다. 

-- 요구사항 : 앨런 또는 클락의 소속 부서번호와 같으면서 상사도 같은 직원들을 조회
SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE ename IN ('ALLEN', 'CLARK')); -- 데이터 한 건이 줄었다. 블레이크. 
                        
-- 스칼라 서브쿼리
-- 이런 문법
SELECT empno, ename, (SELECT SYSDATE FROM dual)
FROM emp;

SELECT empno, ename, (SELECT SYSDATE, SYSDATE FROM dual) -- 컬럼이 한 개를 초과해서 에러
FROM emp;                        
-- emp 테이블에는 해당직원이 속한 부서번호는 관리하지만 해당 부서명 정보는 dept테이블에만 있다. 해당 직원의 부서 이름을 알고 싶으면 dept테이블과 조인해야
-- 컬럼을 확장하는 건 join, 행을 확장하는건아직 안배운 집합연산
-- join 을 안 쓰고 스칼라 서브쿼리를 써도 된다
SELECT *
FROM dept;

SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE dept.deptno = emp.deptno) -- 행의 개수만큼 실행된다. 행이 길면 성능이 많이 저하된다.메인이 1번, 메인을 호출하는 서브는 14번이고. 총 15번
FROM emp;

-- 인라인 뷰
SELECT *
FROM
(SELECT deptno, ROUND(AVG(sal), 2)
FROM emp
GROUP BY deptno);

--subquery4
-- 아래 쿼리를 바탕으로, 직원이 속한 부서의 급여 평균보다 높은 급여를 받는 직원을 조회
-- 좋은 예제
-- 평균 급여보다 높은 급여 받는 직원 정보
SELECT *
FROM emp
WHERE sal >= (SELECT AVG(sal)
             FROM emp);
             
SELECT deptno, AVG(sal)
FROM emp
GROUP BY deptno; -- 20번 부서만 보고 싶은데 한번에 나온다.

SELECT AVG(sal)
FROM emp
WHERE deptno = 20;

SELECT empno, ename, sal, deptno
FROM emp e
WHERE e.sal >= (SELECT AVG(sal)
                FROM emp a
               WHERE a.deptno = e.deptno); 

-- 급여평균 컬럼도 만들고 싶으면?               
SELECT empno, ename, sal, deptno, a.avg_sal
FROM emp e
WHERE e.sal >= (SELECT AVG(sal) avg_sal
                FROM emp a
               WHERE a.deptno = e.deptno); -- 에러! 메인은 서브플롯의 컬럼을 가져올 수 없다. 논리적으로 생각 (FROM 절에 없으니까.)

SELECT empno, ename, sal, deptno, (SELECT AVG(sal) 
                                    FROM emp a
                                    WHERE a.deptno = e.deptno)
FROM emp e
WHERE e.sal >= (SELECT AVG(sal) 
                FROM emp a
               WHERE a.deptno = e.deptno); -- 되긴하는데 비효율적. 그래서 JOIN을 쓴다. 

               
-- subquery4
INSERT INTO dept VALUES (99, 'ddit', 'daejeon');
COMMIT;

SELECT dept.deptno, dept.dname, dept.loc
FROM dept
WHERE dept.deptno NOT IN (SELECT deptno
                        FROM emp
                        GROUP BY emp.deptno);  
-- 정답
SELECT dept.deptno, dept.dname, dept.loc
FROM dept
WHERE dept.deptno NOT IN (SELECT deptno
                        FROM emp);
                          
                          
-- subquery4
고객이 먹지 않는 음료
SELECT * 
FROM product
WHERE pid NOT IN (SELECT pid
                    FROM cycle
                    WHERE cycle.cid = 1);

1번 고객이 먹는 음료
SELECT pnm
FROM cycle;

SELECT *
FROM product;