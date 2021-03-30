--- <<<< 가지치기 >>>>
SELECT -> [START WITH](상황에 따라 다르지만) -> WHERE -> GROUP BY -> SELECT -> ORDER BY 

SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, mgr, deptno, job
FROM emp
WHERE job != 'ANALYST'-- CONNECT BY와는 효과가 다르다. WHERE는 계층쿼리 완성된 후에 실행된다. (스콧과 포드 ANALYST 두 명이 뿅 없어진다. 얘들만 빠진다.)
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, mgr, deptno, job
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr AND job != 'ANALYST';  -- WHERE와 효과가 다르다. 계층 쿼리를 만들 때 조건이 적용되는 케이스. (스콧과 포드 뿐아니라 그들과 연결관 아담과 스미스도 빠진다. 4명이 빠져버린다. 가지치기라고 한다.)

-- 계층쿼리에서는 주로 WHERE절을 쓰기보다는 CONNECT를 쓰는 경우가 많다. 

--- <<<< 특수 함수 >>>>

SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, CONNECT_BY_ROOT(ename) root_ename -- 하향식 쿼리라서 모두 킹이다. 하지만 상향식 쿼리라든가, 게시판(루트가 많음)은 다르다.
FROM emp
WHERE job != 'ANALYST'
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr; 


SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, 
        LTRIM(SYS_CONNECT_BY_PATH(ename, '-'), '-') path    -- 어떻게 값을 타고 내려왔는지 볼 수 있다. LTRIM과 쌍처럼 쓰인다. 원래 공백을 지우는 거지만 문자열을 지정하면 지울 수 있다. 
                     -- 자바 같은 경우 split 함수를 사용하면 잘라서 배열에 넣을 수 있는데, INSTR, SUBSTR 여기서는 이렇게 잘라서 컬럼에 넣어야 한다. 검색한번해보기!
FROM emp
WHERE job != 'ANALYST'
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT empno, LPAD(' ', (LEVEL -1) * 4) || ename ename, CONNECT_BY_ISLEAF isleaf -- 리프면 1, 아니면 0
FROM emp
WHERE job != 'ANALYST'
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr; 

---- <실습>
SELECT *
FROM board_test;

SELECT seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title
FROM board_test
START WITH parent_seq IS NULL  --> SEQ IN(1, 2, 4)는 좋지 않음. 언제든 추가될 수 있으니까. 
CONNECT BY PRIOR seq = parent_seq;

-- 정렬... ORDER BY 어떻게 적용해야 하는지. 계층 구조 깨지지 않게. 게시판은 최신글 먼저 나와야 하니까.  
SELECT seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title
FROM board_test
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq DESC;

-- (그런데 답글은 최신순이 아니라 작성순이다)
-- 즉 시작(root) 글은 작성 순서의 역순으로, 답글은 작성순.

SELECT seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title
FROM board_test
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY NVL2(parent_seq, seq ASC, seq DESC);  -- 안된다
-- 첫번째 조건으로 정렬이 안되면 두 번째 조건으로 정렬이 된다. 
-- 글 단위끼리 공통된값을 줘야 한다.
시작글부터 관련 답글까지 그룹번호를 부여하기 위해 새로운컬럼 추가

ALTER TABLE board_test ADD (gn NUMBER); --테이블 변경. 컬럼 추가. 

DESC board_test;

UPDATE board_test SET gn = 1
WHERE seq IN (1, 9);

UPDATE board_test SET gn = 2
WHERE seq IN (2, 3);

UPDATE board_test SET gn = 4
WHERE seq NOT IN (1, 2, 3, 9);

COMMIT;

SELECT CONNECT_BY_ROOT(seq)
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq;

SELECT gn, CONNECT_BY_ROOT(seq) root_seq, seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title   -- 게시판의 일반 형태
FROM board_test
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY gn DESC, seq ASC;     -- gn을 안 만들고 root_seq을 넣을 수 있을까? 없다! 특수함수를 order by에 쓸 수 없다. -> 인라인 뷰로 만들기

SELECT *
FROM
(SELECT CONNECT_BY_ROOT(seq) root_seq, seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title 
FROM board_test
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq)
START WITH parent_seq IS NULL  
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY root_seq DESC, seq ASC; -- seq ASC때문에 다시 계층을 타야한다. 좀 복잡해졌지만 컬럼을 추가하지 않았으니까.

-- 페이징 처리 

SELECT *
FROM
 (SELECT ROWNUM rm, a.* 
   FROM (SELECT empno, ename      
     	   FROM emp
     	   ORDER BY ename) a )  -- 안쪽 내용만 바꿔주면 된다. 
WHERE rn BETWEEN :pageSize * (:page - 1) + 1 AND :pageSize*:page;

