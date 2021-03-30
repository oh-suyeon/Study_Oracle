SELECT LEVEL, empno, LPAD(' ', (LEVEL - 1) * 4) || ename ename, mgr, job 
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT LEVEL, empno, LPAD(' ', (LEVEL - 1) * 4) || ename ename, CONNECT_BY_ROOT(ename) root, mgr, job
FROM emp
START WITH job IN ('CLERK', 'SALESMAN')
CONNECT BY PRIOR mgr = empno;

SELECT emp.empno, LPAD(' ', (LEVEL - 1) * 4) || emp.ename ename, cut.path, 
        SUBSTR(cut.path, 0, INSTR(cut.path, '~') - 1) first,
        SUBSTR(cut.path, INSTR(cut.path, '~') + 1, INSTR(cut.path, '~', 1, 1)) second,        
        SUBSTR(cut.path, INSTR(cut.path, '~', 1, 2) + 1, INSTR(cut.path, '~', 2, 2)) third        
FROM emp,
    (SELECT empno, LTRIM(SYS_CONNECT_BY_PATH(ename, '~'), '~') path
     FROM emp
     START WITH mgr IS NULL
     CONNECT BY PRIOR empno = mgr) cut
WHERE emp.empno = cut.empno
START WITH emp.mgr IS NULL
CONNECT BY PRIOR emp.empno = emp.mgr;

SELECT c.cut, INSTR(c.cut, '~') f1,
        SUBSTR(c.cut, 0, INSTR(c.cut, '~') - 1) f2,
        INSTR(c.cut, '~', 1, 2) f3,
        SUBSTR(c.cut, INSTR(c.cut, '~') + 1) f4
FROM dual, (SELECT 'KING~JONES~SCOTT~ADAMS' cut
            FROM dual) c;
            
            
SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, CONNECT_BY_ISLEAF isleaf 
FROM emp
WHERE job != 'ANALYST'
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr; 

---

SELECT ename, sal, deptno,
        ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC)sal_rank
FROM emp;

SELECT *
FROM board_test;

SELECT *
FROM board_test;

---


SELECT *
FROM
(SELECT CONNECT_BY_ROOT(seq) root_seq, seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title 
FROM board_test
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq)
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY root_seq DESC, seq ASC;
