---- 복습

DESC emp;

SELECT *
FROM emp
WHERE deptno = deptno;

SELECT *
FROM emp
WHERE 1 = 1;

SELECT *
FROM emp
WHERE 1 != 1;

SELECT 'SELECT * FROM ' || table_name || ';' 
FROM user_tables;

-- 입사일자가 1982년 1월 1일 이후인 모든 직원 조회하는 SELECT 쿼리를 작성하세요.
SELECT *
FROM emp
WHERE hiredate >= TO_DATE('1982/01/01', 'YYYY/MM/DD');

---- 복습 끝

-- WHERE 절에서 사용 가능한 연산자
SELECT *
FROM emp
WHERE deptno BETWEEN 10 AND 20;

-- emp 테이블에서 급여가 1000보다 크거나 같고 2000보다 작거나 같은 직원 조회
    -- sal >= 1000, sal <= 2000 동시에 만족
    
SELECT *
FROM emp
WHERE sal BETWEEN 1000 and 2000;

SELECT *
FROM emp
WHERE sal >= 1000 AND sal <= 2000;

SELECT *
FROM emp
WHERE sal >=1000
    AND sal <= 2000
    AND deptno = 10;

-- 실습 where1
SELECT ename, hiredate
FROM emp
WHERE hiredate BETWEEN TO_DATE('1982/01/01', 'YYYY/MM/DD') AND TO_DATE('1983/01/01', 'YYYY/MM/DD');


-- IN
SELECT * 
FROM emp
WHERE deptno IN(10, 20);

SELECT * 
FROM emp
WHERE deptno = 10 OR deptno = 20;

SELECT * 
FROM emp
WHERE 10 IN(10, 20);  -- TRUE

-- 실습 where2
DESC users;

SELECT userid 아이디, usernm 이름, alias 별명  
FROM users
WHERE userid IN ('brown', 'cony', 'sally');

-- LIKE
-- 첫 글자가 c인 것, 그리고 그 뒤에 0개 이상의 문자가 오는 것 조회
SELECT *
FROM users
WHERE userid LIKE 'c%';

-- 첫 글자가 c인 것, 그리고 그 뒤에 3개 이상의 문자가 오는 것 조회
SELECT *
FROM users
WHERE userid LIKE 'c___';

-- userid에 l이 들어가는 모든 사용자 조회
SELECT *
FROM users
WHERE userid LIKE '%l%';

-- 실습 where4
-- member 테이블에서 성이 신씨인 사람의 아이디, 이름을 조회
SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '신%';

-- 실습 where4
-- member 테이블에서 이름에 이가 들어가는 사람의 아이디, 이름을 조회
SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '%이%';

-- IS (NULL 비교)
SELECT *
FROM emp
WHERE comm IS NULL;

SELECT *
FROM emp
WHERE comm IS NOT NULL;

-- emp 테이블에서 매니저 없는 직원 조회
SELECT *
FROM emp
WHERE mgr IS NULL;

-- 실습 
SELECT *
FROM emp
WHERE mgr IS NOT NULL;

-- 논리 연산자. 조건의 순서는 결과와 무관하다.
-- emp 테이블에서 매니저 사번이 7698이면서 급여가 1000보다 큰 직원
SELECT *
FROM emp
WHERE mgr = 7698 AND sal > 1000;

SELECT *
FROM emp
WHERE mgr = 7698 OR sal > 1000;

SELECT *
FROM emp
WHERE deptno NOT IN (30);

SELECT *
FROM emp
WHERE deptno != 30;

SELECT *
FROM emp
WHERE ename NOT LIKE 'S%';

-- NOT IN 연산자 사용시 주의점 : 비교값 중 NULL이 포함되면, 데이터가 조회되지 않는다. 
SELECT *
FROM emp
WHERE mgr IN (7698, 7839, NULL);

SELECT *
FROM emp
WHERE mgr = 7698 OR mgr = 7839 OR mgr IS NULL;

SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839, NULL); -- 7698, 7839, NULL 모두 아니어야 함.
-- !(WHERE mgr = 7698 OR mgr = 7839 OR mgr IS NULL;)
 -- -> mgr != 7698 AND mgr != 7839 AND mgr != NULL
 -- -> 하지만 이건 의미가 없음. NULL 이 있는 이상 값이 나오지 않으니까, TRUE, FALSE 의미가 없다. 무조건 FALSE일테니까. 


-- 실습 where7
-- emp 테이블에서 영업사원이고 1981년 6월 1일 이후 입사자를 조회
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' 
    AND hiredate >= TO_DATE('19810601', 'YYYYMMDD');

-- 실습 where8
-- -- emp 테이블에서 부서번호가 10번이 아니고, 1981년 6월 1일 이후 입사자를 조회
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE deptno != 10 
    AND hiredate >= TO_DATE('19810601', 'YYYYMMDD');

-- 실습 where9 (8과 동일, NOT IN 사용)
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno    
FROM emp
WHERE deptno NOT IN (10)
    AND hiredate >= TO_DATE('19810601', 'YYYYMMDD');

-- 실습 where10 (8과 동일, IN 사용)
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE deptno IN (20, 30)
    AND hiredate >= TO_DATE('19810601', 'YYYYMMDD');
    
-- 실습 where11 (7과 동일, OR 사용)
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' 
    OR hiredate >= TO_DATE('19810601', 'YYYYMMDD');
    
-- 실습 where12 
-- emp 테이블에서 영업사원이거나, 사원번호가 78로 시작하는 직원 조회
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' 
    OR empno LIKE '78%'; -- 숫자에 문자열 비교를 썼는데 실행됨. 숫자를 자동으로 문자열로 형변환한 것임.
    
-- 과제) 실습 where13 (12와 동일. LIKE 연산자 쓰지 말기)
-- 1000번대만 검색되면 안 된다. 틀렸음!
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' 
    OR empno BETWEEN 7800 AND 7899;
-- 1000번대만 검색되면 안 된다. 100번대, 10번대도 검색되도록 한다.
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' 
    OR empno BETWEEN 7800 AND 7899
    OR empno BETWEEN 780 AND 789
    OR empno = 78; 