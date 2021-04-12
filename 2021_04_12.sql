-- 트리거 

-- 문장단위 트리거 사용예 ) 
-- 상품분류테이블에 자료를 삽입하기. 자료 삽입 후 '상품분류코드가 추가되었습니다.' 메시지 출력
-- lprod_gu : 'P601' 
-- lprod_nm : '신선식품'

CREATE OR REPLACE TRIGGER tg_lprod_insert   
    AFTER INSERT ON lprod
BEGIN      
    DBMS_OUTPUT.PUT_LINE('상품분류코드가 추가되었습니다.');
END;

INSERT INTO lprod
       VALUES ('11', 'P601', '신선식품');

SELECT *        -- 새로고침 개념으로, commit 해줘야 트리거 결과가 보여진다. 
FROM lprod;


-- 행 단위 트리거 사용예) buyprod테이블에서 2005년 4월 16일 상품 'P101000001'(210000원) 
-- 5개를 매입한 다음 remain의 재고수량을 UPDATE하시오 

CREATE OR REPLACE TRIGGER tg_remain_update
    AFTER INSERT OR UPDATE OR DELETE        -- 어떤 이벤트가 발생할지 잘 모르겠다면 OR로 연결해서 나열할 수 있다. 
    ON buyprod      --제품의 매입정보가 저장되는 곳. 매출정보가 저장되는 cart와 반대된다. 
    FOR EACH ROW
BEGIN
    UPDATE remain SET
        (remain_i, remain_j_99, remain_date) = 
        (SELECT remain_i +:new.buy_qty, remain_j_99 +:new.buy_qty, TO_DATE('20050416') -- 없는 값을 새로 삽입하는 거니까 new를 붙인다 / 삭제, 수정이라면 존재하는 값을 조정하는 거니까 old
         FROM remain 
         WHERE remain_year = '2005' AND 
               prod_id =:new.buy_prod)
    WHERE remain_year = '2005' AND 
          prod_id =:new.buy_prod;
END;

INSERT INTO buyprod 
    VALUES (TO_DATE('20050416'), 'P101000001', 5, 210000);

SELECT *
FROM remain;
DESC remain;
SELECT *
FROM buyprod;

-- 트리거함수 사용예) 장바구니 테이블에 신규 판매자료가 삽입될때 재고를 처리하는 트리거를 작성하시오.

CREATE OR REPLACE TRIGGER tg_remain_cart_upate
    AFTER INSERT OR UPDATE OR DELETE ON cart
    FOR EACH ROW
DECLARE 
    v_qty   cart.cart_qty%TYPE;
    v_prod  cart.cart_prod%TYPE;
BEGIN
    IF INSERTING THEN
        v_qty := :NEW.cart_qty;
        v_prod := :NEW.cart_prod;
    ELSIF UPDATING THEN
        v_qty := :NEW.cart_qty - :OLD.cart_qty;
        v_prod := :NEW.cart_prod;
    ELSE 
        v_qty := -(:OLD.cart_qty);      -- 이만큼을 없애야 하니까 음수로 만든다. 
        v_prod := :OLD.cart_prod;
    END IF;

    UPDATE remain 
    SET remain_o = remain_o + v_qty,
        remain_j_99 = remain_j_99 - v_qty,
        remain_date = SYSDATE
    WHERE prod_id = v_prod AND
          remain_year = '2005';
    
    DBMS_OUTPUT.PUT_LINE(v_prod || '상품 재고수량 변동');
END;    

SELECT *
FROM remain;
SELECT *
FROM cart;
SELECT *
FROM cart
WHERE cart_no = '2021041200001';

-- INSERT event -- :NEW / :NEW
INSERT INTO cart VALUES ('a001', '2021041200001', 'P101000003', 5); 

-- UPDATE event -- :NEW / :OLD
UPDATE cart 
    SET cart_qty = 7
WHERE cart_no = '2021041200001'
  AND cart_prod = 'P101000003';

-- DELETE event -- :OLD / :OLD
DELETE FROM cart 
    WHERE cart_no = '2021041200001' AND
          cart_prod = 'P101000003';




-- 문제) 'f001' 회원이 오늘 상품 'P202000001'을 15개 구매했다. 
--       이 정보를 cart테이블에 저장한 후 재고수불 테이블과 회원테이블(마일리지)를 변경하는 트리거를 작성하기

UPDATE prod 
    SET prod_mileage = round(prod_price * 0.001);
commit;

SELECT *
FROM cart;

-- 2. 카트에 회원 구매 정보 INSERT
INSERT INTO cart 
    VALUES ('f001', '2021041200001', 'P202000001', 15);
    
-- 1. remain(remain_0, remain_j_99), member(mem_mile) 데이터 UPDATE할 수 있는 트리거 생성
CREATE OR REPLACE TRIGGER tg_remain_member_update
    AFTER INSERT ON cart
    FOR EACH ROW 
DECLARE
    v_prod  cart.cart_prod%TYPE;
    v_mid   cart.cart_member%TYPE;
    v_qty   cart.cart_qty%TYPE;
    v_mile  prod.prod_mileage%TYPE;
BEGIN
    v_prod   := :NEW.cart_prod;
    v_qty    := :NEW.cart_qty;
    v_mid    := :NEW.cart_member;
    
    UPDATE remain SET 
         remain_o = remain_o + v_qty,
         remain_j_99 = remain_j_99 - v_qty,
         remain_date = TO_DATE('20210412')
    WHERE 
         prod_id = v_prod AND
         remain_year = '2005';
        
    DBMS_OUTPUT.PUT_LINE(v_prod || '/' || v_qty);
        
    SELECT prod_mileage INTO v_mile
    FROM prod
    WHERE prod_id = v_prod;
    
    UPDATE member SET
         mem_mileage = mem_mileage + v_mile
    WHERE mem_id = v_mid;
    
    DBMS_OUTPUT.PUT_LINE(v_mid || '/' || v_mile);
    
END;

SELECT mem_mileage
FROM member
WHERE mem_id = 'f001';

SELECT *
FROM remain
WHERE prod_id = 'P202000001';

rollback;
commit;











