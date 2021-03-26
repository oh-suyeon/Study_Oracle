UPDATE emp SET deptno = (SELECT deptno
                        FROM emp
                        WHERE ename = 'SMITH')
WHERE ename = 'KING';

SELECT ename, deptno
FROM emp;

ROLLBACK;

DELETE emp
WHERE ename = 'KING';

ROLLBACK;

CREATE TABLE emp_test2 AS
SELECT * 
FROM emp;

SELECT *
FROM emp_test2;

DELETE emp_test;

SELECT *
FROM emp_test;

TRUNCATE TABLE emp_test;

SELECT *
FROM emp_test;

CREATE TABLE emp_test AS
SELECT *
FROM emp;

COMMIT;

SELECT *
FROM emp_test2;


EXPLAIN PLAN FOR
SELECT *
FROM emp_test2
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     1 |    87 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP_TEST2 |     1 |    87 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("EMPNO"=7782)
 
Note
-----
   - dynamic sampling used for this statement (level=2)
   
   
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
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
   
SELECT *
FROM emp
WHERE empno = 7782;



