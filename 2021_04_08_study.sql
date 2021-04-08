 --저장프로시저&커서&반복문

CREATE OR REPLACE PROCEDURE proc_remain_test_in_2 (
    p_code  remain_test.prod_id%TYPE,  
    p_cnt   NUMBER)
IS
BEGIN
    UPDATE remain_test 
        SET (remain_i, remain_j_99, remain_date) = 
            (SELECT remain_i + p_cnt, remain_j_99 + p_cnt, TO_DATE('20050130') 
             FROM remain_test
             WHERE prod_id = p_code AND remain_year = '2005')
    WHERE prod_id = p_code AND remain_year = '2005';
END;

DECLARE
BEGIN
    FOR rec04 IN (SELECT buy_prod, SUM(buy_qty) amt
                  FROM buyprod
                  WHERE buy_date BETWEEN '20050101' AND '20050130'
                  GROUP BY buy_prod)
    LOOP
        proc_remain_test_in_2(rec04.buy_prod, rec04.amt);
    END LOOP;
END;

SELECT *
FROM remain_test;

CREATE OR REPLACE VIEW v_remain_test_1
AS
    SELECT *
    FROM remain_test
WITH READ ONLY;

CREATE OR REPLACE VIEW v_remain_test2
AS
    SELECT *
    FROM remain_test;

SELECT *
FROM v_remain_test_1;

SELECT *
FROM v_remain_test2;

----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE proc_mem_info2 (
    p_id    IN member.mem_id%TYPE,
    p_name  OUT member.mem_name%TYPE,
    p_addr  OUT VARCHAR2,
    p_job   OUT member.mem_job%TYPE)
IS
BEGIN
    SELECT mem_name, mem_add1 || '' || mem_add2, mem_job
      INTO p_name, p_addr, p_job
    FROM member 
    WHERE p_id = mem_id;
END;

ACCEPT p_mid PROMPT '아이디입력'
DECLARE
    v_name  member.mem_name%TYPE;
    v_addr  VARCHAR2(200);
    v_job   member.mem_job%TYPE;
BEGIN
    proc_mem_info2(LOWER('&p_mid'), v_name, v_addr, v_job);
    DBMS_OUTPUT.PUT_LINE('회원이름 : ' || v_name);
    DBMS_OUTPUT.PUT_LINE('회원주소 : ' || v_addr);
    DBMS_OUTPUT.PUT_LINE('회원직업 : ' || v_job);
END;

--------------------------------------------------------------------------------------------

SELECT *
FROM prod;

SELECT *
FROM cart;

SELECT m.mem_name, a.amt
FROM 
    (SELECT c.cart_member, SUM(c.cart_qty * p.prod_price) amt
     FROM cart c, prod p
     WHERE c.cart_prod = p.prod_id AND
           SUBSTR(c.cart_n, 1, 4) = '2005'
     GROUP BY c.cart_member
     ORDER BY amt DESC) a, member m
WHERE ROWNUM = 1 AND
      m.mem_id = a.cart_member;
      
CREATE OR REPLACE PROCEDURE proc_mem_ptop2 (
    p_year  IN VARCHAR2,
    p_name  OUT member.mem_name%TYPE,
    p_amt   OUT NUMBER)
IS
BEGIN
    SELECT m.mem_name, a.amt
      INTO p_name, p_amt
      FROM 
          (SELECT c.cart_member, SUM(c.cart_qty * p.prod_price) amt
             FROM cart c, prod p
            WHERE c.cart_prod = p.prod_id AND
                 SUBSTR(c.cart_n, 1, 4) = p_year
            GROUP BY c.cart_member
            ORDER BY amt DESC) a, member m
     WHERE ROWNUM = 1 AND
          m.mem_id = a.cart_member;
END;

ACCEPT p_y PROMPT '년도 입력'
DECLARE    
    v_name  member.mem_name%TYPE;
    v_amt   NUMBER := 0;
BEGIN
    PROC_MEM_ptop('&p_y', v_name, v_amt);
    DBMS_OUTPUT.PUT_LINE('회원이름 : ' || v_name);
    DBMS_OUTPUT.PUT_LINE('구매총액 : ' || LTRIM(TO_CHAR(v_amt, '99,999,999')));
END;

-----------------------------------------------------------------

SELECT m.mem_id, SUM(c.cart_qty)
FROM cart c, member m
WHERE m.mem_id = c.cart_member(+) AND
      SUBSTR(c.cart_no, 1, 4) = '2005'
GROUP BY m.mem_id
HAVING SUM(c.cart_qty) IS NULL;

SELECT m.mem_id, SUM(c.cart_qty)
FROM cart c, member m
WHERE m.mem_id = c.cart_member(+)
GROUP BY m.mem_id, c.cart_no
HAVING SUM(c.cart_qty) IS NULL;

CREATE OR REPLACE PROCEDURE proc_mem_delete (
    p_mid IN member.mem_id%TYPE)
IS
BEGIN
    UPDATE member SET 
        mem_delete = 'Y'
    WHERE p_mid = mem_id;
END;

DECLARE
BEGIN
    FOR rec5 IN (SELECT m.mem_id mid, SUM(c.cart_qty) qyt
                 FROM cart c, member m
                 WHERE m.mem_id = c.cart_member(+)
                 GROUP BY m.mem_id, c.cart_no
                 HAVING SUM(c.cart_qty) IS NULL)
    LOOP
        proc_mem_delete(rec5.mid);
    END LOOP;
END;

SELECT *
FROM member;

