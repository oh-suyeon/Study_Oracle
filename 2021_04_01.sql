-- view
 
-- 사용 예) 사원 테이블에서 부모 부서 코드가 90번 부서에 속한 사원정보를 조회
--         조회항 데이터 : 사원번호, 사원명, 부서명, 급여
 
-- 사용 예) 회원 테이블에서 마일리지가 3000이상인 회원의 회원번호, 회원명, 직업, 마일리지 조회
 
SELECT *
FROM member;

SELECT mem_id 회원번호, 
       mem_name 회원명, 
       mem_job 직업, 
       mem_mileage 마일리지 
 FROM member
WHERE mem_mileage >= 3000;

--> 뷰 생성 일반적으로 V_를 붙인다. (system 계정에 접속해서 djs02061에게 생성 권한을 줘야 한다. GRANT DBA...)
CREATE OR REPLACE VIEW V_MEMBER01 
AS
  SELECT mem_id 회원번호, 
        mem_name 회원명, 
        mem_job 직업, 
        mem_mileage 마일리지 
 FROM member
WHERE mem_mileage >= 3000;

SELECT * 
FROM V_MEMBER01;

-- 원본 테이블과 비교
SELECT MEM_NAME, MEM_JOB, MEM_MILEAGE
 FROM member
WHERE UPPER(MEM_ID) = 'C001';   -- 대소문자를 모를때

-- 원본 테이블에서 신용환 마일리지를 10000으로 변경 --> 뷰의 정보도 업데이트된다. (즉각 연동)
UPDATE member SET mem_mileage = 10000
WHERE MEM_NAME = '신용환';

-- 뷰에서 신용환의 마일리지를 500으로 변경
UPDATE V_member01 SET 마일리지 = 500 -- 뷰의 컬럼명은 변경됐다. / 뷰의 마일리지 3000이상 조건에 어긋났기 때문에 사라졌다.(WITH CHECK OPTION가 있었다면 쿼리가 실행되지 않았음) / 테이블의 정보도 업데이트된다. (즉각 연동) (WITH READ ONLY를 체크했으면 변경 쿼리가 실행되지 않았음)
WHERE 회원명 = '신용환'; 

-- WITH CHECH OPTION 사용해 뷰 생성
CREATE OR REPLACE VIEW V_MEMBER01(MID, MNAME, MJOB, MILE)  -- 같은 이름을 생성하니까 REPLACE
AS
  SELECT mem_id 회원번호, 
        mem_name 회원명, 
        mem_job 직업, 
        mem_mileage 마일리지 
 FROM member
WHERE mem_mileage >= 3000
WITH CHECK OPTION;

-- 뷰에서 신용환 회원의 마일리지를 2000으로 변경  / -- 뷰에 제한 조건이 있어도, 뷰가 원본보다 중요하지 않다. 원본은 제한 없이 변경 가능하다. 
UPDATE V_MEMBER01
    SET MILE = 2000
    WHERE UPPER(MID) = 'C001'; -- ORA-01402: view WITH CHECK OPTION where-clause violation
    
-- 테이블에서 신용환 회원의 마일리지 2000으로 변경 / 가능 / 단 수정 내용은 뷰에서 사라진다. 
UPDATE member
    SET mem_mileage = 2000
    WHERE UPPER(mem_id) = 'C001';
    
-- WITH READ ONLY 사용해 뷰 생성
CREATE OR REPLACE VIEW V_MEMBER01(MID, MNAME, MJOB, MILE)  
AS
  SELECT mem_id 회원번호, 
        mem_name 회원명, 
        mem_job 직업, 
        mem_mileage 마일리지 
 FROM member
WHERE mem_mileage >= 3000
WITH READ ONLY;

SELECT *
FROM V_MEMBER01;

-- 뷰에서 오철희 마일리지를 5700으로 변경
UPDATE v_member01 SET mile = 5700
WHERE UPPER(mid) = 'K001'; -- ORA-42399: cannot perform a DML operation on a read-only view

-- 다른 계정의 테이블 조회하기
SELECT hr.departments.department_id,   -- 같은 계정 내의 테이블을 조회할 때는 department_id만 써도 된다. 원칙적으로는 '계정명.테이블명.컬럼명'이 풀네임. 
       department_name
FROM hr.departments; 


--------------------------------------------------------------------------------------------------------------------------------


-- 문제) 사원테이블(employees)에서 50번 부서의 사원 중 급여가 5000이상인 사원번호, 사원명, 입사일, 급여 읽기전용 뷰로 생성 
        --> 테이블과 뷰를 활용해 사원번호, 사원명, 직무명, 급여를 조회

SELECT *
FROM v_emp_sal01;

SELECT employee_id, emp_name, hire_date, salary     -- 조건에 맞는 사원 정보 조회
FROM employees
WHERE department_id = 50 
      AND salary >= 5000;

CREATE OR REPLACE VIEW v_emp_sal01
    AS SELECT employee_id, emp_name, hire_date, salary  -- 위의 쿼리 결과를 읽기 전용 뷰로 생성
        FROM employees
        WHERE department_id = 50 
                AND salary >= 5000
WITH READ ONLY;

SELECT v.employee_id 사원번호, v.emp_name 사원명, jobs.job_title 직무명, v.salary 급여     -- 뷰, employees 테이블, jobs테이블 JOIN하여 사원 정보 조회      
FROM v_emp_sal01 v, employees, jobs
WHERE v.employee_id = employees.employee_id AND
      employees.job_id = jobs.job_id;

-- 뷰를 만든 목적에 좀 위배된다. sql 조회할 때 빠르고 간편하게 하려고 뷰를 만든 건데 JOIN까지 한다. 
-- 나중에 배울 'CURSUR커서'(행들의 집합)를 사용하면 JOIN을 쓰지 않아도 된다. --> 각 집합에 이름이 붙지 않으면 '묵시적 커서, 익명 커서' 외부에서 접근할 수 없다. (우리가 지금까지 쓰던 것.)       
                                                            --> 이름이 붙은 '명시적 커서'는 행의 집합을 오픈, 집합 안에 있는 자료를 꺼내서 읽거나 조작할 수 있다. (오토마타 이론, 컴파일 매크로 처리. 4개의 사이클이 존재하는데, 그 중 훼치(?) 사이클.)










