--1. List the employee details of the most frequently distributed salary [ Salary Mode ]

with sal_mod as
    (
    select 
    count(salary) over(partition by salary order by salary) sal_rank, salary
    from employees
    )
select * from sal_mod
    where sal_rank= 
    (select max(sal_rank) from sal_mod);

--2. In a single row, Select the name and the hire_date of employees who were hired immediatly before and after 'John Chen', 
--	the returned row should also contain 'John Chen'

with hiring as(
    select
    first_name ||' '||last_name as emp_name,
    lag(first_name) over (order by hire_date) as prev_hire,
    lag(hire_date) over (order by hire_date) as prev_date,
    lead(first_name) over (order by hire_date) as nxt_hire,
    lead(hire_date) over (order by hire_date) as nxt_date,
    hire_date
    from employees
    )
select * from hiring
where emp_name= 'John Chen';

--3. For all those employees whose salary is below their departments average salary, list the employee details,
--	salary and the proposed salary increase in Percentage required to match the respective average.

with avg_sal as(
    select
    first_name, last_name, salary,
    round(avg(salary) over(partition by department_id),2) as avg_sal_dpt,
    round(((avg(salary) over(partition by department_id)- salary)/salary)*100, 2) || '%' as sal_inc_perc
    from employees
    )
select * from avg_sal
where salary<avg_sal_dpt
order by salary desc;


--4. List the employee name, department_name,salary , city and country_name

select first_name || ' ' || last_name as employee_nane,d.department_name,e.salary,c.country_name,l.city
from employees e
join departments d
on e.department_id=d.department_id
join locations l
on l.location_id=d.location_id
join countries c
on c.country_id=l.country_id;

select first_name || ' '|| last_name as employee_name, d.department_name, e.salary, l.city, c.country_name
from employees e, departments d, locations l, countries c
where e.department_id=d.department_id
and d.location_id=l.location_id
and l.country_id=c.country_id;

--5. SQL Clauses: List with a copy the details of the employee identified by first_name=Neena , last_name=Kochhar

select * from employees
where first_name like 'Neena'
and last_name like 'Kochhar';

--6. List employees details while sorted by the salary starting from the smallest to the highest , while at the same time keeping 
--	the President ,Administration Vice President first and second respectively. [ Do not hardcode the job_id ]

select e.* from employees e
join jobs j on e.job_id=j.job_id
order by
    case when job_title='President' then 1
    when job_title='Administration Vice President' then 2
    else 3 end,
salary;

--7. Windows analytics: For all those department with more than one employees , list the second highest salary earner per department including the ties. 
					-- [ Incase there is no second highest earner do not list ]
                     
with sal_dpt as
    (
    select first_name,last_name,salary,department_id,
    dense_rank() over(partition by department_id order by salary) salo,
    count(employee_id) over (partition by department_id) count
    from employees
    )
select first_name,last_name,salary,department_id
from sal_dpt
where salo=2 and count>1;

--8. List the name[First_Name , Last_name ] of the managers

select first_name,last_name
from employees
where employee_id in (select distinct manager_id from employees);