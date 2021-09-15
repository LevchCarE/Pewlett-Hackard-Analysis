
SELECT * FROM departments LIMIT 10 ;

SELECT * FROM employees LIMIT 10 ;

SELECT * FROM salaries LIMIT 10 ;

SELECT * FROM titles LIMIT 10 ;

SELECT * FROM dept_manager LIMIT 10 ;

SELECT * FROM managers LIMIT 10 ;

--queries
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

--birthday only 1952
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

--birthday only 1953
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

--birthday only 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

--birthday only 1955
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--create table retirement_info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;


-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT departments.dept_name,
     dept_manager.emp_no,
     dept_manager.from_date,
     dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no,
    retirement_info.first_name,
     retirement_info.last_name,
    dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;

--shortening previous code
SELECT ri.emp_no,
    ri.first_name,
	ri.last_name,
    de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

-- shortening inner join code 
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

--Use Left Join for retirement_info and dept_emp tables
SELECT ri.emp_no,
    ri.first_name,
    ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

DROP TABLE current_emp;

select * from current_emp;

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO count_emp_by_dep
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;


SELECT * FROM salaries
ORDER BY to_date DESC;


-- Create emp_info table with full name, gender, salary, to_date
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
INNER JOIN salaries AS s
ON e.emp_no = s.emp_no
INNER JOIN dept_emp as de
ON e.emp_no = de.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
------DEPT_INFO		
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);	


-- Create retirement_info list for sales team
SELECT ri.*, d.dept_name
-- INTO sales_info
FROM retirement_info as ri
	INNER JOIN dept_emp AS de
		ON ri.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Sales';

-- Create retirement_info list for sales and development team
SELECT ri.*, d.dept_name
-- INTO sales_dev_info
FROM retirement_info as ri
	INNER JOIN dept_emp AS de
		ON ri.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
WHERE d.dept_name IN ('Sales', 'Development');

-- challenge


----------------------------------------------------retirement_titles

SELECT e.emp_no, 
	e.first_name, 
	e.last_name,
	tl.title,
	tl.from_date,
	tl.to_date
-- INTO retirement_titles
FROM employees AS e
INNER JOIN titles AS tl
ON e.emp_no = tl.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;

---------------------------------------------- Use Dictinct with Orderby to remove duplicate rows; unique_titles

SELECT DISTINCT ON (rt.emp_no) rt.emp_no,
					rt.first_name,
					rt.last_name,
					rt.title
-- INTO unique_titles
FROM retirement_titles AS rt
ORDER BY rt.emp_no, rt.to_date DESC;


--------------------------------retiring_titles

SELECT COUNT(ut.title), ut.title
--INTO retiring_titles
FROM unique_titles AS ut
GROUP BY ut.title
ORDER BY ut.count DESC;


------------------------------------------mentorship_eligibility

SELECT 	DISTINCT ON(e.emp_no) e.emp_no, 
		e.first_name, 
		e.last_name,  
		e.birth_date,
		de.from_date, 
		de.to_date,
		tl.title
--INTO mentorship_eligibility
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN titles AS tl
		ON e.emp_no = tl.emp_no
WHERE de.to_date = '9999-01-01'
AND e.birth_date BETWEEN '1965-01-01' AND '1965-12-31'
ORDER BY e.emp_no;