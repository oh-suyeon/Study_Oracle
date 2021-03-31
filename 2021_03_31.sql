-- window 실습
SELECT empno, ename, sal, deptno, 
        -- 부서 별 평균 급여
        ROUND(AVG(sal) OVER (PARTITION BY deptno), 2) avg_sal,
        -- 해당 부서의 가장 낮은 급여
        MIN(sal) OVER (PARTITION BY deptno) min,
        -- 해당 부서의 가장 높은 급여
        MAX(sal) OVER (PARTITION BY deptno) max,
        SUM(sal) OVER (PARTITION BY deptno) sum,
        COUNT(*) OVER (PARTITION BY deptno) count
        -- 단순히 직계함수를 계산하기 위함이라면 남용하지 않는 게 좋음. GROUP BY로 하는 게 성능에 나음.
FROM emp;
 
--LAG, LEAD
-- 자신보다 급여순위가 한단계 낮은 사람급여를 5번째 컬럼으로 생성
SELECT empno, ename, hiredate, sal, 
       LEAD(sal) OVER (ORDER BY sal DESC, hiredate) lead -- sal이 같은 구간에서 문제가 생길 수 있으니 입사일자를 추가.  
FROM emp;
/*ORDER BY sal DESC; --> 내림차순으로 정렬된 상태. 바로 이전 행이 답이다. 필요없어져서 삭제 */

-- 급여 순위 1단계 높은 사람
SELECT empno, ename, hiredate, sal,
    LAG(sal) OVER (ORDER BY sal DESC, hiredate) lag
FROM emp;
-- 윈도우함수 사용하지 말고 1단계 높은 사람

SELECT a.empno, a.ename, a.hiredate, a.sal, rn 
FROM 
(SELECT ROWNUM rn, a.empno, a.ename, a.hiredate, a.sal
FROM 
(SELECT empno, ename, hiredate, sal
FROM emp
ORDER BY sal DESC, hiredate) a) a;
--왜 안되지ㅠㅠ
SELECT ROWNUM, emp.empno, emp.ename, emp.hiredate, emp.sal, a.sal
FROM emp,
    (SELECT rn, a.sal
     FROM 
         (SELECT ROWNUM rn, a.sal
          FROM 
             (SELECT sal
              FROM emp  
              ORDER BY sal DESC, hiredate) a) a
    WHERE rn BETWEEN 2 AND 14) a
WHERE ROWNUM = a.rn + 1;
-- 정답 rn을 넣은 같은 테이블을 두 개 만든다. rn값을 기준으로 OUTERJOIN하고, 정렬을 다시 써준다.  
SELECT a.empno, a.ename, a.hiredate, a.sal, b.sal
FROM 
    (SELECT ROWNUM rn, a.*
     FROM
        (SELECT empno, ename, hiredate, sal
         FROM emp
         ORDER BY sal DESC, hiredate) a) a,
    (SELECT ROWNUM rn, b.*
     FROM
        (SELECT empno, ename, hiredate, sal
         FROM emp
         ORDER BY sal DESC, hiredate) b) b
WHERE a.rn - 1 = b.rn(+)
ORDER BY a.sal DESC, a.hiredate;

-- 예제6: 윈도우 함수 이용. 1단계 높은 사람 급여 조회. 업무 별로. 
SELECT empno, ename, hiredate, job, sal,
    LAG(sal) OVER (PARTITION BY job ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

-- LEAD, LAG 두번째 인자 -- 일반적으로 많이 쓰지는 않는다. 
SELECT empno, ename, hiredate, sal,
    LAG(sal, 2) OVER (ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

SELECT empno, ename, hiredate, sal,
    LEAD(sal, 2) OVER (ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

-- 누적합 ** 실무에서 자주 나온다. 
-- 급여가 낮은 순으로, 윈도우 함수 없이, 자신 급여에 자신보다 낮은 급여들을 누적합. rownum, non-equi범위 조인, 

SELECT a.empno, a.ename, a.sal
FROM 
(SELECT ROWNUM rn, a.*
FROM (SELECT empno, ename, sal
FROM emp
ORDER BY sal, empno) a) a,
(SELECT ROWNUM rn, b.*
FROM (SELECT empno, ename, sal
FROM emp
ORDER BY sal, empno) b) b
WHERE b.rn BETWEEN 1 AND a.rn; --> 여기까지 잘 했다. 여기서 GROUP BY 를 하고 SUM을 하기만하면 됐음. 

-- 정답
1. ROWNUM
2. INLINE VIEW
3. NON-EQUI-JON
4. GROUP BY

SELECT a.empno, a.ename, a.sal, SUM(b.sal)
FROM
(SELECT ROWNUM rn, a.*
FROM (SELECT empno, ename, sal
FROM emp
ORDER BY sal, empno) a) a,
(SELECT ROWNUM rn, b.*
FROM (SELECT empno, ename, sal
FROM emp
ORDER BY sal, empno) b) b
WHERE a.rn >= b.rn
GROUP BY a.empno, a.ename, a.sal
ORDER BY a.sal, a.empno;

-- 윈도우 함수를 쓴다면
SELECT empno, ename, sal, 
    SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum, -- 명확하게 길더라도 이렇게 쓰는게 낫다.일반적인 형태.
    SUM(sal) OVER (ORDER BY sal, empno ROWS UNBOUNDED PRECEDING) c_sum2
FROM emp;


SELECT empno, ename, sal, 
    SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) c_sum -- 앞 뒤로 오는 행들을 더하기
FROM emp;


-- 7. 부서별 / 급여, 사번, 오름차순/ 자신과 선행하는 사원들 급여 합 조회 (윈도우 사용) / 윈도우 문법 총정리
SELECT empno,ename, deptno, sal,
    SUM(sal) OVER (PARTITION BY deptno ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sum
FROM emp;

-- 잘 사용하진 않지만 참고
ROWS | RANGE BETWEEN UNBOUNDED PRECEDING --> ROWS와 RANGE의 차이는? 
ROWS - 물리적인 행
RANGE - 논리적인 값의 범위. 같은 값을 하나의 행으로 본다. 정렬 기준이 sal 뿐이었을 때. 동등한 순위인 워드와 마틴.둘은 하나의 range로 본다. 워드 입장에서도 뒤에 자신과 '같은' 마틴이 있으니까. 하나의 행으로 본다.반대로 로우즈는 물리적으로 정확히 분리한다. 같은 값이더라도 내가 아니니까.  
-- 일반적으로 명확한 rows가 편하겠다. 그렇지만. 윈도윙을 적용하지 않으면 기본적으로는 range가 들어간다. 그러면 내가 의도하지 않은 값도 들어갈 수 있음을 주의!

ROWS와 RANGE의 차이
SELECT empno,ename, deptno, sal,
    SUM(sal) OVER (ORDER BY sal ROWS UNBOUNDED PRECEDING) rows_c_sum,
    SUM(sal) OVER (ORDER BY sal RANGE UNBOUNDED PRECEDING) range_c_sum,
    SUM(sal) OVER (ORDER BY sal) no_win_c_sum,
    SUM(sal) OVER () no_ord_c_sum -- 전체 합이나온다. 윈도윙은 기본적으로 ORDER BY가 있어야 사용할 수 있다. 그래야 이전, 이후 행을 알 수 있으니까. ORDER BY를 썼는데 윈도윙을 안썼으면 기본값인 RANGE가 적용된다.
FROM emp;

--이것도 찾아보기
RATIO_TO_REPORT
PERCENT_RANK
CUME_DIST
NTILE


