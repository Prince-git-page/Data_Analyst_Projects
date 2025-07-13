-- 1.	Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv into the employee database from the given resources. 

create database employee;
use employee;

-- 2.	Create an ER diagram for the given employee database.
alter table proj_table modify PROJECT_ID varchar(50) ;
alter table proj_table 
add primary key(PROJECT_ID);
create index primary_idx on proj_table (PROJECT_ID(50));


-- 3.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of employees and details of their department.

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT from emp_record_table;

/*
4.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
●	less than two
●	greater than four 
●	between two and four
*/

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where  EMP_RATING between 2 and 4 ;

-- 5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and then give the resultant column alias as NAME.

select EMP_ID, FIRST_NAME, LAST_NAME, DEPT, concat(FIRST_NAME," ",LAST_NAME) as 'NAME'
from emp_record_table
where DEPT='finance';

-- 6.	Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).
use employee;
select e.EMP_ID as 'Manager_ID',count(e.EMP_ID) as 'NumberOfReportees'
from 
    emp_record_table e
        JOIN
    emp_record_table m ON e.EMP_ID = m.MANAGER_ID
    group by 1
    order by 1;
    
    -- 7.	Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.
    
    SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM
    emp_record_table
WHERE
    dept = 'HEALTHCARE' 
UNION SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM
    emp_record_table
where dept ='FINANCE'
order by 4;

-- 8.	Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. Also include the respective employee rating along with the max emp rating for the department.

select EMP_ID,FIRST_NAME,LAST_NAME,ROLE,DEPT,EMP_RATING,max(EMP_RATING) over (partition by DEPT)
from emp_record_table;

-- 9.	Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.

select EMP_ID,FIRST_NAME,LAST_NAME,ROLE,DEPT,SALARY,min(SALARY) over (partition by ROLE) as 'Min_Salary',max(SALARY) over (partition by ROLE) as 'Max_Salary'
from emp_record_table;

-- 10.	Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.

select EMP_ID,FIRST_NAME,LAST_NAME,ROLE,DEPT,EXP,dense_rank() over (partition by dept order by EXP desc) as 'Emp_rank'
from emp_record_table;

-- 11.	Write a query to create a view that displays employees in various countries whose salary is more than six thousand. Take data from the employee record table.

create view emp_sal 
as
select * from emp_record_table where SALARY>6000;

select * from emp_sal;

-- 12.	Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.

SELECT 
    *
FROM
    emp_record_table
WHERE
    emp_id IN (SELECT 
            emp_id
        FROM
            emp_record_table
        WHERE
            exp > 10);
            
-- 13.	Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. Take data from the employee record table.

delimiter //
create procedure experience(in ex int)
begin
select * from emp_record_table where exp > ex;
end //
delimiter ;

call experience(3);

use employee;


/* 
14.	Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard.

The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.
*/
use employee;
delimiter //
create function emp_exp(exp int)
returns varchar(50)
deterministic
begin
declare emp_label varchar(50) default '';
if exp<=2 then set emp_label='JUNIOR DATA SCIENTIST';
elseif exp > 2 and exp <= 5 then set emp_label='ASSOCIATE DATA SCIENTIST';
elseif exp > 5 and exp <= 10 then set emp_label='SENIOR DATA SCIENTIST';
elseif exp > 10 and exp <= 12 then set emp_label='LEAD DATA SCIENTIST';
else set emp_label='MANAGER';
end if;
return emp_label;
end //
delimiter ;

select emp_id, exp, emp_exp(EXP) from data_science_team;

-- 15.	Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.

create index idx_name on 
emp_record_table(FIRST_NAME(50));
select * from emp_record_table where FIRST_NAME='eric';

-- 16.	Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).

select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, SALARY, EMP_RATING, (round(0.05*salary*emp_rating,2)) as 'BONUS'
from emp_record_table;

-- 17.	Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY, round(avg(salary) over (partition by COUNTRY, CONTINENT),2) as 'Avg_salary'
from emp_record_table;