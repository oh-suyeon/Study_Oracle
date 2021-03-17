-- * 연산자 우선순위

SELECT *
FROM emp
WHERE ename = 'SMITH' OR ename = 'ALLEN' AND job = 'SALESMAN';
    --> (직원의 이름이 ALLEN "이면서" job이 SALESMAN) "이거나" 이름이 SMITH인 직원 조회
    
SELECT *
FROM emp
WHERE (ename = 'SMITH' OR ename = 'ALLEN') AND job = 'SALESMAN';
    --> (직원의 이름이 ALLEN "이거나" SMITH) "이면서" job이 SALESMAN 인 직원 조회
    
-- where14
-- emp 테이블에서 다음과 같은 직원 정보 조회
-- 1. job이 SALESMAN이거나
-- 2. 사원번호가 78로 시작하면서, 입사일자가 1981년 6월 1일 이후
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
FROM emp
WHERE job = 'SALESMAN' OR 
        ((empno BETWEEN 7800 AND 7899 OR
        empno BETWEEN 780 AND 789 OR empno = 78)
        AND hiredate >= TO_DATE('19810601', 'YYYYMMDD'));

--* 데이터 정렬

SELECT *
FROM emp
ORDER BY ename; -- 이름 컬럼 기준 '오름차순'으로 행이 정렬된다. 

SELECT *
FROM emp
ORDER BY ename DESC; -- 이름 컬럼 기준 '내림차순'으로 행이 정렬된다. 

SELECT *
FROM emp
ORDER BY job DESC, sal; 

SELECT *
FROM emp
ORDER BY job DESC, sal, comm; -- 1차로 job 내림차순 정렬한 상태에서, 2차로 sal 오름차순 정렬하고 3차로 comm 오름차순 정렬 -> 

SELECT *
FROM emp
ORDER BY 2; -- 두번째 열(컬럼) 'ename' 을 기준으로 오름차순 정렬

SELECT empno, job, mgr
FROM emp
ORDER BY 2; -- 두번째 열(컬럼) 'job'을 기준으로 오름차순 정렬

SELECT empno a, job b, mgr c
FROM emp
ORDER BY a;  -- 별칭 정렬

--orderby 1
-- dept 테이블의 모든 정보를 부서이름으로 오름차순 정렬 조회
-- dept 테이블의 모든 정보를 부서위치로 내림차순 정렬 조회
DESC dept;

SELECT * 
FROM dept
ORDER BY dname;

SELECT * 
FROM dept
ORDER BY loc DESC;

--orderby 2
-- emp 테이블에서 상여 정보가 있는 사람 중에 
-- 상여 많이 받는 사람이 먼저 조회되도록 정렬, 상여 같을 경우 사번으로 내림차순
SELECT *
FROM emp
WHERE comm > 0
ORDER BY comm DESC, empno DESC;

--orderby 3
-- emp 테이블에서 매니저 사번이 NULL이 아닌 직원을 직함 오름차순으로 정렬하고 중복될 경우 사번 큰 순으로 정렬
SELECT *
FROM emp
WHERE mgr IS NOT NULL
ORDER BY job, empno DESC;

--orderby 4
-- emp 테이블에서 10번, 20번 부서 사람 중 급여 1500 이상 직원 조회해 이름 내림차순으로 정렬
SELECT *
FROM emp
WHERE (deptno = 10 OR deptno = 30) AND sal > 1500
ORDER BY ename DESC;

SELECT *
FROM emp
WHERE deptno IN (10, 30) AND sal > 1500 -- 더 보기 좋다.
ORDER BY ename DESC;


-- 페이징 처리

-- ROWNUM 행번호를 첫번째 컬럼으로 가져올 수 없을까?
SELECT ROWNUM, empno, ename
FROM emp;

SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM BETWEEN 1 AND 5;  -- WHERE에서 ROWNUM 쓰기. 1부터 사용하는 경우에만 가능 ROWNUM의 특징.

