-- 데이터 오름차순으로 정리하기
SELECT *
FROM emp
WHERE comm IS NOT NULL AND comm != 0
ORDER BY ename, sal DESC;

SELECT *
FROM emp;

-- 페이징 처리
-- 행번호 있는 상태, 이름 순으로 정렬, 
-- 페이지 3씩 보여지는데, 그 중 2번째 페이지를 보고 싶다.

SELECT *
FROM (SELECT ROWNUM rn, a.* 
        FROM (SELECT * 
              FROM emp
              ORDER BY ename) a)
WHERE rn BETWEEN :pageSize * (:page - 1) + 1 AND :pageSize * :page;   