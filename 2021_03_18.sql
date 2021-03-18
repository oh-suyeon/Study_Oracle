SELECT ename, TO_CHAR(hiredate, 'YYYY/MM/DD HH24:mi:ss') hiredate,
        MONTHS_BETWEEN(SYSDATE, hiredate) month_between,
        ADD_MONTHS(SYSDATE, 5) add_months,
        ADD_MONTHS((TO_DATE('2021-02-15' , 'YYYY-MM-DD'), 5)) add_months2,
        NEXT_DAY(SYSDATE, 1) next_day, --18일 이후에 등장하는 일요일은?. 많이 활용된다.
        LAST_DAY(SYSDATE) last_day,
        TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM') || '01', 'YYYYMMDD') first_day
FROM emp;


-- 시간의 기본 값 00:00:00, 월 일의 기본 값 서버의 월-01

SELECT TO_DATE('2021' || '0101', 'YYYYMMDD') -- 월,일 값까지 강제 결합. 정해주지 않으면 기본값.
FROM dual;

-- 실습 fn3
-- 마지막 일자 구하기 = 월에 있는 일 수 구하기
SELECT :yyyymm, TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd') DT 
FROM dual;

-- 묵시적 형변환
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = '7369'; -- 변환되는 건 좌변일까 우변일까? 근데 좌변이 바뀌면 안된다고 했잖아. 
-- 이걸 어떻게 풀지 sql이 스스로 찾아낸다. 스스로 우변을 형변환한다.
-- 명시적으로 형변환해보자
SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

SELECT ename, sal, TO_CHAR(sal, 'L0009,999.00') 
FROM emp;
-- 헷갈리면 9를 많이 넣기. 근데 많이 안 쓴다. 자바에서 이런 기능해주는 모듈이 있다. 보통 데이터 갖고 올 때는 원본 가지고 오고 화면 보여줄 때만 전환을 한다. 사실 DATE도 비슷한데 이건 형변환을 잘 알아야 한다. where절 조건 쓸 때 필요하니까. 

-- NULL 처리 함수
-- 1. 가장 많이 사용 NVL(expr1, expr2) -- 표기는 표현값이지만 컬럼도 포함한 어쨌든 값
if(expr1 == null) -- expr1이 NULL 값이 아니면 1을 사용하고, NULL 값이면 2로 대체
    System.out.println(expr2)
else
    System.out.println(expr1)
    
SELECT empno, comm, NVL(comm, 0) 
FROM emp;

SELECT empno, sal, comm, sal+comm -- 문제가 생긴다. 직원들이 총 얼마를 버는지 알고 싶은데.
FROM emp;

SELECT empno, sal, comm, sal + NVL(comm, 0) 
FROM emp;

SELECT empno, sal, comm, sal + NVL(comm, 0),
        NVL(sal + comm, 0) 잘못된예 -- 합계 자체가 무시될 수 있기 때문.
FROM emp;

--2. NVL2(ex1, ex2, ex3) 많이 쓰진 않은 것 같은데
if(ex1 != null)
    sysout(ex2)
else
    sysout(ex3) -- 원래 값을 돌려주는 게 아니라 또 다른 새 값을 준다.
    
-- comm이 null이 아니면 sal+comm 
-- comm이 null 이면 sal
SELECT empno, sal, comm, NVL2(comm, sal+comm, sal) -- 다른 방법 동이한 값
FROM emp;

--3. NULLIF(ex1, ex2) 정말 안 쓴다. null을 만들면 문제가 생겨서.
if(ex1 == ex2)
    sysout(null)
else
    sysout(ex1)
    
SELECT empno, sal, NULLIF(sal, 1250) -- 1250 급여받으면 null이 된다.
FROM emp;

COALESCE(ex1...) -- 가변인자. 인자 개수가 정해지지 않았다. 무한대. 인자들중에 가장 먼저 나오는 null이 아닌 인자를 반환.
if(ex1 != null)
    sysout(ex1);
else
    COALESCE(ex2, ex3....);- 
    
if(ex2 != null)
    sysout(ex2);
else
    COALESCE(ex3....); -- 재기 함수. 자기가 자기를 호출한다. 
    
SELECT empno, sal, comm, COALESCE()
FROM emp;

-- fn4.
SELECT empno, ename, mgr, 
        NVL(mgr, 9999) mgr_n,
        NVL2(mgr, mgr, 9999) mgr_n_1, 
        COALESCE(mgr, 9999) mgr_n_2 -- COALESCE(mgr, null, 9999)
