/*
Consider the schema for Movie Database: 
ACTOR (Act_id, Act_Name, Act_Gender) 
DIRECTOR (Dir_id, Dir_Name, Dir_Phone) 
MOVIES (Mov_id, Mov_Title, Mov_Year, Mov_Lang, Dir_id) 
MOVIE_CAST (Act_id, Mov_id, Role) 
RATING (Mov_id, Rev_Stars) 
Write SQL queries to 
1. List the titles of all movies directed by ‘Hitchcock’. 
2. Find the movie names where one or more actors acted in two or more movies. 
3. List all actors who acted in a movie before 2000 and also in a movie after 2020 (use 
JOIN operation). 
4. Find the title of movies and number of stars for each movie that has at least one rating 
and find the highest number of stars that movie received. Sort the result by movie title. 
5. Update rating of all movies directed by ‘Steven Spielberg’ to 5. 
*/

create database movie;

use movie;

create table actor (
  act_id int not null ,		
  act_name varchar(20) NOT NULL,
  act_gender char(1) ,
  CONSTRAINT pk_actor_act_id PRIMARY KEY (act_id)
);

create table director (
  dir_id int not null,
  dir_name varchar(20),
  dir_phone varchar(20),
  CONSTRAINT pk_director_dir_id PRIMARY KEY (dir_id)
);

create table movies(
  mov_id int not null,
  mov_title varchar(20),
  mov_year year,
  mov_lang varchar(20),
  dir_id int not null,
  CONSTRAINT pk_movies_mov_id PRIMARY KEY (mov_id),
  CONSTRAINT fk_movies_director FOREIGN KEY (dir_id) 
	REFERENCES director(dir_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

create table movie_cast (
  act_id int ,
  mov_id int,
  role varchar(20),
  CONSTRAINT fk_movie_cast_actor foreign key (act_id) references actor(act_id) on delete cascade on update cascade,
  CONSTRAINT fk_move_case_movies foreign key (mov_id) references movies(mov_id) on delete cascade on update cascade
);


create table rating(
  mov_id int NOT NULL,
  rev_stars varchar(25),
  CONSTRAINT fk_rating_movie foreign key (mov_id) references  movies(mov_id) on delete cascade on update cascade
);


INSERT INTO actor  VALUES
(101,'RAHUL','M'),
(102,'ANKITHA','F'),
(103,'RADHIKA','F'),
(104,'CHETHAN','M'),
(105,'VIVAN','M'),
(106,'SHIVANNA','M');

select * from ACTOR;

INSERT INTO director VALUES
(201,'ANUP',918181818),
(202,'HITCHCOCK',918181812),
(203,'SHASHANK',918181813),
(204,'STEVEN SPIELBERG',918181814),
(205,'ANAND',918181815),
(206,'UPENDRA',999888);

select * from director; 

INSERT INTO movies 
VALUES
(1001,'MANASU',2017,'KANNADA',201),
(1002,'AAKASHAM',2015,'TELUGU',204),
(1003,'KALIYONA',2008,'KANNADA',201),
(1004,'WAR HORSE',2011,'ENGLISH',202),
(1005,'HOME',2012,'ENGLISH',205),
(1006,'OM',1998,'KANNADA',206);

INSERT INTO movie_cast 
VALUES
(106,1001,'Villian'),
(101,1002,'HERO'),
(101,1001,'HERO'),
(103,1003,'HEROINE'),
(103,1002,'GUEST'),
(104,1004,'HERO'),
(106,1006,'HERO');

select * from movie_cast;

INSERT INTO rating VALUES
(1001,4),
(1002,2),
(1003,5),
(1004,4),
(1005,3),
(1006,5);

delete from rating where mov_id = 1002;

/*
1)List the titles of all movies directed by ‘Hitchcock’.
*/
                 
SELECT m.mov_id,m.mov_title,d.dir_name
FROM movies m
NATURAL JOIN director d
WHERE d.dir_name = 'HITCHCOCK';


/*
2)Find the movie names where one or more actors acted in two or more movies.
*/

SELECT m.mov_title FROM movies m
NATURAL JOIN
(SELECT DISTINCT mov_id FROM movie_cast mc 
 NATURAL JOIN  
	(SELECT act_id FROM movie_cast 
	 GROUP BY act_id 
	 HAVING COUNT(*) >=2 ) 
	 AS filtered_actors) 
AS filtered_movies;

/*
3)List all actors who acted in a movie before 2000 and also in a movie after 2015 (use JOIN 
operation).
*/

SELECT DISTINCT a.act_id, a.act_name
FROM actor a
JOIN movie_cast mc ON a.act_id = mc.act_id
JOIN movies m ON m.mov_id = mc.mov_id
WHERE m.mov_year < 2000
	AND a.act_id IN (	SELECT mc1.act_id
						FROM movies m1
						JOIN movie_cast mc1 on m1.mov_id = mc1.mov_id
						WHERE m1.mov_year > 2015
					);
					
/*
4)Find the title of movies and number of stars for each movie that has at least one rating and 
find the highest number of stars that movie received. Sort the result by movie title
*/

select mov_title , max(rev_stars)
from movies natural join rating
group by mov_title
order by mov_title;

/*
#5) Update rating of all movies directed by ‘Steven Spielberg’ to 5.
*/

update rating
set rev_stars = 5
where mov_id in ( select mov_id 
                  from director natural join movies
                  where dir_name = 'STEVEN SPIELBERG'
 );

select * from rating
order by mov_id;
