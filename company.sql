/* 
Consider the schema for Company Database: 
EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) 
DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) 
DLOCATION (DNo,DLoc) 
PROJECT (PNo, PName, PLocation, DNo) 
WORKS_ON (SSN, PNo, Hours) 
Write SQL queries to 
1. Make a list of all project numbers for projects that involve an employee whose last 
name is ‘Scott’, either as a worker or as a manager of the department that controls the 
project. 
2. Show the resulting salaries if every employee working on the ‘IoT’ project is given a 
10 percent raise. 
3. Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as 
the maximum salary, the minimum salary, and the average salary in this department 
4. Retrieve the name of each employee who works on all the projects controlled by 
department number. 5 (use NOT EXISTS operator). 
5. For each department that has more than five employees, 
retrieve the department number and the number of its employees who are making more 
than Rs.6, 00,000.
*/

create database company_kiran;
use company_kiran;

create table department (
    dno INT ,
    dname varchar(20) NOT NULL,
    mgrssn varchar(20),
    mgrStartDate date,
    CONSTRAINT pk_department PRIMARY KEY(dno)
);

desc department;

create table employee (
    ssn varchar(20) ,
    name varchar(20) NOT NULL,
    address varchar(30),
    sex char(1) NOT NULL,
    salary int,
    superssn varchar(20),
    dno INT,
    CONSTRAINT pk_employee PRIMARY KEY(ssn),
    CONSTRAINT fk_employee_employee foreign key (superssn) references employee(ssn),
    CONSTRAINT fk_employee_department foreign key (dno) references department(dno)
);

desc employee;

alter table department
add CONSTRAINT fk_department_employee 
foreign key (mgrssn) references employee(ssn);

create table dlocation (
    dno INT,
    dloc varchar(20),
    CONSTRAINT fk_dlocation_department 
    foreign key (dno) references department(dno)
);

create table project (
    pno int,
    pname varchar(20),
    plocation varchar(20),
    dno INT,
    CONSTRAINT pk_project_pno PRIMARY KEY(pno),
    CONSTRAINT fk_project_department
    foreign key (dno) references department(dno)
);

create table works_on (
    ssn varchar(20),
    pno int,
    hours int,
    CONSTRAINT pk_works_on PRIMARY KEY (ssn,pno),
    CONSTRAINT fk_works_on_employee foreign key (ssn) references employee(ssn),
    CONSTRAINT fk_works_on_project foreign key (pno) references project(pno)
);

-- Insert into DEPARTMENT
INSERT INTO department(dno,dname) 
VALUES
(1,'accounts'),
(2,'hr'),
(3,'sales');



-- #Insertion
-- Insert into EMPLOYEE

INSERT INTO employee
VALUES
('abc00','kiran','dvg','m',800000,NULL,1),
('abc01','ben scott','blr','m', 450000,'abc00',1),
('abc02','akhilesh','blr','m', 500000,'abc00',1),
('abc03','bhuvan','blr','m', 700000,'abc02',3),
('abc04','martin scott','mys','m', 500000,'abc00',2),
('abc05','shashank','MGR','m', 650000,'abc04',2),
('abc06','abhay','mys','m', 450000,'abc03',3),
('abc07','cstmn','blr','f', 800000,'abc04',2),
('abc08','nishi','MGR','f', 350000,'abc03',3),
('abc09','tejas','MGR','m', 300000,'abc00',1),
('abc10','sagar','mys','m', 600000,'abc00',1),
('abc11','deekshith','blr','m', 500000,'abc00',1);

-- Select from EMPLOYEE
SELECT * FROM employee;


-- Select from DEPARTMENT
SELECT * FROM department;

-- Update DEPARTMENT
UPDATE department
SET
mgrssn='abc00',
mgrStartDate='2021-12-31'
WHERE dno=1;

UPDATE department
SET
mgrssn='abc04',
mgrStartDate='2022-12-31'
WHERE dno=2;

UPDATE department
SET
mgrssn='abc03',
mgrStartDate='2022-11-14'
WHERE dno=3;



-- Insert into DLOCATION
INSERT INTO dlocation VALUES 
(1, 'blr'),
(2, 'mys'),
(3, 'dvg');

-- Select from DLOCATION
SELECT * FROM dlocation;

-- Insert into PROJECT
INSERT INTO project 
VALUES 
(1000,'bank management','blr',1),
(1001,'salary management','blr',1),
(1002,'iot','mys',2),
(1003,'data analysis','dvg',3);

-- Select from PROJECT
SELECT * FROM project;

-- Insert into WORKS_ON
INSERT INTO works_on 
VALUES
('abc01', 1000, 8),
('abc02', 1000, 6),
('abc02', 1001, 8),
('abc03', 1003, 10),
('abc05', 1002, 30),
('abc06', 1003, 4),
('abc07', 1002, 5);


-- Select from WORKS_ON
SELECT * FROM works_on;

-- #Queries:

/*
1. Make a list of all project numbers for projects that involve an employee whose last name
is ‘Scott’, either as a worker or as a manager of the department that controls the project.
*/

SELECT DISTINCT w.pno
FROM works_on w
JOIN employee e on e.SSN=w.ssn
WHERE e.name LIKE '%scott'
UNION
SELECT DISTINCT p.pno
FROM project p
JOIN department d ON p.dno=d.dno
JOIN employee e ON e.ssn=d.mgrssn
WHERE e.name LIKE '%scott';



/*
2. Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10
percent raise.
*/

SELECT e.ssn,e.name,e.salary, 1.1 * e.salary AS new_salary
FROM employee e
JOIN works_on w ON w.ssn = e.ssn
JOIN project p ON p.pno = w.pno
WHERE p.pname='iot';

/*
3. Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the
maximum salary, the minimum salary, and the average salary in this department
*/
SELECT SUM(e.salary),max(e.salary),min(e.salary),avg(e.salary)
FROM employee e
JOIN department d ON d.dno=e.dno
WHERE d.dname='accounts';

/*
4. Retrieve the name of each employee who works on all the projects controlled by
department number.5 (use NOT EXISTS operator).
*/

SELECT e.name
FROM employee e
WHERE NOT EXISTS (
      SELECT p.pno
      FROM project p
      WHERE p.dno=1
      AND NOT EXISTS (
            SELECT w.ssn
            FROM works_on w
            WHERE w.ssn = e.ssn AND 
                  w.pno = p.pno
      )
);


/*
5. For each department that has more than five employees,
retrieve the department number and the number of its employees who are making more than
 Rs.6, 00,000.
*/

SELECT e.dno,COUNT(*) AS No_of_Employees_earning_more_than_600000
FROM employee e
WHERE e.dno IN (
        SELECT e1.dno
        FROM employee e1
        GROUP BY e1.dno
        HAVING COUNT(e1.dno) > 5)
      AND e.salary > 600000
GROUP BY e.dno;


