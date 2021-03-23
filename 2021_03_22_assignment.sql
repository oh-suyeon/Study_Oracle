-- join 8
SELECT r.region_id, r.region_name, c.country_name
FROM countries c, regions r
WHERE r.region_id = c.region_id AND r.region_name = 'Europe';

-- join 9
SELECT r.region_id, r.region_name, c.country_name, l.city
FROM countries c, regions r, locations l
WHERE r.region_id = c.region_id AND 
        c.country_id = l.country_id AND
        r.region_name = 'Europe';

-- join 10
SELECT r.region_id, r.region_name, c.country_name, l.city, d.department_name
FROM countries c, regions r, locations l, departments d
WHERE  r.region_id = c.region_id AND 
        c.country_id = l.country_id AND
        l.location_id = d.location_id AND
        r.region_name = 'Europe';

-- join 11
SELECT r.region_id, r.region_name, c.country_name, l.city, d.department_name, e.first_name || e.last_name name
FROM countries c, regions r, locations l, departments d, employees e
WHERE  r.region_id = c.region_id AND 
        c.country_id = l.country_id AND
        l.location_id = d.location_id AND
        d.department_id = e.department_id AND
        r.region_name = 'Europe';
        
-- join 12
SELECT e.employee_id, e.first_name || e.last_name name, j.job_id, j.job_title
FROM employees e, jobs j
WHERE j.job_id = e.job_id;

-- join 13
SELECT m.employee_id mgr_id, m.first_name || m.last_name mgr_name, e.employee_id, e.first_name || e.last_name name, j.job_id, j.job_title
FROM employees e, employees m, jobs j
WHERE m.employee_id = e.manager_id AND j.job_id = e.job_id;
