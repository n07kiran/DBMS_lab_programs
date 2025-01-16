/*
Consider the schema for College Database: 
STUDENT (USN, SName, Address, Phone, Gender) 
SEMSEC (SSID, Sem, Sec) 
CLASS (USN, SSID) 
SUBJECT (Subcode, Title, Sem, Credits) 
IAMARKS (USN, Subcode, SSID, Test1, Test2, Test3, FinalIA) 
Write SQL queries to 
1. List all the student details studying in fifth semester ‘B’ section. 
2. Compute the total number of male and female students in each semester and in each 
section. 
3. Create a view of Event 1 marks of student USN ‘01JST    IS ’ in all subjects. 
4. Calculate the Final IA (average of best two test marks) and update the corresponding 
table for all students. 
5. Categorize students based on the following criterion: 
If Final IA = 17 to 20 then CAT =‘Outstanding’ 
If Final IA = 12 to 16 then CAT = ‘Average’ 
If Final IA< 12 then CAT = ‘Weak’ 
Give these details only for 8th semester A, B, and C section students. 
*/

CREATE DATABASE college_kiran;
USE college_kiran;

CREATE TABLE STUDENT (
   USN VARCHAR(20),
   SNAME VARCHAR(20),
   ADDRESS VARCHAR(40),
   PHONE VARCHAR(10),
   GENDER CHAR,
   CONSTRAINT pk_student_usn PRIMARY KEY (USN)
);

DESC STUDENT;

CREATE TABLE SEMSEC (
   SSID VARCHAR(20),
   SEM INT,
   SEC CHAR,
   CONSTRAINT pk_semsec_ssid PRIMARY KEY (SSID)
);

CREATE TABLE CLASS (
   USN VARCHAR(20),
   SSID VARCHAR(20),
   CONSTRAINT pk_class_usn_ssid PRIMARY KEY (USN, SSID),
   CONSTRAINT fk_class_student FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT fk_class_semsec FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SUBJECT (
   SUBCODE VARCHAR(10),
   TITLE VARCHAR(50),
   SEM INT,
   CREDITS INT,
   CONSTRAINT pk_subject_subcode PRIMARY KEY (SUBCODE)
);

CREATE TABLE IAMARKS (
   USN VARCHAR(20),
   SUBCODE VARCHAR(10),
   SSID VARCHAR(20),
   TEST1 INT,
   TEST2 INT,
   TEST3 INT,
   FINALIA INT,
   CONSTRAINT pk_iamarks_usn_subcode_ssid PRIMARY KEY (USN, SUBCODE, SSID),
   FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (SUBCODE) REFERENCES SUBJECT(SUBCODE) ON DELETE CASCADE ON UPDATE CASCADE
);

DESC STUDENT;

INSERT INTO STUDENT 
VALUES
('01JST21IS020', 'KIRAN', 'DVG', '1111111111', 'M'),
('01JST22UIS001', 'ABHAY', 'BLR', '2222222222', 'M'),
('01JST22UIS018', 'SHASHANK', 'MANDYA', '4545454545', 'M'),
('01JST22UCS021', 'PH', 'MYS', '5656565656', 'F'),
('01JST22UEC001', 'PUCCHE', 'UK', '9898989898', 'M'),
('01JST22UCS005', 'NEHA', 'KUNDAPURA', '6565676767', 'F'),
('01JST21IS018', 'CA', 'KAIGA', '4545454545', 'M'),
('01JST21CS021', 'TH', 'MYS', '5656565656', 'M'),
('01JST21EC001', 'VMJ', 'UK', '9898989898', 'M'),
('01JST21CS005', 'ANANYA', 'KUNDAPURA', '6565676767', 'F');

DESC SEMSEC; 


INSERT INTO SEMSEC VALUES
('5B', 5, 'B'),
('5A', 5, 'A'),
('8C', 8, 'C'),
('8A', 8, 'A'),
('8B', 8, 'B');

SELECT * FROM SEMSEC;
SELECT * FROM STUDENT;

INSERT INTO CLASS 
VALUES
('01JST21IS020', '5A'),
('01JST22UIS001', '5A'),
('01JST22UIS018', '5B'),
('01JST22UCS021', '5A'),
('01JST22UEC001', '5A'),
('01JST22UCS005', '5B'),
('01JST21IS018', '8A'),
('01JST21CS021', '8B'),
('01JST21EC001', '8A'),
('01JST21CS005', '8C');

INSERT INTO SUBJECT 
VALUES
('IS520', 'DBMS', 5, 4),
('IS510', 'CN', 5, 4),
('IS810', 'MGMT', 8, 3);

INSERT INTO IAMARKS 
VALUES
('01JST21IS020', 'IS520', '5A', 25, 17, 30, 40),
('01JST21IS020', 'IS510', '5A', 28, 19, 24, 50),
('01JST22UIS001', 'IS510', '5A', 17, 17, 17, 40),
('01JST22UIS001', 'IS520', '5A', 23, 17, 27, 45),
('01JST22UIS018', 'IS520', '5B', 10, 18, 25, 35),
('01JST22UIS018', 'IS510', '5B', 20, 18, 28, 45),
('01JST22UCS021', 'IS520', '5A', 25, 17, 30, 50),
('01JST22UEC001', 'IS510', '5A', 28, 19, 24, 55),
('01JST22UCS005', 'IS520', '5B', 25, 17, 30, 60),
('01JST21IS018', 'IS520', '5A', 15, 16, 20, 30),
('01JST21IS018', 'IS510', '5A', 4, 16, 10, 20),
('01JST21IS018', 'IS810', '8A', 30, 20, 30, 70),
('01JST21CS021', 'IS510', '5B', 25, 17, 30, 40),
('01JST21CS021', 'IS810', '8B', 26, 27, 13, 60),
('01JST21CS005', 'IS810', '8C', 15, 19, 30, 50);


/*
QUERIES
1). List all the student details studying in fifth semester ‘B’ section
*/

SELECT S.*
FROM STUDENT S
JOIN CLASS C on C.USN = S.USN
JOIN SEMSEC SS on C.SSID = SS.SSID
WHERE	SS.SEM = 5 AND
	SS.SEC = 'B';


-- 2)Compute the total number of male and female students in each semester and in each section

