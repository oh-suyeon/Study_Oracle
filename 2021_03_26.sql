-- UPDATE 테이블명 SET 컬럼명1 = (스칼라 서브쿼리) -> 한 컬럼에 넣을 하나의 행이까. 고정된 값 뿐 아니라 쿼리로 가져올 수 있다. 

--9999사번 brown 직원을 입력

INSERT INTO emp (empno, ename) VALUES (9999, 'brown'); -- 테이블
INSERT INTO emp (ename, empno) VALUES ('brown', 9999); -- 같다. 

DESC emp;

SELECT *
FROM emp;

--9999직원의 부서번호와 직업정보를 스미스사원의 정보로 업데이트 -- 잘 쓰지 않는다. 서브 쿼리를 업데이트 양만큼 써야 하니까 --> merge를 사용한다. DML인데 기본은 아니다. 
UPDATE emp SET deptno = (SELECT deptno
                         FROM emp
                         WHERE ename = 'SMITH'),
                job = (SELECT job
                         FROM emp
                         WHERE ename = 'SMITH')
WHERE empno = 9999;

SELECT deptno, job
FROM emp
WHERE ename = 'SMITH';

SELECT *
FROM emp;
WHERE empno = 9999;

-- DELETE : 기존 데이터 삭제. 이미있는 데이터를 가공하기 때문에 WHRER 이 중요하다. (INSERT도 마찬가지)
-- 행을 지우기 때문에 컬럼에 대한 기술이 없어 문법이 간단
DELETE 테이블명
WHERE 조건;

DELETE 테이블명; --> 모두 삭제 (트랜잭션의 시작은 첫 DML부터. 첫 INSERT가 있었던 곳부터 자동으로 묶인다. DBMS마다 다르다. 어떤 것은 시작점을 명시해야 한다. )
-- 트랜잭션 (논리적 일의 단위)
-- 첫 DML문 실행시 자동 시작
-- commit, rollbakc 시 종료.

DELETE emp
WHERE empno = 9999; -- 행을 식별할 수 있는 조건이면 모두 가능

-- 매니저 7698인 사람들 5명 지우기
SELECT mgr
FROM emp
WHERE mgr = 7698; -- 다른 방법으로 해본다면

SELECT *
FROM emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698); -- UPDATE 하기 전에 WHERE절의 SELECT부터 써보는 건 좋은 습관
DELETE emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698);

ROLLBACK;

--데이터를 삭제하는 다른 방법
-- DBMS 는 DML 문장을 실행하면 REDO LOG를 남긴다.
-- UNDO(REDO) 로그(파일의 맨 마지막에 붙이기만해서 빠르다). -> 사용자의 이력을 저장 (정전) 
-- 데이터 흐름에 대한 교통정리. 데이터 입력하면 메모리에 올라간다. 메모리가 갖고 있다가,
-- 데이터 입력되면 메모리에도 쓰고 지정된 데이터파일에 기록도 함.
-- 1억건 삭제하면 REDO LOG에 기록된다는것. 복구를 위한 안전대비책.
-- 개발을 하는 입장에서는 TEST가 필요. 
-- REDO로그 남기지 않고 삭제는 할 수 있다. 복구 필요없고 빠른실행.
-- 함부로 하면 안된다. 복구할 수 없으니까. DML아니라서 (DDL이다) ROLLBACK도 안된다. 
TRUNCATE
- DDL
- ROLLBACK 불가
- 주로 테스트 환경에서 사용
TRUNCATE TABLE 테이블명; (부분 삭제가 아니라 전체 테이블을 삭제하는 것)

CREATE TABLE emp_test AS
SELECT *
FROM emp;

SELECT *
FROM emp_test;

TRUNCATE TABLE emp_test;

ROLLBACK;

-같은 계정으로 두 창을열면 동일 계정으로 쓰는 두 사용자로본다. 
- A 사용자가 데이터를 입력했을 때, B 사용자에게는 뜨지 않음 . commit으로 확정을 하기 전에는..
- 읽기의 일관성(어려움)
- DAP 자격증카페?
- 오라클과 다른 dbms와는 큰 차이점
데이터 변경 기록이 데이터 블록에 차례차례 시간별로 저장되는데, 다른 사용자는 그걸 보면 안되니까. 커밋하기 전이니까. 
오라클이 알아서, 다른 사용자가 봐야하는 undo 데이터를 보여준다. 
오라클은 디비 블록을 멀티버전으로 관리한다. 
일관성레벨을 막 수정하면 위험하다. 그냥써라.
읽기 일관성 레벨(isolation level)이 있다.총 4단계. 0~3.
트랜잭션의 실행 결과가 다른 트랜잭션한테 어떤 영향을 미치는지 정의한 단계

