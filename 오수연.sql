
SELECT st.sido, st.sigungu, 
    (COUNT(b.storecategory) + COUNT(m.storecategory) + COUNT(k.storecategory)) / COUNT(l.storecategory) 도시발전지수

FROM 
(SELECT sido, sigungu, storecategory
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구') st,
    
(SELECT sido, sigungu, COUNT(*) c
FROM burgerstore
WHERE sido = '대전' 
    AND sigungu = '중구'
    AND storecategory = 'BURGER KING'
    GROUP BY sido, sigungu) b,
    
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
    
WHERE
    
GROUP BY st.sido, st.sigungu;

-- 