SELECT *
FROM
 (SELECT ROWNUM rn, a.* 
  FROM (SELECT gn, CONNECT_BY_ROOT(seq) root_seq, seq, parent_seq, LPAD(' ', (LEVEL -1) * 4) || title title  
         FROM board_test
         START WITH parent_seq IS NULL  
         CONNECT BY PRIOR seq = parent_seq
         ORDER SIBLINGS BY gn DESC, seq ASC) a )  -- 이렇게 내부 쿼리만 교체한다.
WHERE rn BETWEEN :pageSize * (:page - 1) + 1 AND :pageSize*:page;


----<<분석함수 window 함수 - 행 간 연산>> 주식 전일대비 = 현재행의 종가 - 이전행 종가 

SELECT *
FROM emp
WHERE deptno =10 AND sal = (SELECT MAX(sal)
                            FROM emp
                            WHERE deptno =10); -- deptno=10 를 두 번 읽어야 한다. 분석함수로 이걸 한 번만 읽도록 할 수 있다.
                            
-- 부서별 급여순위
SELECT ename, sal, deptno, (??)sal_rank
FROM emp
ORDER BY deptno, sal_rank;

SELECT ROWNUM rn, a.*
FROM
(SELECT ename, sal, deptno 
FROM emp
WHERE deptno = 10
ORDER BY deptno, sal DESC) a

SELECT ROWNUM rn, b.*
FROM
(SELECT ename, sal, deptno 
FROM emp
WHERE deptno = 20
ORDER BY deptno, sal DESC) b;

SELECT ROWNUM rn, c.*
FROM
(SELECT ename, sal, deptno 
FROM emp
WHERE deptno = 30
ORDER BY deptno, sal DESC) c;

--분석함수없이 만들어보기
SELECT a.*, ROWNUM rn
FROM
(SELECT ename, sal, deptno
FROM emp
ORDER BY deptno, sal DESC) a;

SELECT *
FROM 
    (SELECT ROWNUM rn
     FROM emp) a,
    (SELECT deptno, COUNT(*) cnt -- deptno 그룹 행 숫자만큼, 순위를 매겨야 한다. 
     FROM emp
     GROUP BY deptno) b
WHERE a.rn <= b.cnt -- 그룹 행 숫자와 순위를 BETWEEN으로 연결. 순위는 첫 행(1)부터 그룹 행 숫자만큼 가져오는 걸로.  
ORDER BY b.deptno, a.rn;

-- 복잡하고 동일 테이블을 3번 읽어야 함. 쿼리도 간단하고 테이블을 한번만 읽는 분석 함수가 좋다. 
SELECT a.ename, a.sal, a.deptno, b.rank
FROM 
    (SELECT a.*, ROWNUM rn
     FROM
        (SELECT ename, sal, deptno
         FROM emp
         ORDER BY deptno, sal DESC) a) a,

    (SELECT ROWNUM rn, rank
     FROM 
        (SELECT a.rn rank
         FROM 
             (SELECT ROWNUM rn
              FROM emp) a,
        (SELECT deptno, COUNT(*) cnt
         FROM emp
         GROUP BY deptno) b
     WHERE a.rn <= b.cnt
     ORDER BY b.deptno, a.rn)) b
WHERE a.rn = b.rn;
--

SELECT ename, sal, deptno, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank -- 다른 함수와 달리 분석함수는 over가 붙는다. 
FROM emp; -- 20번 부서에 공동 1등이 있는데 이따가 공동 순위 처리 함수를 배울 거다. 
ORDER BY deptno, sal DESC;   -- 분석함수로 내부적으로 정렬이 되어서 ORDER BY 하지 않아도 된다. 
PARTITION BY deptno -- 같은 부서코드같는 row를 그룹으로 묶기
ORDER BY sal DESC 그룹 내에서 sal 로 row 의 순서를 정한다. 
RANK() : 파티션 단위 안에서 순위 부여

-- 순위 관련 함수 RANK, DENSE_RANK, ROW_NUMBER (자격증시험 차이 알아야 함 - 중복 값을 어떻게 처리하는가?)
SELECT ename, sal, deptno, 
        RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank,
        DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_dense_rank,
        ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_row_number
FROM emp;	

--  사원 전체 급여 순위. 급여 동일할 경우 사번 순위 정렬.
SELECT empno, ename, sal, deptno,
        RANK() OVER (ORDER BY sal DESC, empno) sal_rank,
        DENSE_RANK() OVER (ORDER BY sal DESC, empno) sal_dense_rank,
        ROW_NUMBER() OVER (ORDER BY sal DESC, empno) sal_row_number
FROM emp;

---부서의 사원수 조회 컬럼 넣기

SELECT emp.empno, emp.ename, emp.deptno, cn.count
FROM emp, (SELECT deptno, count(*) count
            FROM emp
            GROUP BY deptno) cn
WHERE emp.deptno = cn.deptno
ORDER BY emp.deptno;

SELECT empno, ename, deptno,
      COUNT(*) OVER (PARTITION BY deptno) cnt -- 행의 개수를 세는 데 정렬은 필요하지 않다.  
FROM emp;

