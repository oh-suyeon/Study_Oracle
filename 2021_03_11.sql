-- 데이터 조회 방법
-- FROM : 데이터 조회할 테이블 명시
-- SELECT : 조회하고자 하는 컬럼명(단, 테이블에 있는 컬럼명만 가능)
--          테이블의 모든 컬럼을 조회할 경우 *(아스테리스크)를 기술

SELECT * 
FROM emp;

--EMPNO : 직원번호, ENAME : 직원이름, JOB : 담당업무
--MGR : 상위 담당자, HIREDATE : 입자일자, SAL : 급여
--COMM : 상여금, DEPTNO : 부서번호

SELECT empno, ename  
FROM emp;

SELECT job, sal
FROM emp;

