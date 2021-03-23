-- outerjoin5 : 과제 :  4에 고객(customer) 이름 컬럼 추가하기 
SELECT p.*, :cid, cu.cnm, NVL(c.day, 0) day, NVL(c.cnt, 0) cnt 
FROM cycle c, product p, customer cu
WHERE p.pid = c.pid(+) AND 
c.cid(+) = :cid
ORDER BY cu.cnm;