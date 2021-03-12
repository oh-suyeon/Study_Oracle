--[sem계정]에 있는 prod 테이블의 모든 컬럼을 조회하는 SELECT 쿼리 (SQL) 작성
SELECT *
FROM prod;

--[sem계정]에 있는 prod 테이블의 prod_id, prod_name 두 개의 컬럼을 조회하는 SELECT 쿼리 (SQL) 작성
SELECT prod_id, prod_name
FROM prod;

--실습 select1
SELECT *
FROM lprod;

SELECT buyer_id, buyer_name
FROM buyer;

SELECT *
FROM cart;

SELECT mem_id, mem_pass, mem_name
FROM member;

--테이블의 컬럼 정보 조회
DESC emp;

--연산
----"empno + 10"과 같이 컬럼 정보가 아닌 수식, 연산은 expression이라고 부른다.
SELECT empno + 10
FROM emp;

SELECT empno, empno + 10
FROM emp;

SELECT empno, empno + 10, 10 -- "10"값을 10으로 통일하겠다.
FROM emp;

SELECT hiredate, hiredate + 10 -- 날짜와 숫자를 더하면, '일수'에 더해진다. 날짜는 +와 -만 가능.
FROM emp;

SELECT hiredate, hiredate - 10 
FROM emp;

SELECT empno, empno emp_plus -- 조회되는 컬럼명을 바꾸기. 특히 복잡한 expression이 컬럼명이 되기 때문에 지정해주는 게 좋음
FROM emp;

SELECT empno, empno AS emp_plus
FROM emp;

SELECT empno empno -- 컬럼명 [별칭명] 이므로 잘 실행된다. **시험문제
FROM emp;

SELECT empno "emp no" -- 쌍따옴표 안에 넣으면 소문자와 공백도 가능하다
FROM emp

-- NULL아직 모르는 값
----0과 공백은 NULL과 다르다.
----**** (중요) NULL을 포함한 연산은 결과가 항상 NULL 이다.****

SELECT ename, sal, comm, comm + 100 -- (NULL + 100 = NULL)
FROM emp;

SELECT ename, sal, comm, sal + comm, comm + 100 -- (총 연봉 구하려고 sal + comm = NULL일 수 있어 문제가 된다. NULL값을 다른 값으로 치환해주는 함수가 필요하다
FROM emp;

--실습 select2

SELECT prod_id AS "id", prod_name AS "name" 
FROM prod;

SELECT lprod_gu "gu", lprod_nm "nm" 
FROM lprod;

SELECT buyer_id "바이어아이디", buyer_name "이름" 
FROM buyer;

--literal 값 자체
----literal 표기법 : 값을 표현하는 방법

SELECT empno, 10, 'Hello World' -- 문자열은 따옴표에 표현
FROM emp;

--문자열 연산  

DESC emp;

SELECT empno + 10, ename || 'Hello' || ', World',
        CONCAT(ename, ', World')
FROM emp;

-- 컬럼 값을 '아이디 : brown'로 출력하기

SELECT CONCAT('아이디 :', userid)
FROM users;

SELECT '아이디 :' || userid
FROM users;

-- 실습 
---- 세 개의 문자열 결합하고 컬럼 별칭 만들기
------ CONCAT(CONCAT(문자열1, 문자열2), 문자열3)

SELECT table_name
FROM user_tables;

SELECT 'SELECT * ' || table_name || ';' query,
        CONCAT(CONCAT('SELECT * ', table_name), ';') query2
FROM user_tables;

--WHERE 절 조건 연산자
----부서번호 10번 직원들만
SELECT *
FROM emp
WHERE deptno = 10;
----users 테이블에서 userid 컬럼 값이 brown인 사용자만 조회
SELECT *
FROM users
WHERE userid = 'brown';
----emp 테이블에서 부서번호가 20번보다 큰부서에 속한 직원 조회
SELECT * 
FROM emp
WHERE deptno > 20;
----emp 테이블에서 부서번호가 20번 부서에 속하지 않은 직원 조회
SELECT * 
FROM emp
WHERE deptno != 20;
----언제나 참인 조건으로 필터링하면, 모든 결과가 나온다 (모두 만족하므로) 
----쓸데없어보이지만 나중에 활용하게 된다
SELECT * 
FROM emp
WHERE 1=1;
----언제나 거짓인 조건으로 필터링하면 결과가 아무것도 안 나온다 (모두 불만족하므로)
SELECT * 
FROM emp
WHERE 2=1;
----날짜값 표기하기 (날짜 문자열을 날짜 값으로 변경하는 TO_DATE() 함수를 사용하기)
SELECT empno, ename, hiredate
FROM emp
WHERE hiredate >= TO_DATE('1981/03/01', 'YYYY/MM/DD');
