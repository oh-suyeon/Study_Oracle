 ACCEPT p_num PROMPT '수 입력(2~9) : '
 
 DECLARE
    v_base NUMBER := TO_NUMBER('&p_num');
    v_cnt NUMBER := 0;
    v_res NUMBER := 0;
    
 BEGIN 
    LOOP 
    
        v_cnt := v_cnt + 1;
        EXIT WHEN v_cnt > 9;
        v_res := v_base * v_cnt;
    
        DBMS_OUTPUT.PUT_LINE(v_base || '*' || v_cnt || '=' || v_res);
    END LOOP;
    
    EXCEPTION WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('예외 발생 : ' || SQLERRM);
END;

DECLARE
    ex_num CONSTANT NUMBER := 10;
    ex_str VARCHAR2(10);
    
BEGIN 
    ex_str := 'EXAPLE';
    DBMS_OUTPUT.PUT_LINE(ex_num);
    DBMS_OUTPUT.PUT_LINE(ex_str);
END;

DECLARE 
    vn_num NUMBER := 1;
    vn_num2 NUMBER := 2;
    
BEGIN 
    DBMS_OUTPUT.PUT_LINE(vn_num + vn_num2);

END;

DECLARE
    score NUMBER := 80;
    
BEGIN 
    IF score >= 90 THEN
        DBMS_OUTPUT.PUT_LINE('A등급');
    ELSE IF score >= 80 THEN
        DBMS_OUTPUT.PUT_LINE('B등급');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('C등급');
    END IF;

END;


ACCEPT num1 PROMPT '정수 입력 : '

DECLARE
    v_num NUMBER := 0;
    v_message VARCHAR2(100);
    
BEGIN
    v_num := TO_NUMBER('&num1');
    
    IF MOD(v_num, 2) = 0 THEN
        v_message := v_num || '은 짝수당';
    ELSE 
        v_message := v_num || '은 홀수당';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_message);

END;
    
-- 커서를 사용하는 법을 몰라서 이해가 안 된다. 
ACCEPT p_job PROMPT '직업 입력 > '

DECLARE 
    v_name member.mem_name%TYPE;
    v_id member.mem_id%TYPE;
    v_mile member.mem_mileage%TYPE;
    CURSOR cur_mem(v_job member.mem_job%TYPE)
    IS
        SELECT mem_id, mem_name, mem_mileage
            FROM member
        WHERE mem_job = v_job;
BEGIN 
    OPEN cur_mem('&a_job');
        LOOP
            FETCH cur_mem INTO v_id, v_name, v_mile;
            
            EXIT WHEN cur_mem%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_id || ', ' || v_name || ', ' || v_mile);
        END LOOP;
    CLOSE cur_mem;
END;
 
 
DECLARE
    v_name      employees.emp_name%TYPE;
    v_dept_id   departments.department_id%TYPE;
    v_dept_name departments.department_name%TYPE;
    v_sal       employees.salary%TYPE;
    v_remarks   VARCHAR2(50);
    
BEGIN 
    v_dept_id := ROUND(DBMS_RANDOM.VALUE(10, 110) - 1);
    
    SELECT a.emp_name, b.department_name, a.salary
            INTO v_name, v_dept_name, v_sal
    FROM employees a, departments b
    WHERE a.department_id = b.department_id
        AND a.department_id = v_dept_id
        AND ROWNUM = 1;
    
    IF v_sal BETWEEN 1 AND 2999 THEN
        v_remarks := '낮은 임금';
    ELSE IF v_sal BETWEEN 3000 AND 6000 THEN
        v_remarks := '보통 임급';
    ELSE
        v_remarks := '높은 임금';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_name || ', ' || v_dept_name || ', ' || v_sal || '=>' || v_remarks);
    
END;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    