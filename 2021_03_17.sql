-- function 
-- character
SELECT ename, LOWER(ename), UPPER(ename), INITCAP(ename) -- 함수도 expression의 한 종류다. 원래 값을 가공하거나 없던 값을 만들어내거나. 
FROM emp;

SELECT ename, LOWER(ename), LOWER('TEST') 
FROM emp;

-- 문자열
SELECT ename, LOWER(ename), LOWER(SUBSTR(ename, 2, 3))
FROM emp;

-- DUAL 테이블
SELECT *
FROM dual;

SELECT LENGTH('TEST') -- 고정된 문자열의 수를 알고 싶다. 
FROM emp; -- 14번 실행된다. 쓸데 없이.

SELECT LENGTH('TEST')
FROM dual; -- 행이 하나니까 한 번만 실행된다.

SELECT *
FROM dual
CONNECT BY LEVEL <= 10;

-- 싱글 where절에서 사용
SELECT *
FROM emp
WHERE LENGTH(ename) > 5;

SELECT * 
FROM emp
WHERE LOWER(ename) = 'smith'; -- 권장하지 않음. 실행횟수가 많아진다. LOWER함수가 14번 실행된다.

SELECT * 
FROM emp
WHERE ename = UPPER('smith'); -- 1번만 실행되면 되니까. 데이터가 많아지면 속도가 중요하다.

--- 문자, 문자열
SELECT 'HELLO' || ',' || 'WORLD', 
        CONCAT('HELLO', CONCAT(',', 'WORLD')) CONCAT,
        SUBSTR('HELLO, WORLD', 1, 5) SUBSTR,
        LENGTH('HELLO, WORLD') LENGTH,
        INSTR('HELLO, WORLD', 'O') INSTR,  -- o는 두번 나오는데 첫 o의 자리만 반환된다. 
        INSTR('HELLO, WORLD', 'O', 6) INSTR2, -- 6번째 자리부터 시작해라. 
        LPAD('HELLO, WORLD', 15, '*') LPAD, -- 해당 문자열을 총 15자리로 만들고 싶다. 부족한 칸을 별표로 채워 넣어라.
        RPAD('HELLO, WORLD', 15, '_') RPAD,
        REPLACE('HELLO, WORLD', 'O', 'X') REPLACE, -- o를 x로 바꾸고 싶다. 
        TRIM('  HELLO, WORLD   ') TRIM, -- 공백을 제거, 문자열 앞과 뒷부분에 있는 공백만! 가운데 공백은 건들지 않는다.
        TRIM('D' FROM 'HELLO, WORLD') TRIM2
FROM dual;

-- 숫자
SELECT MOD(10, 3)
FROM dual;


SELECT ROUND(105.54, 1) round1,-- 반올림 결과가 소수점 첫번째 자리까지 나오도록. 소수점 둘째 자리에서 반올림
        ROUND(105.54, 0) round2, -- 반올림 결과가 정수 첫번째 자리 (1의 자리)까지 나오도록. 소수점 첫째 자리에서 반올림
        ROUND(105.54, -1) round3, -- 반올림 결과가 10의 자리)까지 나오도록. 정수 첫째 자리에서 반올림
        ROUND(105.54) round4, -- 두번째 인자를 쓰지 않으면 0이 기본값. 그냥 정수가 된다. 
        TRUNC(105.54, 1) trunc1,-- 절삭 결과가 소수점 첫번째 자리까지 나오도록. 소수점 둘째 자리에서 절삭
        TRUNC(105.54, 0) trunc2, -- 절삭 결과가 정수 첫번째 자리 (1의 자리)까지 나오도록. 소수점 첫째 자리에서 절삭
        TRUNC(105.54, -1) trunc3, -- 절삭 결과가 10의 자리까지 나오도록. 정수 첫째 자리에서 절삭
        TRUNC(105.54) trunc4 -- 두번째 인자를 쓰지 않으면 0이 기본값
FROM dual;

SELECT empno, ename, sal, TRUNC(sal / 1000) 몫, MOD(sal, 1000) 나머지
FROM emp;

-- 날짜/시간

SELECT SYSDATE, 
       SYSDATE + 5/24 시, 
       SYSDATE + 5/24/60 분, 
       SYSDATE + 5/24/60/60 초  -- 날짜에 정수를 사칙연산하면 일수를 조작할 수 있다. / '/'값으로 넣어주면 시간도 조작할 수 있다. 
FROM dual;

SELECT TO_DATE('20191231', 'YYYYMMDD') lastday, 
       TO_DATE('20191231', 'YYYYMMDD') - 5 lastday_before5, 
       SYSDATE now, 
       SYSDATE - 3 now_before3
FROM dual;

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') 년월일,  
       TO_CHAR(SYSDATE) 기본, -- 형식 입력하지 않으면 서버 설정대로 나온다.
       TO_CHAR(SYSDATE, 'YYYY') 년, -- 년도만 
       TO_CHAR(SYSDATE, 'HH24') 시 -- 시간만
FROM dual;

-- DATE FORMAT
-- 주차 IW - 1~53
-- 주간요일 D - 1~7 (1:일요일, 2:월요일, 3:화요일, 4:수요일 ~ 7:토요일)
SELECT SYSDATE, TO_CHAR(SYSDATE, 'IW'), TO_CHAR(SYSDATE, 'D')
FROM dual;

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') DT_DASH,
        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') DT_DASH_WITH_TIME,
        TO_CHAR(SYSDATE, 'DD-MM-YYYY') DT_DASH_REVERSE
FROM dual;

-- 중첩
SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD')) DT_DASH
FROM dual;

2021-03-17 -> 2021-03-17 12:41:00 
SELECT TO_CHAR(TO_DATE('2021-03-17', 'YYYY-MM-DD'), 'YYYY-MM-DD HH24:MM:DD') 
FROM dual;

SELECT SYSDATE, TO_DATE(TO_CHAR(SYSDATE - 5, 'YYYYMMDD'), 'YYYYMMDD') a -- 시간을 서버 시간이 아니라 00:00:00으로 맞추고 싶어서.
FROM dual;                                                                    -- 'YYYYMMDD' 문자형식으로 변해서 시간 값을 잃어버린 것을 다시 날짜형식으로 바꾼 것.