SELECT ROWNUM, empno, ename
FROM emp
ORDER BY ename;  -- 꼬여버린 rownum. 번호가 부여된 후 정렬되었기 때문. sql의 시행순서에 대해

--인라인 뷰 - 실행순서 역전시키기

SELECT ROWNUM, empno, ename -- 2. 행번호를 부여한다. 
FROM (SELECT empno, ename -- 1. 정렬된 상태의 테이블을 만들어 놓고,
      FROM emp
      ORDER BY ename)
WHERE ROWNUM BETWEEN 1 AND 5; --인라인 뷰(뷰라는 것은 셀렉트 쿼리) 객체가 됐다. 특정 칼럼을 하나의 테이블로 만든 것.
                                -- 그런데 또 1번이 아니면 조회가 안 된다. 
                                
-- 또한번 인라인 뷰를 하고 별칭을 붙여서, ROWNUM의 특징인 1부터 조회 가능한 조건을 피하기.

SELECT *
FROM
(SELECT ROWNUM rm, empno, ename -- 바깥에서 봤을 때는 rownum이 아니라 rm이라는 컬럼으로 보이도록. 그러면 1번도 조회 가능하니까.
 FROM (SELECT empno, ename      -- 그냥 ROWNUM을 썼을 때는 바깥의 rownum이라는 기능으로 읽힌다. 여기서 필요한 것은 행번호 값이 있는 "칼럼"
      FROM emp
      ORDER BY ename))
WHERE rn BETWEEN 6 AND 10; -- 셀렉트 쿼리 안에 있는 ROWNUM을 지칭하는 게 아니라면 별칭이 필요하다.

-- pageSize : 5건 (변동 가능)
-- (page) page : rn BETWEEN page*pageSize-(pageSize-1) AND page*pageSize;
--                        (n-1)*pageSize + 1 

-- 변수 적용하기 ':'
-- (page) page : rn BETWEEN :page*:pageSize-(:pageSize-1) AND :page*:pageSize;
--                          = (:page-1)*:pageSize + 1 
-- 변수 값 입력하는 바인드에서 공백 넣지 말기 (바인딩 변수)

SELECT *
FROM
(SELECT ROWNUM rm, empno, ename 
 FROM (SELECT empno, ename      
      FROM emp
      ORDER BY ename))
WHERE rm BETWEEN (:page-1)*:pageSize + 1 AND :page*:pageSize;

--mysql의 페이징 쿼리는 또 다르다.

--row1

SELECT ROWNUM rn, empno, ename
FROM emp
WHERE ROWNUM BETWEEN 1 AND 10;

SELECT ROWNUM rn, empno, ename
FROM emp
WHERE rn BETWEEN 1 AND 10; -- ORA-00904: "RN": invalid identifier // WHERE 절에 별칭은 쓸 수 없다? 바로는 못씀.

-- row2
SELECT *
FROM(SELECT ROWNUM rn, empno, ename
    FROM emp)
WHERE rn BETWEEN 11 AND 14;

-- row3
SELECT *
FROM (SELECT ROWNUM rn, empno, ename 
      FROM(SELECT empno, ename
           FROM emp)
      ORDER BY ename)
WHERE rn BETWEEN 11 AND 14;

-- 질문 답변1. ROWNUM과 * 같이 쓰기. 한정자로 *가 어디서 오는지 알려줘야 한다.
SELECT ROWNUM, emp.*
FROM emp;

-- 테이블에도 별칭을 줄 수 있다.
SELECT ROWNUM rn, e.*
FROM emp e; -- AS를 못 쓰는 것만 다르다.

--> 인라인 뷰에도 별칭을 줄 수 있다. 
SELECT *
FROM (SELECT ROWNUM rn, empno, ename 
      FROM(SELECT empno, ename
           FROM emp)
      ORDER BY ename) a
WHERE rn BETWEEN 11 AND 14;