LEVEL. 0: READ UNCOMMITED
 - dirty(변경이 가해졌다) read : 커밋되지 않은 것도 읽을 수 있다. 
 - 커밋을 하지 않은 변경 사항도 다른 트랜잭션에서 확인 가능
 - 오라클은 지원하지 않음
 
LEVEL. 1: READ COMMITED
- 대부분의 DBMS 읽기 일관성 설정 레벨
- 커밋한 데이터만 다른 트랜잭션에서 읽을 수 있다. 
- 커밋하지 않은 데이터는 다른 트랜잭션에서 볼 수 없다.

LEVEL. 2: Repeatable READ
- 선행 트랜잭션에서 읽은 데이터를 후행 트랜잭션에서 수정하지 못하도록 방지 
- 끼어듦 방지
- 선행 트랜잭션에서 읽었던 데이터를 트랜잭션의 마지막에서 다시 조회를 해도 동일한결과가 나오게끔 유지
- 한쪽에서 데이터를 업데이트하고 커밋했다. 그런데 한쪽이 그 데이터를 읽을 때 결과가 달라지면 안되니까(처음에는 15건이었는데 13건으로 줄었네?). 동일한 결과를 보여주도록. 
- 기존 데이터에 대해서는 유지시켜주지만, 신규입력데이터에 대해서는 막을 수 없음
- 신규입력데이터 (Phantom Read) -> 갑자기 나타난 데이터. 
- 오라클에서 공식적으로 지원하지는 않지만, FOR UPDATE 구문으로 효과를 만들어낼 수 있다.
SELECT *
FROM emp
FOR UPDATE; --> 자원을 잡아놓고, 다른 접속자가 수정하지 못하게 막는다. - 누가 자원을 잡고 있으니까 대기 상태로. 
--> 이 사람이 트랜잭션을 완료(확정, 취소)를 했을 때에 자원이 넘어간다. 
?? 커밋을 하지 않으면 자바에서 자원을 쓸 수 없다? - ? FOR UPDATE를 건 것도 아닌데?? 동일한 데이터는 동시에 작업할 수없다. 셀렉트와는 다르게..

LEVEL. 3: Serializable Read 직렬화 읽기
- 후행 트랜잭션에서 수정, 입력 삭제한 데이터가 선행 트랜잭션에 영향을 주지 않음
- 신규 데이터 입력도 막는다. 
- 선 : 데이터 조회(14)
- 후 : 신규에 입력(15)
- 선 : 데이터 조회(14)
- 오라클은 멀티 데이터 블럭이기 때문에 동시성이 높다. 다른 dbms에서는 그냥 locking을 한다. 
- 근데 잃는 것도 있다. 블럭 버전이 여러개고, 메모리에 올라가있잖아. 메모리공간이한정되어 있으니까. 오래된 데이터는 내려가는데. 시간이 오래 걸리는 셀렉트쿼리를 짰을 때. 해당데이터찾으러갔을때 메모리에서 밀리면 조회가 안된다. snapshot too old. 

-- 

-- 인덱스!
- 눈에 보이지 않음
- 테이블의 일부 컬럼을 사용하여 데이터를 정렬한 객체 -> 원하는 데이터를 빠르게 찾을 수 있다. 
- 테이블과 같이 존재한다. 테이블에 인덱스를 만들 수 있다.
- 일부 컬럼과 함께 그 컬럼의 행을 찾을 수 있는 ROWID가 같이 저장됨. 값이 정렬되어 있다!
- 정렬이 되어 있으면 오라클은 더 빠른 경로로 찾아갈 수 있다. 
- ROWID : 행의 아이디. 테이블에 저장된 행의 물리적 위치, 집 주소 같은 개념. 주소 통해 해당 행의 위치로 빠르게 접근 가능. 데이터가 입력이 될 때 생성. 오라클이 알아서 생성. 

SELECT ROWID, emp.*
FROM emp;

SELECT emp.*
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACLAAA';

SELECT emp.*
FROM emp
WHERE empno = 7782; --> 행을 다 읽어본다. 

SELECT ROWID, empno
FROM emp;

SELECT *
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACLAAG';

EXPLAIN PLAN FOR    -- 실행 계획을 보면 인덱스를 이해할 수 있다. 
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY); -- 


