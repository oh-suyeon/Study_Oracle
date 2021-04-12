 CREATE TABLE order_list(
    order_date  CHAR(8),
    product     VARCHAR2(10),
    qty         NUMBER NOT NULL,
    amount      NUMBER NOT NULL
 );
 
 CREATE TABLE sales_per_date(
    sales_date  CHAR(8),
    product     VARCHAR2(10),
    qty         NUMBER NOT NULL,
    amount      NUMBER NOT NULL
 );
 
 CREATE OR REPLACE TRIGGER tg_summary_sale
    AFTER INSERT ON order_list
    FOR EACH ROW
 DECLARE 
    o_date  order_list.order_date%TYPE;
    o_prod  order_list.product%TYPE;
 BEGIN 
    o_date  := :new.order_date;
    o_prod  := :new.product;
    
    UPDATE sales_per_date 
        SET qty = qty + :new.qty,
            amount = amount + :new.amount
        WHERE sales_date = o_date AND
              product = o_prod;
    IF SQL%NOTFOUND THEN
        INSERT INTO sales_per_date
            values(o_date, o_prod, :new.qty, :new.amount);
    END IF;
 END;
 
 INSERT INTO order_list 
 VALUES ('20120901', 'MULTIPACK', 10, 300000);
 
 INSERT INTO order_list
 VALUES ('20120901', 'MONOPACK', 20, 600000);
    
 SELECT *
 FROM order_list;
 
 SELECT *
 FROM sales_per_date;
 commit;
 rollback;
 
 -------------------
  
 CREATE OR REPLACE TRIGGER tg_lprod_insert2
    AFTER INSERT ON lprod
 BEGIN
    DBMS_OUTPUT.PUT_LINE('행이 삽입되었습니다.');
 END;
 
 INSERT INTO lprod VALUES (12, 'P701', '수산물');
 
 SELECT *
 FROM lprod;
 commit;
 
 DELETE FROM lprod
    WHERE lprod_id > 10;
 
 ----------------------
 SELECT *
 FROM cart;
 
 SELECT *
 FROM remain;
 
 DROP TRIGGER tg_remain_cart_upate;
 
 CREATE OR REPLACE TRIGGER tg_remain_cart_update
    AFTER INSERT OR UPDATE OR DELETE ON cart
    FOR EACH ROW
 DECLARE
    v_qty   cart.cart_qty%TYPE;
    v_prod  cart.cart_prod%TYPE;
 BEGIN
    IF INSERTING THEN
        v_qty := :new.cart_qty;
        v_prod := :new.cart_prod;
    ELSIF UPDATING THEN
        v_qty := :new.cart_qty - :old.cart_qty;
        v_prod := :old.cart_prod;   -- (??) OLD, NEW 결과는 똑같다. (있는 상품 정보를 수정하는 거니까 OLD가 맞지 않나?)
    ELSE 
        v_qty := -(:old.cart_qty);
        v_prod := :old.cart_prod;
    END IF;
    
    UPDATE remain
    SET remain_o = remain_o + v_qty,
        remain_j_99 = remain_j_99 - v_qty,
        remain_date = SYSDATE
    WHERE prod_id = v_prod AND
          remain_year = '2005';
          
    DBMS_OUTPUT.PUT_LINE('재고수량이 변동되었습니다.');
    
 END;
 
 INSERT INTO cart VALUES ('a001', '2021041200002', 'P101000003', 5);
 INSERT INTO cart VALUES ('a001', '2021041200002', 'P101000001', 5);
 
 UPDATE cart 
 SET cart_qty = 15
 WHERE cart_no = '2005040100001' AND
       cart_prod = 'P101000001';
  
 SELECT *
 FROM cart
 WHERE cart_member = 'a001';
 
 SELECT *
 FROM remain;
 
 rollback;
 commit;
 