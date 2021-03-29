 -- 컬럼 순서에 따른 인덱스의 변화 (column_position)
 SELECT ename, job, ROWID
 FROM emp
 ORDER BY ename, job;
 
 -- 삭제
 -- DROP 객체타입 객체명;
 DROP INDEX idx_emp_03;
 
-- 생성
CREATE INDEX idx_emp_04 ON emp (ename, job);

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
 AND ename LIKE 'C%';
 
SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    38 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    38 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_04 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ENAME" LIKE 'C%' AND "JOB"='MANAGER')
       filter("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       
-- 두 개 테이블에 인덱스 만들기
-- 테이블을 동시에 읽을 순 없다. 순차적으로 읽는다.
-- 어떤 접근 방법, 순서을 선택할까? 총 16가지의 방법중에서.. (접근방법 * 테이블^개수)
-- 응답성 : OLTP (Online Transaction Processing) - 일반적, 우리가 오라클을 쓰는 이유. 응답성을 중요시해서 항상 정답을 맞추진 못 한다. 
-- 퍼포먼스 : OLAP (ONLINE Analysis Processing) - 눈에 보이지 않는 시스템. 은행 이자 계산. 빠르게 응답하는 게 아니라 (실시간이 아니니까) 수많은 데이터를 만들어야 함. 30분이 걸려도 괜찮. 
emp (4)
1. table full access
2. idx 01
3. idx 02
4. idx 04

dept (2)
1. table full access
2. idx 01


SELECT ROWID, dept.*
FROM dept;

CREATE INDEX idx_dept_01 ON dept (deptno);

EXPLAIN PLAN FOR
SELECT ename, dname, loc
FROM emp, dept
WHERE emp.deptno = dept.deptno -- 부서번호를 알아내면 emp.deptno가 상수조건이 된다. 20 = dept.deptno
  AND emp.empno = 7788; -- empno 상수 조건이 있으니까 emp의 첫번째 인덱스를 사용. 그런데 논유니크 인덱스라서 한건이 아니라 두건을 읽을 거다. 부서번호를 알아내면...
  
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

4, 3, 5, 2, 6, 1, 0
---------------------------------------------------------------------------------------------
| Id  | Operation                     | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |             |     1 |    32 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |             |       |       |            |          |
|   2 |   NESTED LOOPS                |             |     1 |    32 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| EMP         |     1 |    13 |     2   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_EMP_01  |     1 |       |     1   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN           | IDX_DEPT_01 |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT        |     1 |    19 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
   
-- 
-- 달력 만들기 쿼리 
-- 주어진 것 : 년월 6자리 문자열 ex - 202102
-- 만들 것 : 해당 년월에 해당하는 달력 (7칸 짜리 테이블)

20210301 - 날짜, 문자열
20210302
202103마지막 날짜까지

--레벨은 1부터 시작
SELECT *
FROM dual --> 1개의 행이
CONNECT BY LEVEL <= 10; --> 10번 반복된다. 

SELECT dummy, LEVEL
FROM dual 
CONNECT BY LEVEL <= 10; 
--> 우린 마지막 날까지 만들어야 한다. 

SELECT TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD')
FROM dual;

SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL -1) dt
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'); 


SELECT dt, d
FROM        --> 쿼리를 단순화 시키는 인라인뷰
(SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1) dt,
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'D') d /*
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'IW') iw */
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD')); 


SELECT dt, d, /*일요일이면 dt 아니면 null, 월요일이면 dt 아니면 null*/
              DECODE(d, 1, dt) sun, DECODE(d, 2, dt) mon,
              /*화요일이면 dt 아니면 null, 수요일이면 dt 아니면 null*/
              DECODE(d, 3, dt) tue, DECODE(d, 4, dt) wen,
              /*목요일이면 dt 아니면 null, 금요일이면 dt 아니면 null*/
              DECODE(d, 5, dt) thu, DECODE(d, 6, dt) fri,
              /*토요일이면 dt 아니면 null*/
              DECODE(d, 7, dt) sat
FROM        
(SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1) dt,
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'D') d /*
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'IW') iw */
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'));

------ 여기서부터! GROUP BY 기준을 IW가 아니라 LEVEL로 내가 직접 지정해줘야 할 것 같다. 계층으로..? 

SELECT iw, 
              MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,  --> 오라클은 min을 권장한다. null처리 함수는 가능할까?
              MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wen,
              MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
              MIN(DECODE(d, 7, dt)) sat
FROM        
(SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1) dt,
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'D') d, 
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'IW') iw 
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'))
GROUP BY iw --> 주차는 맨 첫주와 마지막 주만 빼면 7개 요일로 이루어진다. 7개의 행 중에 날짜가 오는 것은 한 개 뿐. 주차 별로 그룹바이를 해야 한다. 
ORDER BY iw;  --> 일요일이 한칸씩 위로 올라온 문제점이 생긴다. iw의 포맷 문제. 주의 시작을 일요일이 아닌 월요일로 봐서 생긴 문제. --> 일요일일 때는 주차를 1 더해주기. 



SELECT DECODE(d, 1, iw + 1, iw),           -- 그룹바이 기준은 셀렉트절에 없어도 된다. 
              MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,  
              MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wen,
              MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
              MIN(DECODE(d, 7, dt)) sat
