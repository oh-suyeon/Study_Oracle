-- 모든 / 특정 컬럼 조회

SELECT *
FROM cart;

SELECT cart_no, cart_prod 
FROM cart;

-- 컬럼 정보 확인

DESC cart;
DESC emp;
DESC member;

-- 컬럼의 별칭을 만들어 조회하기

SELECT cart_member AS "member name"
FROM cart;

SELECT cart_member names
FROM cart;

-- 연산자 : NUMBER, DATE 숫자, 날짜 타입 사칙 연산

SELECT cart_qty, cart_qty / 2
FROM cart;

SELECT sal, comm, sal + comm   
FROM emp;

SELECT  hiredate, hiredate - 7
FROM emp;

-- 연산자 :  varchar2 문자 타입 사칙 연산

SELECT '이 회원은 ' || mem_like || '을/를 좋아합니다.'
FROM member;

SELECT CONCAT(CONCAT('이 회원은 ', mem_like), '을/를 좋아합니다.')
FROM member;

-- WHERE절 조건 연산자로, 조건에 맞는 행만 필터링하기

SELECT mem_bir, mem_id -- 1970년대 이후 출생한 회원 출력 (?)12월 이후 생일자 출력 어떻게 하지?
FROM member
WHERE mem_bir > TO_DATE('1975/03/01', 'YYYY/MM/DD');

SELECT mem_name, mem_memorialday -- 99년 12월 12일 기념일인 회원 출력
FROM member
WHERE mem_memorialday = TO_DATE('1999/12/12', 'YYYY/MM/DD'); 

SELECT mgr, empno, ename -- 상사의 직원번호가 7839가 아닌 직원 출력
FROM emp
WHERE mgr != 7839;

SELECT empno, ename, job -- 영업사원인 직원 출력
FROM emp
WHERE job = 'SALESMAN';