name - 관련 객체
그런데 이 아래 부분은 다 예측이니까 안 봐도 된다. 
rows - 예측값. 실제 그부분을 실행했을 때 1건이 나올 것같다. -> 복잡해지면 틀려질 수 있다.
bytes - 데이터 읽기까지 얼마나 바이트를 읽었는지
cost - 비용이 얼마나 들었는지. 상대적인 개념
time - 실행 시간 

table access full 데이터 다 읽었다 -> 비효율적이다.
* - 정보가 있다. 데이터 다 읽고 필터링처리를 했다. 1개 제외하고 다 버렸다. 비효율적.
테이블은 정렬이 되어 있지 않다. 내가 찾고자하는데이터 어디있는지 알 수 없다. 그래서인덱스를 활용하는 것. 

오라클 객체 생성
CREATE 객체타입(INDEX, TABLE,...) 객체명
인덱스 생성
CREATE [UNIQUE] INDEX 인덱스이름 ON 테이블명(컬럼1, 컬럼2, ...); -- 유니크는 유일해야 한다는 것.

CREATE UNIQUE INDEX PK_emp ON emp(empno);

EXPLAIN PLAN FOR    -- 실행 계획을 보면 인덱스를 이해할 수 있다. 
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    38 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    38 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7782)

filter가 아니라 access로 변했다. rowid를 알고있으니까, 정렬이 되어 있으니까 하나하나 필터링하지 않고 접근했다는 것. 
인덱스 한 건읽고, 테이블 한 건 읽고.
이게 아니면 테이블 14건 다 읽는 것. 

EXPLAIN PLAN FOR    
SELECT empno
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 56244932
 
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |     1 |     4 |     0   (0)| 00:00:01 |
|*  1 |  INDEX UNIQUE SCAN| PK_EMP |     1 |     4 |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("EMPNO"=7782)
   
중간에 테이블을 읽지 않았다. empno는 인덱스에 있으니까. 

--
DROP INDEX PK_EMP;  -- 인덱스 삭제


CREATE INDEX IDX_emp_01 ON emp (empno); -- 유니크를 뺐다. 중복이 가능한 인덱스. 어떤 차이가 있나 보자.

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 4208888661
 
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    38 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    38 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_01 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7782)
   
INDEX UNIQUE SCAN -> INDEX RANGE SCAN
하나만 읽는 게 아니라 여러개를 읽는다. 데이터가 더 있을 수 있으니까. 정렬으로 제한된 범위 내에서 일단 다 읽는 것. 

-- jop 컬럼 인덱스
-- 쿼리를 실행하고 싶을 때경우의 수가 3개 생긴 것. 테이블 다 읽거나, 첫 인덱스 읽고 테이블로 접근, 두번째 인덱스 읽고 테이블로 접근. 
CREATE INDEX idx_emp_02 ON emp (job); 

EXPLAIN PLAN FOR    
SELECT *
FROM emp
WHERE job = 'MANAGER';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     3 |   114 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     3 |   114 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER')
   

--

EXPLAIN PLAN FOR    
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    38 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    38 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')        -- 얘가 추가됐다. 3건에 대해 테이블에 접근한 상태에서 2건을 거른 거야. 
   2 - access("JOB"='MANAGER')
   
   
-- 두 개 컬럼을 기준으로 인덱스

CREATE INDEX IDX_EMP_03 ON emp (job, ename);

SELECT job, ename, ROWID
FROM emp
ORDER BY job, ename;

EXPLAIN PLAN FOR    
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    38 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    38 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%') -- 정렬을 찾아가는 조건이 늘었다. 인덱스에 조건을 두 개 다 갖고 있으니까. 한번만 접근하면 된다. 필터(읽고나서 버린다) 조건이 여기서 해결된다. 
       filter("ENAME" LIKE 'C%') --jones를 걸렀다는 뜻.
       

---
EXPLAIN PLAN FOR    
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE '%C';  -- 정렬,인덱스 의미가 없어짐. 처음에는 어떤 글자가 와도 괜찮으니까. 액세스 조건으로 좋지 않다. 
  
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    38 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    38 |     2   (0)| 00:00:01 | -- 계획은 이렇게 세웠지만, 실제로 접근은 하지 않았다. 조건을 만족하는 데이터가없기 때문에.
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER')  -- 조건으로 얘만 쓴 다음에
       filter("ENAME" LIKE '%C' AND "ENAME" IS NOT NULL) -- 이 조건으로는 필터링만 한 것. 인덱스 4건을 읽어야 했다.

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

---
ROLLBACK;