SELECT SS.SEM,SS.SEC,S.GENDER,COUNT(*) AS TotalStudents
FROM STUDENT S
JOIN CLASS C on C.USN = S.USN
JOIN SEMSEC SS ON SS.SSID = C.SSID
GROUP BY SS.SEM,SS.SEC,S.GENDER
ORDER BY SS.SEM;


-- 3)Create a view of Event 1 marks of student USN ‘01JST IS ’ in all subjects.

CREATE VIEW ISE_TEST1_MARKS_VIEW
AS
SELECT USN,Subcode,SSID,Test1
FROM IAMARKS
WHERE USN LIKE '01JST%IS%';

SELECT * FROM ISE_TEST1_MARKS_VIEW;

/*
4)Calculate the Final IA (average of best two test marks) and update the corresponding table 
for all students.
*/

UPDATE IAMARKS I
SET FINALIA = CEIL((I.Test1 + I.Test2 + I.Test3 - LEAST(I.Test1,I.Test2,I.Test3))/2);

SELECT * FROM IAMARKS;

/*
5) Categorize students based on the following criterion:
If Final IA = 17 to 20 then CAT =‘Outstanding’ 
If Final IA = 12 to 16 then CAT = ‘Average’
If Final IA< 12 then CAT = ‘Weak’
Give these details only for 8th semester A, B, and C section students.
*/

SELECT S.USN,S.SNAME,IA.SUBCODE,SS.SEM,SS.SEC,IA.FINALIA,
	CASE    WHEN IA.FINALIA >= 17 THEN 'OutStanding'
		WHEN IA.FINALIA BETWEEN 12 AND 16 THEN 'Average'
		WHEN IA.FINALIA < 12 THEN 'Weak'
	END AS CAT
FROM STUDENT S
JOIN IAMARKS IA ON S.USN = IA.USN
JOIN SEMSEC SS ON SS.SSID = IA.SSID
WHERE 	SS.SEM = 8 AND
	SS.SEC IN ('A','B','C');


