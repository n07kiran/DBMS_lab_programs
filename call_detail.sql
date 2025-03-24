/*
Consider the schema of the call detail table to partitioned primary index: 
 
CREATE TABLE calldetail ( 
phone_number DECIMAL(10) NOT NULL, 
call_start TIMESTAMP, 
call_duration INTEGER, 
call_description VARCHAR(30)) 
PRIMARY INDEX (phone_number, call_start); 
Demonstrate the query against this table be optimized by partitioning its primary index 
using partitioning techniques. */



CREATE TABLE calldetail (
    phone_number DECIMAL(10) NOT NULL,
    call_start TIMESTAMP,
    call_duration INTEGER,
    call_description VARCHAR(30),
    PRIMARY KEY (phone_number, call_start)
);

CREATE TABLE calldetail_partitioned (
	phone_number DECIMAL (10) NOT NULL,
	call_start TIMESTAMP,
	call_duration INTEGER,
	call_description VARCHAR(30),
	PRIMARY KEY (phone_number,call_start)
)
PARTITION BY RANGE (UNIX_TIMESTAMP(call_start))(
	PARTITION p_before_2023 VALUES LESS THAN (UNIX_TIMESTAMP('2023-01-01 00:00:00')),
	PARTITION p_2023 VALUES LESS THAN (UNIX_TIMESTAMP('2024-01-01 00:00:00')),
	PARTITION p_2024 VALUES LESS THAN (UNIX_TIMESTAMP('2025-01-01 00:00:00')),
	PARTITION p_future VALUES LESS THAN MAXVALUE
);

CREATE INDEX idx ON calldetail_partitioned(phone_number,call_start);

-- SHOW INDEX FROM calldetail_partitioned;

INSERT INTO calldetail VALUES
(1234567890,'2023-07-23 08:30:00',12,'Work call'),
(1234567891,'2022-08-23 09:30:00',12,'Work call'),
(1234567892,'2024-09-23 10:30:00',12,'Work call'),
(1234567890,'2024-10-23 11:30:00',12,'Work call'),
(1234567892,'2023-11-23 12:30:00',12,'Work call'),
(1234567891,'2024-12-23 07:30:00',12,'Work call'),
(1234567892,'2023-01-23 06:30:00',12,'Work call'),
(1234567891,'2023-03-23 05:30:00',12,'Work call'),
(1234567890,'2024-02-23 04:30:00',12,'Work call'),
(1234567890,'2020-07-23 03:30:00',12,'Work call');

INSERT INTO calldetail_partitioned VALUES
(1234567890,'2023-07-23 08:30:00',12,'Work call'),
(1234567891,'2022-08-23 09:30:00',12,'Work call'),
(1234567892,'2024-09-23 10:30:00',12,'Work call'),
(1234567890,'2024-10-23 11:30:00',12,'Work call'),
(1234567892,'2023-11-23 12:30:00',12,'Work call'),
(1234567891,'2024-12-23 07:30:00',12,'Work call'),
(1234567892,'2023-01-23 06:30:00',12,'Work call'),
(1234567891,'2023-03-23 05:30:00',12,'Work call'),
(1234567890,'2024-02-23 04:30:00',12,'Work call'),
(1234567890,'2020-07-23 03:30:00',12,'Work call');

-- 1.
SELECT * FROM calldetail
WHERE call_start >= '2024-01-01 00:00:00' AND call_start < '2025-01-01 00:00:00';

-- 2.
EXPLAIN 
SELECT * FROM calldetail
WHERE call_start >= '2024-01-01 00:00:00' AND call_start < '2025-01-01 00:00:00';

-- 3.
SELECT * FROM calldetail_partitioned
WHERE call_start >= '2024-01-01 00:00:00' AND call_start < '2025-01-01 00:00:00';

-- 4.
EXPLAIN 
SELECT * FROM calldetail_partitioned
WHERE call_start >= '2024-01-01 00:01:00' AND call_start < '2025-01-01 00:00:00';
/*
-- Output: 
-- COMPARE THE ROWS column in output of Query 2 and 4.

-- 1.
+--------------+---------------------+---------------+------------------+
| phone_number | call_start          | call_duration | call_description |
+--------------+---------------------+---------------+------------------+
|   1234567890 | 2024-02-23 04:30:00 |            12 | Work call        |
|   1234567890 | 2024-10-23 11:30:00 |            12 | Work call        |
|   1234567891 | 2024-12-23 07:30:00 |            12 | Work call        |
|   1234567892 | 2024-09-23 10:30:00 |            12 | Work call        |
+--------------+---------------------+---------------+------------------+

-- 2. 
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | calldetail | NULL       | ALL  | NULL          | NULL | NULL    | NULL |   10 |    11.11 | Using where |
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+

-- 3.
+--------------+---------------------+---------------+------------------+
| phone_number | call_start          | call_duration | call_description |
+--------------+---------------------+---------------+------------------+
|   1234567890 | 2024-02-23 04:30:00 |            12 | Work call        |
|   1234567890 | 2024-10-23 11:30:00 |            12 | Work call        |
|   1234567891 | 2024-12-23 07:30:00 |            12 | Work call        |
|   1234567892 | 2024-09-23 10:30:00 |            12 | Work call        |
+--------------+---------------------+---------------+------------------+

-- 4.
+----+-------------+------------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table                  | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | calldetail_partitioned | p_2024     | ALL  | NULL          | NULL | NULL    | NULL |    4 |    25.00 | Using where |


+----+-------------+------------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
*/
