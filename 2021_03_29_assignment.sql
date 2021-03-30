--03.

CREATE TABLE emp_test3 AS SELECT * FROM emp;
CREATE TABLE dept_test2 AS SELECT * FROM dept;

CREATE UNIQUE INDEX idx_emp_test3_01 ON emp_test3 (empno, mgr);
CREATE INDEX idx_emp_test3_02 ON emp_test3 (ename);
/*CREATE INDEX idx_emp_test3_03 ON emp_test3 (deptno, sal, hiredate);*/ -- 6번 쿼리에서 hiredate 인덱스가 조회 안 된다
CREATE INDEX idx_emp_test3_03 ON emp_test3(deptno, sal);
/*CREATE INDEX idx_emp_test3_04 ON emp_test3(deptno, hiredate);*/ -- 6번 쿼리에서 소용 없음
/*CREATE INDEX idx_emp_test3_04 ON emp_test3(deptno, TO_CHAR(hiredate, 'yyyymm'));*/ -- 6번 쿼리에서 소용 없음
/*CREATE INDEX idx_emp_test3_04 ON emp_test3(hiredate);*/ -- 6번 쿼리에서 소용 없음
/*CREATE INDEX idx_emp_test3_04 ON dept_test2(deptno);*/ -- 6번 쿼리에서 소용 없음
DROP INDEX idx_emp_test3_04;



-------------------------------------------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT *
FROM emp_test3
WHERE empno = :empno;   
------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                  |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP_TEST3        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_TEST3_01 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=TO_NUMBER(:EMPNO))
--------------------------------------------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT *
FROM emp_test3
WHERE ename = :ename;
------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                  |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP_TEST3        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_TEST3_02 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ENAME"=:ENAME)

---------------------------------------------------------------------------------------------------------------------


EXPLAIN PLAN FOR
SELECT *
FROM emp_test3 EMP, DEPT
WHERE EMP.deptno = DEPT.deptno
AND EMP.deptno = :deptno
AND EMP.empno LIKE :empno || '%';
| Id  | Operation                     | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                  |     1 |   106 |     3   (0)| 00:00:01 |
|   1 |  MERGE JOIN CARTESIAN         |                  |     1 |   106 |     3   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID | EMP_TEST3        |     1 |    87 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN           | IDX_EMP_TEST3_03 |     5 |       |     1   (0)| 00:00:01 |
|   4 |   BUFFER SORT                 |                  |     1 |    19 |     1   (0)| 00:00:01 |
|   5 |    TABLE ACCESS BY INDEX ROWID| DEPT             |     1 |    19 |     1   (0)| 00:00:01 |
|*  6 |     INDEX RANGE SCAN          | IDX_DEPT_01      |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter(TO_CHAR("EMP"."EMPNO") LIKE :EMPNO||'%')
   3 - access("EMP"."DEPTNO"=TO_NUMBER(:DEPTNO))
   6 - access("DEPT"."DEPTNO"=TO_NUMBER(:DEPTNO))

-------------------------------------------------------------------------------------------------------------------


EXPLAIN PLAN FOR
SELECT *
FROM emp_test3
WHERE sal BETWEEN :st_sal AND :ed_sal
AND deptno = :deptno;
-------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                  |     1 |    87 |     2   (0)| 00:00:01 |
|*  1 |  FILTER                      |                  |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| EMP_TEST3        |     1 |    87 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_EMP_TEST3_03 |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(TO_NUMBER(:ST_SAL)<=TO_NUMBER(:ED_SAL))
   3 - access("DEPTNO"=TO_NUMBER(:DEPTNO) AND "SAL">=TO_NUMBER(:ST_SAL) AND 
              "SAL"<=TO_NUMBER(:ED_SAL))
    
--------------------------------------------------------------------------------------------------------------------              


EXPLAIN PLAN FOR
SELECT B.*
FROM emp_test3 A, emp_test3 B
WHERE A.mgr = B.empno
AND A.deptno= :deptno;
--------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                  |     1 |   113 |     4   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |                  |       |       |            |          |
|   2 |   NESTED LOOPS                |                  |     1 |   113 |     4   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| EMP_TEST3        |     1 |    26 |     2   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_EMP_TEST3_03 |     1 |       |     1   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN           | IDX_EMP_TEST3_01 |     1 |       |     1   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | EMP_TEST3        |     1 |    87 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("A"."DEPTNO"=TO_NUMBER(:DEPTNO))
   5 - access("A"."MGR"="B"."EMPNO")
   
---------------------------------------------------------------------------------------------------------------------   


EXPLAIN PLAN FOR
SELECT deptno, TO_CHAR(hiredate, 'yyyymm'),
COUNT(*) cnt
FROM emp_test3
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm');
--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |    14 |   308 |     4  (25)| 00:00:01 |
|   1 |  HASH GROUP BY     |           |    14 |   308 |     4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMP_TEST3 |    14 |   308 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------
 
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);