FROM        
(SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1) dt,
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'D') d, 
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'IW') iw 
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, iw + 1, iw)     --> 또 다른 문제점이 남았다. 201912할 떄. iw는 목요일을 기준으로 한다. 12월 마지막 주의 목요일이 1주차이기 때문에 월, 화가 1주로 밀려난 것. 
ORDER BY DECODE(d, 1, iw + 1, iw); 


-------

-- 계층쿼리 (조직도, 생산, 물류, 부품조립(bill of meterial), 답변형 게시판) 오라클이 파워풀한 성능을 보이는 분야
-- 데이터의 상하관계를 나타내는 쿼리. 데이터는 모두 나오는데, 계층 순서대로 정렬이 되어 출력. ORDER BY로 구현할 수 없는 순서. 
-- LEVEL은 계층쿼리에서만 쓸 수 있는 특수 키워드 
-- 들여쓰기를 해서 시각적으로 표현할 수 있다. 
사용방법 
1. 시작위치 설정
2. 행과 행의 연결 조건 기술 PRIOR, CONNECT BY
3. 

SELECT empno, ename, mgr 
FROM emp
START WITH empno = 7839
CONNECT BY PRIOR empno = mgr; 
내가 읽은 행의 사번 = 앞으로 읽을 행의 매니저 사번
(위의)empno = (아래의)mgr -- king의 사번 = mgr 컬럼 값
-- 위는 이미 읽은 데이터prior, 아래는 앞으로 읽을 데이터

SELECT empno, ename, mgr, LEVEL
FROM emp
START WITH empno = 7566 -- 시작 위치를바꿀 수 있다. 
CONNECT BY PRIOR empno = mgr; 

-- 들여쓰기로 시각적 효과를 LPAD()
SELECT LPAD('TEST', 1*20) pad
FROM dual;

SELECT empno, LPAD(' ', (LEVEL - 1) * 4) || ename en, mgr, LEVEL  -- 이런 예제들이 많이 나올 것. 
FROM emp
START WITH empno = 7839
CONNECT BY PRIOR empno = mgr;

--대다수의 책에서 오해할 수 있는 구절.  CONNECT BY  + PRIOR가 하나라고 생각하면 안된다. PRIOR의 세트는 이미 읽은 컬럼의 이름! 
ex. CONNECT BY mgr = PRIOR empno AND deptno = PROIR deptno; -- prior 키워드가 어디에 붙을 지 명확하게 이해하기!

계층쿼리의 종류 (데이터 조회 건수가 달라진다.) (상황에 따라 사용하는데, 보통 하향식을 사용)
1. 상향식 : 특정 자식(leaf nod)에게 연결된 부모만 나온다. 직접적인 관계가 없는 행들은 나오지 않는다. 
2. 하향식 : 최상위 노드(root nod)에서 모든 자식 노드 방문. 모든 행이 다 나온다. 위에서부터 내려가면 모든 행이 연결되니까. 
-- PSUEDO CODE - 가상코드. 일상어로 풀어 설명하는 거.ㅅ 

-- 스미스부터 상향식 계층쿼리
SELECT empno, LPAD(' ', (LEVEL - 1) * 4)|| ename pd, mgr, LEVEL
FROM emp
START WITH empno = 7369
CONNECT BY PRIOR mgr = empno;

-- h1. 최상위 노드~ 최하위 노드까지 탐색, 시각적 표현
SELECT *
FROM dept_h;

SELECT LEVEL, LPAD(' ', (LEVEL - 1) * 4)|| deptnm deptnm, deptcd, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

-- h2. 정보시스템부 하위 부서계층 구조 

SELECT LEVEL lv, deptcd, LPAD(' ', (LEVEL -1) * 4) || deptnm deptnm, p_deptcd
FROM dept_h
START WITH deptnm = '정보시스템부'
CONNECT BY PRIOR deptcd = p_deptcd;

-- h3. 디자인팀에서 시작 상향식 계층 쿼리

SELECT LEVEL lv, deptcd, LPAD(' ', (LEVEL -1) * 4) || deptnm deptnm, p_deptcd
FROM dept_h
START WITH deptnm = '디자인팀'
CONNECT BY PRIOR p_deptcd = deptcd;

-- h4. 
노드 아이디, 부모노드 아이디, 노드 저장 값
SELECT *
FROM h_sum;

SELECT LPAD(' ', (LEVEL - 1) *4)|| s_id s_id, value
FROM h_sum
START WITH s_id = '0'
CONNECT BY PRIOR s_id = ps_id;


DESC h_sum; -- id가 문자열이네  --  
만약 데이터베이스 컬럼을 숫자로 바꿨다면... 값을 변형한 거니까 인덱스를 쓰지 못한다. 좌측을 가공하면 안 된다. 칠거지악.
---



SELECT DECODE(d, 1, iw + 1, iw),           
              MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,  
              MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wen,
              MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
              MIN(DECODE(d, 7, dt)) sat
FROM        
(SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1) dt,
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'D') d, 
       TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL - 1), 'IW') iw 
FROM dual 
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, iw + 1, iw)     
ORDER BY DECODE(d, 1, iw + 1, iw);


