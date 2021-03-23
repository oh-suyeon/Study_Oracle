--outerjoin2 : buy_date 컬럼이 null인 항목이 안 나오도록 
SELECT TO_DATE(:yyyymmdd, 'YYYYMMDD'), b.buy_prod, p.prod_id, p.prod_name, NVL(b.buy_qty, 0)
FROM buyprod b, prod p
WHERE p.prod_id = b.buy_prod(+) AND buy_date(+) = TO_DATE(:yyyymmdd, 'YYYYMMDD');

--outerjoin3 : b.buy_qty 값이 null이면 0이 나오도록
SELECT TO_DATE(:yyyymmdd, 'YYYYMMDD'), b.buy_prod, p.prod_id, p.prod_name, NVL(b.buy_qty, 0)
FROM buyprod b, prod p
WHERE p.prod_id = b.buy_prod(+) AND buy_date(+) = TO_DATE(:yyyymmdd, 'YYYYMMDD');

--outerjoin4 :먹지 않는 제품도 조회되도록 기본은 pid, pnm
SELECT *
FROM cycle;
SELECT *
FROM product;

SELECT p.*, :cid, NVL(c.day, 0) day, NVL(c.cnt, 0) cnt 
FROM cycle c, product p
WHERE p.pid = c.pid(+) AND 
c.cid(+) = :cid;

SELECT product.*, cycle.cid, cycle.day, cycle.cnt 
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid = 1);

SELECT product.*, :cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt 
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid = :cid); -- 바인딩 변수로 처리하는 게 좋다. 

-- outerjoin5 : 과제 :  4에 고객(customer) 이름 컬럼 추가하기 
SELECT p.*, :cid, cu.cnm, NVL(c.day, 0) day, NVL(c.cnt, 0) cnt 
FROM cycle c, product p, customer cu
WHERE p.pid = c.pid(+) AND 
c.cid(+) = :cid
ORDER BY cu.cnm;

-- CROSS JOIN
SELECT *
FROM emp, dept;

--cross join1 - 고객이 먹을 수 있는 모든 제품 조합
SELECT c.cid, c.cnm, p.pid, p.pnm 
FROM customer c, product p;


-- 지역 별 프랜차이즈 매장 수
SELECT storecategory
FROM burgerstore
WHERE SIDO = '대전'
GROUP BY storecategory;

SELECT *
FROM burgerstore;

-- 대전 중구 버거지수
-- 도시발전지수 : (kfc + 맥도날드 + 버거킹) / 롯데리아 = (1+3+2) / 3

SELECT st.sido, st.sigungu, 
    (COUNT(b.storecategory) + COUNT(m.storecategory) + COUNT(k.storecategory)) / COUNT(l.storecategory) 도시발전지수

FROM 
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구') st,
    
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구'
    AND storecategory = 'BURGER KING') b,
    
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구'
    AND storecategory = 'MACDONALD') m,
    
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구'
    AND storecategory = 'KFC') k,
    
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구'
    AND storecategory = 'LOTTERIA') l
    
WHERE st.storecategory = m.storecategory(+) 
    AND st.storecategory = k.storecategory(+) 
    AND st.storecategory = b.storecategory(+) 
    AND st.storecategory = l.storecategory(+) 
    
GROUP BY st.sido, st.sigungu;

-- 정답 
-- FROM으로 데이터를 한 번만 읽고 가져올 수 있는 방법
-- 행을 컬럼으로 변경하기 (PIVOT)

SELECT sido, sigungu, storecategory --  아래의 컬럼을 인위적으로 만들 것 (조건 분기)
        storecategory가 BURGER KING이면 1, 0
        storecategory가 KFC이면 1, 0
        storecategory가 MACDONALD이면 1, 0
        storecategory가 LOTTERIA이면 1, 0
FROM burgerstore;

SELECT sido, sigungu, storecategory,
    CASE
        WHEN storecategory = 'BURGER KING' THEN 1
        ELSE 0
    END bk
FROM burgerstore;

SELECT sido, sigungu,
    ROUND((SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) +
    SUM(DECODE(storecategory, 'KFC', 1, 0)) +
    SUM(DECODE(storecategory, 'MACDONALD', 1, 0))) /
    DECODE(SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)), 0, 1, SUM(DECODE(storecategory, 'LOTTERIA', 1, 0))), 2) idx  --"divisor is equal to zero" 오류가 난다. 나누는 수가 0인 지역이 있는 것. 분모가 0인 데이터는 어떻게 처리할 것인지 합의해야 한다. 우리는 1로 본다. 
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY idx DESC;

SELECT sido, sigungu,
    ROUND(SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) +
    SUM(DECODE(storecategory, 'KFC', 1, 0)) +
    SUM(DECODE(storecategory, 'MACDONALD', 1, 0)) /
    DECODE(SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)), 0, 1, SUM(DECODE(storecategory, 'LOTTERIA', 1, 0))), 2) idx
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY idx DESC;


