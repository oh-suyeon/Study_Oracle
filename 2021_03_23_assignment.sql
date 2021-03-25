-- outerjoin5 : 과제 :  4에 고객(customer) 이름 컬럼 추가하기  // 다시한번해보기
SELECT * 
FROM 
(SELECT p.*, :cid cid, cu.cnm, NVL(c.day, 0) day, NVL(c.cnt, 0) cnt 
FROM cycle c, product p, customer cu
WHERE p.pid = c.pid(+) 
      AND c.cid(+) = :cid) a, customer cu
WHERE a.cid = c.cid;
ORDER BY cu.cnm


-- 4. 1번 고객이 먹지 않는 제품 조회 / 고객 이름, 제품 이름
SELECT * 
FROM product
WHERE pid NOT IN (SELECT pid
                    FROM cycle
                    WHERE cycle.cid = 1);
                    
SELECT *
FROM customer; -- cid, cnm
SELECT *
FROM cycle; -- cid, pid, day, cnt
SELECT *
FROM product; -- pid, pnm


-- 1.
SELECT cycle.cid, customer.cnm, product.*, cycle.day, cycle.cnt
FROM product, cycle, customer
WHERE product.pid IN (SELECT cycle.pid
                  FROM cycle
                  WHERE cycle.cid = 1)
    AND product.pid = cycle.pid
    AND cycle.cid = customer.cid
    AND cycle.cid = 1;

SELECT *
FROM cycle;

--2.수정 완료! 고객이 안 먹는 것도 조회하는 것.
SELECT :cid cid, cu.cnm, p.*, NVL(c.day, 0) day, NVL(c.cnt, 0) cnt 
FROM cycle c, product p, customer cu
WHERE p.pid = c.pid(+) 
  AND c.cid(+) = :cid
  AND :cid = cu.cid;


