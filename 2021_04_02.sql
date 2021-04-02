-- 시퀀스 
CREATE SEQUENCE 시퀀스명
 [START WITH n]
 [INCREMENT BY n]
 {MAXVALUE n | NOMAXVALUE}
 [MINVALUE n | NOMINVALUE]
 [CYCLE | NOCYCLE]
 [CACHE n | NOCACHE]
 [ORDER | NOORDER]
 
 SELECT *
 FROM lprod;
 
 -- 사용 예 : lprod 테이블에 다음 자료를 삽입하시오(단, 시퀀스를 이용하시오)
 -- lprod_id : 10번부터
 -- lprod_gu : p501,    p502,   p503
 -- lprod_nm : 농산물,   수산물,  임산물
 
 --1. 시퀀스 생성
 CREATE SEQUENCE seq_lprod
    START WITH 10; 

 SELECT seq_lprod.CURRVAL -- sequence SEQ_LPROD.CURRVAL is not yet defined in this session
 FROM dual; -- 참조포인터가 아직 만들어지지 않았음 (참고. 자료구조 linked list)
 
  --2. 자료 삽입 
  INSERT INTO lprod VALUES(seq_lprod.NEXTVAL, 'P501', '농산물');
  
  SELECT * 
  FROM lprod;
  
  -- 사용예 2) 오늘은 2005년 7월 28일. m001회원이 제품 p201000004을 5개 구입. cart테이블에 해당 자료 삽입하는 쿼리 작성
  -- 먼저 날짜를 2005년 7월 28일로 변경 후 작성할 것.
  -- 판매한 걸 적어넣는 게 cart 테이블. 그 다음에 해야 할 건. 실시간으로, 자동으로 재고 조정. --> 트리거 (이벤트가 발생했을 때 수행해야 할 쿼리를 자동으로 수행해준다.) 
  
SELECT *
FROM cart;  -- 로그인한 순간 카트(년,월,일,로그인순을 문자열 변환해 붙였다)를 한 개씩 부여한다. 카트 한개에는 여러 상품을 담을 수 있고, 그걸 한꺼번에 결제한다. (부분 취소가 거의 안 된다.)
            -- 카트번호 하나로 여러 상품을 관리하니까 힘들다. 
            -- 단가가 없다. 단가는 prod 테이블을 조인해서 가져오고, sum으로 결제 금액을 계산한다. 
            
  -- 1. cart_no생성. m001은 사이트에 온 5번째 사람. 카트 번호는 2005072700005다.
  SELECT TO_CHAR(TO_CHAR(SYSDATE, 'yyyymmdd') ||
        MAX(SUBSTR(cart_no, 9)) + 1)
  FROM cart;
  
  SELECT TO_CHAR(MAX(cart_no) + 1) -- 자바는 결합(연산) 시 숫자보다 문자열이 우선이지만, sql에서는 숫자가 우선이다. cart_no가 문자열에서 숫자로 자동 형변환되었다. 
  FROM cart;
  
  -- 지금은 변수를 못 쓰니까 복잡하지만. 
  -- 순번 확인하고
  SELECT MAX(SUBSTR(cart_no, 9)) 
  FROM cart;
  
  -- 시퀀스 객체 생성
  CREATE SEQUENCE sql_cart
   START WITH 5;
 
 DELETE cart
  WHERE cart_no = '200507285'; --> 잘못만들었던 행을 한번 지웠기 때문에 5번은 건너뛰고 6번이 부여된다. 
   
 INSERT INTO cart(cart_member, cart_no, cart_prod, cart_qty)
    VALUES('m001', (TO_CHAR(SYSDATE, 'yyyyddmm') || 
        TRIM(TO_CHAR(sql_cart.NEXTVAL, '00000'))), 'P201000004', 5) -- 공백이 끼지 않도록 TRIM.
  
  SELECT *
  FROM user_sequences;
  
  --SYNONYM 객체
  
  -- 사용예 ) HR계정의 REGIONS테이블의 내용을 조회
  
  SELECT hr.regions.region_id 지역코드, 
         hr.regions.region_name 지역명
    FROM hr.regions;
    
    (테이블 별칭을 사용한 경우)
    SELECT a.region_id 지역코드, 
         a.region_name 지역명
    FROM hr.regions a;
   
   (동의어를 사용한 경우)
   CREATE OR REPLACE SYNONYM reg FOR HR.REGIONS;
   SELECT region_id 지역코드, 
          region_name 지역명
    FROM reg;
    
    
    -- INDEX 객체
    
    SELECT *
    FROM emp;
    
    