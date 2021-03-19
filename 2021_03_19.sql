
-- grp2
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY deptno;

-- grp3
SELECT DECODE(deptno, 10, 'ACCOUNTING', 20,'RESEARCH', 30, 'SALES') DNAME, 
        MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY deptno;

-- grp4
SELECT TO_CHAR(hiredate, 'yyyymm') hire_yyyymm, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'yyyymm')
ORDER BY TO_CHAR(hiredate, 'yyyymm');

-- grp5
SELECT TO_CHAR(hiredate, 'yyyy') hire_yyyy, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'yyyy')
ORDER BY TO_CHAR(hiredate, 'yyyy');

-- grp6
SELECT COUNT(*)
FROM dept;

-- grp7 직원이 속한 부서의 개수. 직원이 속하지 않은 부서가 존재한다. 
-- 만약 속한 직원이 없으면 카운트해선 안되는데...어떻게 하지??? --> 직원이 없다면 아예 행이 존재하지도 않았음. 
SELECT ename, deptno
FROM emp;

SELECT deptno
FROM emp
GROUP BY deptno;

SELECT COUNT(*) CNT
FROM (SELECT deptno
        FROM emp
        GROUP BY deptno);

-- JOIN
-- 표준
SELECT *
FROM emp NATURAL JOIN dept; -- LOC는 필요 없을때?

SELECT ename, dname
FROM emp NATURAL JOIN dept;

-- 한정자에 대해 emp.ename
SELECT emp.empno, emp.ename, emp.deptno -- 내추럴 조인에서는 연결고리 컬럼에 한정자를 쓰지 못한다. 
FROM emp NATURAL JOIN dept;

--오라클버전 - 오라클에서는 조인을 다 이렇게 한다!
SELECT *
FROM emp, dept  -- 컬럼이 모호하게 정의되었다는 경고
WHERE deptno = deptno;

SELECT *
FROM emp, dept
WHERE emp.deptn = dept.deptno; -- 한정자를 붙여서 확실히 정의해준다. 이 조건을 만족하면 조인을 해라. 부서번호가 두 번 등장한다. 

-- 같은 테이블을 조인하기(어떤 직원의 매니저는 이름이 뭐지?) - 테이블 별칭 필요
-- null인 킹은 조회되지 않는다. 조인에 실패. where 조건을 만족하지 못해서 연결되지 않음.
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

-- JOIN WITH USING
SELECT *
FROM emp JOIN dept USING(deptno);

-- JOIN WITH ON 
SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);  
-- 사원 번호, 사원 이름, 해당사원의 상사 사번, 해당 사원의 상사 이름
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno);
-- 단, 사원 번호가 7369~7698인 사원들만
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;
-- 오라클로 바꾸면
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno AND e.empno BETWEEN 7369 AND 7698;

-- 논리적인 조인 형태
-- SELF JOIN
-- NONEQUI-JOIN
SELECT *
FROM emp, dept
WHERE emp.deptno != dept.deptno
ORDER BY emp.ename; -- 자기 부서가 아닌 부서와 연결. 스미스에게 3개의 부서가 연결됐다. 총 42건이 나올 것. 14 * 3
--salgrade를 이용해 직원의 급여 등급 구하기 empno, ename, sal, 급여등금
SELECT *
FROM salgrade;
-- 오라클
SELECT e.empno, e.ename, e.sal, s.grade 급여등급 
FROM emp e, salgrade s
WHERE e.sal BETWEEN s.losal AND s.hisal;
-- ANSI 
SELECT e.empno, e.ename, e.sal, s.grade 급여등급
FROM emp e JOIN salgrade s ON (e.sal BETWEEN s.losal AND s.hisal);

--join0
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY e.deptno;

--join0_1
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno AND e.deptno IN(10, 30);

--join0_2
SELECT e.empno, e.ename, e.sal, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno AND e.sal > 2500
ORDER BY e.deptno;

--join0_3
SELECT e.empno, e.ename, e.sal, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno AND e.sal > 2500 AND e.empno > 7600
ORDER BY e.deptno;

--join0_4
SELECT e.empno, e.ename, e.sal, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno AND e.sal > 2500 AND e.empno > 7600 AND d.dname = 'RESEARCH'
ORDER BY e.deptno;
