-- 커서 예제
SET SERVEROUTPUT ON;
DECLARE
    CURSOR emp_cur
    IS
    SELECT *
    FROM emp
    WHERE deptno = 10;
    
    emp_rec emp%ROWTYPE;

BEGIN 
    OPEN emp_cur;
    LOOP
        FETCH emp_cur INTO emp_rec;
        EXIT WHEN emp_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(emp_rec.empno || ' ' || emp_rec.ename);
        
    END LOOP;
    CLOSE emp_cur;
    
END;

-- 

SET SERVEROUTPUT ON;
DECLARE
    CURSOR id_list IS
    SELECT 'GOD' AS user_id FROM dual;
BEGIN 
    FOR test_cursor IN id_list
    LOOP
        DBMS_OUTPUT.PUT_LINE(test_cursor.user_id);
    END LOOP;
END;

---

DECLARE
    v_mid   v_maxamt.memid%TYPE;
    v_name  v_maxamt.memnm%TYPE;
    v_amt   v_maxamt.price%TYPE;
    v_res   VARCHAR2(100);
    
BEGIN
    SELECT memid, memnm, price
    INTO v_mid, v_name, v_amt
    FROM v_maxamt;
    
    v_res := v_mid || v_name || ', ' || TO_CHAR(v_amt, '99,999,999');
    DBMS_OUTPUT.PUT_LINE(v_res);

END;

-- 

ACCEPT p_num PROMPT '원의 반지름 입력하쇼'

DECLARE
    v_radius    NUMBER := TO_NUMBER('&p_num');
    v_pi        CONSTANT NUMBER := 3.14;
    v_res       NUMBER := 0;
    
BEGIN
    v_res := v_radius * v_radius * v_pi;
    DBMS_OUTPUT.PUT_LINE(v_res);
END;

--
DECLARE
    v_pid   prod.prod_id%TYPE;
    v_pnm   prod.prod_name%TYPE;
    v_buyer buyer.buyer_name%TYPE;
    v_amt   NUMBER := 0;
    
    CURSOR cur_buy_amt IS
        SELECT buy_prod, SUM(buy_qty) amt
        FROM buyprod
        WHERE buy_date BETWEEN '20050301' AND LAST_DAY(TO_DATE('20050301', 'yyyymmdd'))
        GROUP BY buy_prod;
        
BEGIN
    OPEN cur_buy_amt;
    
    LOOP 
    FETCH cur_buy_amt INTO v_pid, v_amt;
    EXIT WHEN cur_buy_amt%NOTFOUND;
    
    SELECT prod_name, buyer_name INTO v_pnm, v_buyer
    FROM prod, buyer
    WHERE prod_id = v_pid
        AND prod_buyer = buyer_id;
    
    DBMS_OUTPUT.PUT_LINE(v_pid + ' ' + v_pname + ' ' + v_buyer + ' ' + v_amt);
    
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(cur_buy_amt%ROWCOUNT);
    CLOSE cur_buy_amt;
    
END;
    

