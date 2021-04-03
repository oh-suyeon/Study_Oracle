-- DML 연습 (DDL 중 CREATE도 포함해서!)

DROP TABLE emp_test4; 

CREATE TABLE emp_test4 AS (SELECT * FROM emp);

INSERT INTO emp_test4 VALUES (7777, 
                              'SUYEON', 
                              'CLERK', 
                              7893, 
                              TO_DATE('2021/04/03', 'yyyy/mm/dd'), 
                              800, 
                              NULL, 
                              10);

UPDATE emp_test4 SET deptno = 40
                 WHERE empno = 7777;

DESC emp_test4;

SELECT *
FROM emp_test4;

COMMIT;

INSERT INTO emp_test4 VALUES (0000, 'GHOST', 'SALESMAN', 7777, TO_DATE('2021/04/03', 'yyyy/mm/dd'), 0, NULL, 40);

UPDATE emp_test4 SET ename = 'MIKEY'
                 WHERE empno = 0000;
                 
UPDATE emp_test4 SET empno = 4444
                 WHERE empno = 0;
                 
DELETE emp_test4
WHERE empno = 4444;

COMMIT;

-- 달력 만들기 -- 
-- 입력받는 것 : 년도, 월 :yyyymm

SELECT TO_DATE(:yyyymm, 'yyyymm')
FROM dual;

-- 입력받은 '달' 정보의 1일부터 마지막 날까지 출력하기
-- 마지막 날은 언제지?

SELECT TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd')
FROM dual;

-- 마지막 날을 구했다. 특정 '달'의 일수 dd를 구한 셈.
-- 특정 '달'은 1부터 dd까지 출력되어야 한다. 
-- LEVEL을 이용해서..

SELECT TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1)
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd');

-- 요일 정보를 넣어주자
-- 인라인 뷰로 재료 테이블 base를 준비해주고
-- 셀렉트 절에서 재료를 요일 정보 기반으로 골라와서 컬럼으로 재배치한다. 
-- 조건 분기. CASE? DECODE? 7개 숫자를 기준으로 동등비교를 해야 하니까 DECODE로 하면 간단하겠다.

SELECT TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1) dt, TO_CHAR((TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1)), 'd') wd
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd');

SELECT DECODE(base.wd, 1, base.dt) sun,
       DECODE(base.wd, 2, base.dt) mon,
       DECODE(base.wd, 3, base.dt) tue,
       DECODE(base.wd, 4, base.dt) wen,
       DECODE(base.wd, 5, base.dt) thu,
       DECODE(base.wd, 6, base.dt) fri,
       DECODE(base.wd, 7, base.dt) sat
FROM 
    (SELECT TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1) dt, 
            TO_CHAR((TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1)), 'd') wd
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd')) base;

-- NULL 값이 나오는 행을 없애줘야 한다. 
-- 그러면 일주일 단위로 묶어 그룹을 만들어준 다음에, 각 요일 별로 그룹 함수 MIN/MAX를 써서 값이 있는 날만 가져와야 한다. 


SELECT TO_CHAR(base.dt, 'w'),

       MIN(DECODE(base.wd, 1, base.dt)) sun,
       MIN(DECODE(base.wd, 2, base.dt)) mon,
       MIN(DECODE(base.wd, 3, base.dt)) tue,
       MIN(DECODE(base.wd, 4, base.dt)) wen,
       MIN(DECODE(base.wd, 5, base.dt)) thu,
       MIN(DECODE(base.wd, 6, base.dt)) fri,
       MIN(DECODE(base.wd, 7, base.dt)) sat
FROM 
    (SELECT TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1) dt, 
            TO_CHAR((TO_DATE(:yyyymm, 'yyyymm') + (LEVEL - 1)), 'd') wd
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'dd')) base
GROUP BY TO_CHAR(base.dt, 'w')
ORDER BY TO_CHAR(base.dt, 'w');