FROM emp;

-- fn5.
SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
FROM users
WHERE userid IN('cony', 'sally', 'james', 'moon');

-- 조건분기

-- 1. CASE 절 
-- 직원 급여 인상. 영업사원이면 현급여에서 5% 인상. 매니저는 10%, 사장은 20%인상, 그 밖의 직군은 유지.

SELECT ename, job, sal, 
        CASE 
            WHEN job = 'SALESMAN' THEN sal * 1.05 -- sal + sal * 0.05 
            WHEN job = 'MANAGER' THEN sal * 1.10
            WHEN job = 'PRESIDENT' THEN sal * 1.20
            ELSE sal * 1.0
        END sal_bonus
FROM emp;

-- 2. DECODE

SELECT ename, job, sal, 
        DECODE(job, 
            'SALESMAN', sal * 1.05,
            'MANAGER', sal * 1.10,
            'PRESIDENT', sal * 1.20,
            sal * 1.0) sal_bonus  -- 디폴트 쓰지 않으면 null이 된다!
FROM emp;

-- cond1
SELECT empno, ename, deptno,
        DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 40, 'OPERATIONS', 'DDIT') DNAME
FROM emp;

-- cond2. 건강검진대상자인가요?
SELECT empno, ename, hiredate, 
        DECODE(MOD(TO_NUMBER(TO_CHAR(hiredate, 'YYYY'), 9999), 2), 
                 MOD(TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'), 9999), 2), '검강검진 대상자', 
                 '검강검진 비대상자') CONTACT_TO_DOCTOR
FROM emp;

-- cond3. 건강검진대상자인가요?
SELECT userid, usernm, reg_dt, 
        DECODE(MOD(TO_NUMBER(TO_CHAR(reg_dt, 'YYYY'), 9999), 2), 
                 MOD(TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'), 9999), 2), '검강검진 대상자', 
                 '검강검진 비대상자') CONTACT_TO_DOCTOR
FROM users
WHERE userid IN('brown', 'cony', 'james', 'moon', 'sally');


---- 그룹함수

SELECT *
FROM emp;


SELECT deptno, MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY deptno; -- 부서 기준으로 묶겠다.

SELECT deptno, MAX(sal)
FROM emp
GROUP BY deptno
ORDER BY deptno;

-- 전체 직원은 몇 명인가? 많이 쓰는 패턴. GROUP BY를 안 하면 전체 행을 하나의 행으로 그룹핑. 
SELECT COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal)
FROM emp;

-- 에러
SELECT empno, MAX(sal)  -- 논리적으로 맞지 않다. 그룹으로 묶어서 하나의 값씩 나와야 하는데. 나오는 값이 둘 이상이니까. GROUP BY 절에 나온 컬럼이 SELECT 절에 그룹함수가 적용되지 않은 채로 기술되면 에러
FROM emp
GROUP BY deptno;

SELECT empno, MAX(sal)
FROM emp
GROUP BY deptno, empno; -- 이렇게 하면 에러가 사라지지만 empno로도 그룹핑을 하기 때문에 결국 14개 전체의 행이 나온다. 

SELECT MIN(empno), MAX(sal) -- 혹은 번호 중 가장 작은 것, 값 하나만 나오도록 한다. 
FROM emp
GROUP BY deptno, empno;

SELECT deptno, COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal) -- GROUP BY를 안 하면 전체 행을 하나의 행으로 그룹핑한 상태. 
FROM emp;                                             -- 이것도 동일한 에러. 전체 테이블이 하나의 행이 된 상태이기 때문. 

SELECT deptno, 'TEST', 100, COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal)  --고정된 상수는 동일한 하나의 값이기 때문에 에러 없이 출력된다.
FROM emp;


--null 값
SELECT COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(comm) -- null값이 있어도 자동으로 처리해준다. null처리 해주지 않아도 된다.
FROM emp;

SELECT COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2),
        SUM(NVL(comm, 0)), -- 둘 다 결과는 같지만 효율 면에서는 아래가 낫다. 한번만 실행하면되니까.
        NVL(sum(comm), 0)
FROM emp
WHERE COUNT(*) >=4  -- 오류가 난다. 그룹함수에 대한 조건은 where가 아니라 having에 써야 한다. 
GROUP BY deptno;

FROM emp
GROUP BY deptno;
HAVING COUNT(*) >= 4;


-- grp1
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp;

-- grp2
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY deptno;