 -- 인덱스 객체 생성
 -- 사용예) 상품 테이블에서 상품명으로 NORMAL INDEX를 구성하시오
 CREATE INDEX idx_prod_name
    ON prod(prod_name);
 
 -- 사용예) 장바구니테이블에서 장바구니번호 중 3번째에서 6글자로 인덱스를 구성하시오 (함수 인덱스)
 CREATE INDEX idx_cart_no
    ON cart(SUBSTR(cart_no, 3, 6));
 
 
 -- 인덱스 재구성
 
 -- PL/SQL 
 -- 익명 블록
 -- 사용예) 키보드로 2-9사이의 값을 입력 받아 그 수에 해당하는 구구단을 작성하시오
 ACCEPT p_num PROMPT '수 입력(2~9) : ' -- ACCEPT 많이 사용하지 않는 명령어. 값을 입력받는다. ACCEPT 변수명 PROMPT 메시지 (;을 붙이지 않음)
 DECLARE
   v_base NUMBER := TO_NUMBER('&p_num'); -- 변수는 v로, 매개변수는 p로 시작하는 게 일반적 / := 대입(할당)연산자 파스칼 문법 / p_num의 값을 참조하려면 & 붙이기
   v_cnt NUMBER := 0;   -- 오라클의 초기값은 숫자든 문자든 null. null은 숫자로 자동형변환이 되지 않기 때문에, 밑에서 숫자와 연산하기 위해서는 0값으로 초기화해줘야 한다. 숫자 변수 초기화는 중요하다. 
   v_res NUMBER := 0;
BEGIN 
   LOOP -- LOOP / END LOOP는 무한 루프. 나가려면 EXIT WHEN이 필요.
      v_cnt := v_cnt + 1;
      EXIT WHEN v_cnt > 9;
      v_res := v_base * v_cnt;
      
      DBMS_OUTPUT.PUT_LINE(v_base||'*'||v_cnt||'='||v_res);
   END LOOP;
    
   EXCEPTION WHEN OTHERS THEN   -- WHEN OTHERS는 java의 EXCEPTION 클래스와 비슷.
      DBMS_OUTPUT.PUT_LINE('예외발생 : ' || SQLERRM); -- SQLERRM 에러메시지를 출력
END;

DESC member;
 
 -- 변수상수 선언
 -- 예) 장바구니에서 2005년 5월 가장 많은 구매를 한 (구매 금액 기준) 회원정보를 조회하시오 (회원번호, 회원명, 구매금액합)
 
 SELECT a.cart_member memid, 
        b.mem_name memnm, 
        SUM(c.prod_price * a.cart_qty) price
 FROM cart a, member b, prod c
 WHERE c.prod_id = a.CART_PROD AND
       b.mem_id = a.CART_MEMBER
GROUP BY a.cart_member, b.mem_name
ORDER BY price DESC;

SELECT r.*
FROM
(SELECT a.cart_member memid, 
        b.mem_name memnm, 
        SUM(c.prod_price * a.cart_qty),
        RANK() OVER (ORDER BY SUM(c.prod_price * a.cart_qty) DESC) pricerank
FROM cart a, member b, prod c
WHERE c.prod_id = a.cart_prod AND
       b.mem_id = a.cart_member
GROUP BY a.cart_member, b.mem_name) r
WHERE r.pricerank = 1;

SELECT f.*
FROM 
(SELECT a.cart_member memid, 
        b.mem_name memnm, 
        SUM(c.prod_price * a.cart_qty) price
 FROM cart a, member b, prod c
 WHERE c.prod_id = a.cart_prod AND
       b.mem_id = a.cart_member
GROUP BY a.cart_member, b.mem_name
ORDER BY price DESC) f
WHERE ROWNUM = 1;



 
 
 
 
 