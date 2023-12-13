USE imdb_ijs;

-- I) The big picture
-- How many actors are there in the actors table? 817.718 
SELECT COUNT(DISTINCT id) as distinct_actor_count
FROM actors;

-- How many directors are there in the directors table? 86.880
SELECT COUNT(DISTINCT id) as distinct_director_count
FROM directors;

-- How many movies are there in the movies table? 388.269
SELECT COUNT(DISTINCT id) as distinct_movie_count
FROM movies;

-- II) Exploring the movies
-- From what year are the oldest and the newest movies? What are the names of those movies?
-- 1888, 2008
SELECT name, year
FROM movies
WHERE year IN (1888,2008);

-- What movies have the highest and the lowest ranks?

-- Alter data type from DOUBLE to FLOAT
ALTER TABLE movies
MODIFY COLUMN `rank` FLOAT;
-- Subqueries
SELECT MIN(`rank`) AS min_rank
FROM movies
WHERE `rank` IS NOT NULL;

SELECT MAX(`rank`) AS max_rank
FROM movies
WHERE `rank` IS NOT NULL;

-- Final query
SELECT name, `rank`
FROM movies
WHERE `rank` = (
    SELECT MIN(`rank`)
    FROM movies
    WHERE `rank` IS NOT NULL
) OR `rank` = (
    SELECT MAX(`rank`)
    FROM movies
    WHERE `rank` IS NOT NULL
);

-- What is the most common movie title?
SELECT name, COUNT(name) name_count
FROM movies
GROUP BY name
ORDER BY name_count DESC
LIMIT 1;

-- III) Understanding the database
-- Are there movies with multiple directors?
SELECT movie_id, COUNT(director_id) as director_count
FROM movies_directors
GROUP BY movie_id
HAVING director_count > 1;

-- What is the movie with the most directors? The Bill, 87 directors, id: 382052
SELECT movie_id, name,  COUNT(director_id) as director_count
FROM movies_directors AS md
JOIN movies AS m
ON md.movie_id = m.id
GROUP BY movie_id
HAVING director_count > 1
ORDER BY director_count DESC
LIMIT 1;

-- Why do you think it has so many? Started in 1984, Googled the ending year (2010) running for 26 years.
SELECT *
FROM movies 
WHERE id = 382052;

-- On average, how many actors are listed for each movie?
SELECT name, movie_id, COUNT(actor_id) as avg_num_actors
FROM roles
JOIN movies
ON roles.movie_id = movies.id
GROUP BY movie_id;

-- Are there movies with more than one “genre”?
SELECT name, movie_id, COUNT(genre) AS genre_count
FROM movies_genres 
JOIN movies
ON movies_genres.movie_id = movies.id
GROUP BY movie_id
HAVING genre_count > 1;

-- EXTRA: what are the top 5  most frequent genre?

SELECT genre, COUNT(movie_id) AS movie_count_per_genre
FROM movies_genres
GROUP BY genre
ORDER BY movie_count_per_genre DESC
LIMIT 5;

USE imdb_ijs;

-- I) Looking for specific movies

-- Can you find the movie called “Pulp Fiction”? id: 267038
SELECT *
FROM movies
WHERE name = "Pulp Fiction";

--  Who directed it? Quentin Tarantino
SELECT first_name, last_name
FROM movies_directors
JOIN directors
ON movies_directors.director_id = directors.id
WHERE movie_id = 267038;

--  Which actors were cast in it?
SELECT first_name, last_name
FROM roles
JOIN actors
ON roles.actor_id = actors.id
WHERE movie_id = 267038;

-- Can you find the movie called “La Dolce Vita”? id: 89572
SELECT *
FROM movies
WHERE NAME LIKE "%Dolce%";

--  Who directed it? Federico Fellini
SELECT first_name, last_name
FROM movies_directors
JOIN directors
ON movies_directors.director_id = directors.id
WHERE movie_id = 89572;

--  Which actors were cast in it?
SELECT first_name, last_name
FROM roles
JOIN actors
ON roles.actor_id = actors.id
WHERE movie_id = 89572;

-- When was the movie “Titanic” by James Cameron released? id: 333856, first name James(I), last name Cameron 1997
--  Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
--  Hint 2: the name “James Cameron” is stored with a weird character on it. 
SELECT name, first_name, last_name, m.id, year
FROM movies AS m
JOIN movies_directors AS md
ON m.id = md.movie_id
JOIN directors AS d
ON md.director_id = d.id
WHERE first_name LIKE "%James%" AND last_name LIKE "%Cameron%" AND name LIKE "%Titanic%";

-- II) Actors and directors
-- Who is the actor that acted more times as “Himself”? - what does this even mean?
SELECT 
    a.first_name, a.last_name, COUNT(a.id)
FROM
    actors a
        JOIN
    roles r ON a.id = r.actor_id
WHERE
    `role` LIKE '%himself%'
GROUP BY a.id , a.first_name , a.last_name
ORDER BY COUNT(a.id) DESC
LIMIT 1;

-- What is the most common name for actors? 
-- Full name: 
SELECT CONCAT(first_name, ' ', last_name) AS full_name, COUNT(*) AS name_count
FROM actors
GROUP BY CONCAT(first_name, ' ', last_name)
HAVING name_count > 1;
-- First name: John 4371
SELECT first_name, COUNT(first_name) AS fname_count
FROM actors
GROUP BY first_name
ORDER BY fname_count DESC
LIMIT 1;
-- Last name: Smith 2425
SELECT last_name, COUNT(last_name) AS lname_count
FROM actors
GROUP BY last_name
ORDER BY lname_count DESC
LIMIT 1;

-- And for directors?
SELECT CONCAT(first_name, ' ', last_name) AS full_name, COUNT(*) AS name_count
FROM directors
GROUP BY CONCAT(first_name, ' ', last_name)
HAVING name_count > 1;
-- First name: Michael 670
SELECT first_name, COUNT(first_name) AS fname_count
FROM directors
GROUP BY first_name
ORDER BY fname_count DESC
LIMIT 1;
-- Last name: Smith 243
SELECT last_name, COUNT(last_name) AS lname_count
FROM directors
GROUP BY last_name
ORDER BY lname_count DESC
LIMIT 1;

-- III) Analysing genders
-- How many actors are male and how many are female?
-- What percentage of actors are female, and what percentage are male?
SELECT 
  COUNT(*) AS total_actors,
  SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count,
  SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count,
  ROUND((SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS male_percentage,
  ROUND((SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS female_percentage
FROM actors;

-- IV) Movies across time
-- How many of the movies were released after the year 2000? 46006
SELECT COUNT(id)
FROM movies
WHERE year > 2000;

-- How many of the movies were released between the years 1990 and 2000? 91138
SELECT COUNT(id)
FROM movies
WHERE year BETWEEN 1990 AND 2000;

-- Which are the 3 years with the most movies? 2002,2003,2001 ordered by movies_per_year
SELECT year, COUNT(id) movies_per_year
FROM movies
GROUP BY year
ORDER BY movies_per_year DESC
LIMIT 3;

-- How many movies were produced in those years? 35636 movies were produced in 2001,2002 and 2003
SELECT SUM(movies_per_year)
FROM (
    SELECT year, COUNT(id) AS movies_per_year
    FROM movies
    GROUP BY year
    ORDER BY movies_per_year DESC
    LIMIT 3
) AS top_3_years;

-- What are the top 5 movie genres? short, drama, comedy, documentary and animation
SELECT genre, COUNT(movie_id) AS genre_count
FROM movies_genres
GROUP BY genre
ORDER BY genre_count DESC
LIMIT 5;

-- What are the top 5 movie genres before 1920? Short, comedy, drama, documentary and western
SELECT genre, COUNT(movie_id) AS genre_count
FROM movies_genres
JOIN movies ON movies_genres.movie_id = movies.id
WHERE year < 1920
GROUP BY genre
ORDER BY genre_count DESC
LIMIT 5;

-- What is the evolution of the top movie genres across all the decades of the 20th century?

-- Create decades function 
DELIMITER $$

CREATE FUNCTION GetDecade(year INT) RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
    DECLARE decade VARCHAR(10);

    CASE
        WHEN year BETWEEN 1900 AND 1910 THEN SET decade = '1900s';
        WHEN year BETWEEN 1910 AND 1920 THEN SET decade = '1910s';
        WHEN year BETWEEN 1920 AND 1930 THEN SET decade = '1920s';
        WHEN year BETWEEN 1930 AND 1940 THEN SET decade = '1930s';
        WHEN year BETWEEN 1940 AND 1950 THEN SET decade = '1940s';
        WHEN year BETWEEN 1950 AND 1960 THEN SET decade = '1950s';
        WHEN year BETWEEN 1960 AND 1970 THEN SET decade = '1960s';
        WHEN year BETWEEN 1970 AND 1980 THEN SET decade = '1970s';
        WHEN year BETWEEN 1980 AND 1990 THEN SET decade = '1980s';
        WHEN year BETWEEN 1990 AND 2000 THEN SET decade = '1990s';
        ELSE SET decade = NULL;
    END CASE;

    RETURN decade;
END $$

DELIMITER ;

-- create procedure to get most popular genre per decade using the function from above

DELIMITER //

CREATE PROCEDURE MostFrequentGenrePerDecade()
BEGIN
    WITH DecadeGenreCounts AS (
      SELECT
        GetDecade(year) AS decades,
        genre,
        COUNT(genre) AS genre_count_per_decade,
        ROW_NUMBER() OVER (PARTITION BY GetDecade(year) ORDER BY COUNT(genre) DESC) AS genre_rank
      FROM movies
      JOIN movies_genres ON movies_genres.movie_id = movies.id
      WHERE GetDecade(year) IS NOT NULL
      GROUP BY decades, genre
    )

    SELECT * 
    FROM DecadeGenreCounts
    WHERE genre_rank = 1
    ORDER BY decades, genre_count_per_decade DESC;
END //

DELIMITER ;

CALL MostFrequentGenrePerDecade();

USE imdb_ijs;

-- I) Putting it all together: names, genders and time
-- Has the most common name for actors changed over time?

WITH RankedDirectors AS (
    SELECT
        year,
        first_name,
        COUNT(first_name) as fname_count,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY COUNT(first_name) DESC) AS rnk
    FROM
        directors
        JOIN movies_directors ON directors.id = movies_directors.director_id
        JOIN movies ON movies.id = movies_directors.movie_id
    GROUP BY
        year, first_name
)
SELECT
    year,
    first_name,
    fname_count
FROM
    RankedDirectors
WHERE
    rnk = 1
ORDER BY
    year;


-- Get the most common actor name for each decade in the XX century.

WITH MostFrequentActorFNames AS (
    SELECT
        FLOOR(movies.year / 10) * 10 AS decade,
        first_name,
        COUNT(first_name) as fname_count,
        ROW_NUMBER() OVER (PARTITION BY FLOOR(movies.year / 10) * 10 ORDER BY COUNT(first_name) DESC) AS rnk
    FROM
        movies
        JOIN roles ON movies.id = roles.movie_id
        JOIN actors ON roles.actor_id = actors.id
    GROUP BY
        FLOOR(movies.year / 10) * 10, first_name
)
SELECT
    decade,
    first_name,
    fname_count
FROM
    MostFrequentActorFNames
WHERE
    rnk = 1
ORDER BY
    decade;


-- Re-do the analysis on most common names, split for males and females.

WITH MostFrequentActorFNames AS (
    SELECT
        FLOOR(movies.year / 10) * 10 AS decade,
        first_name,
        gender,
        COUNT(first_name) as fname_count,
        ROW_NUMBER() OVER (PARTITION BY FLOOR(movies.year / 10) * 10, gender ORDER BY COUNT(first_name) DESC) AS rnk
    FROM
        movies
        JOIN roles ON movies.id = roles.movie_id
        JOIN actors ON roles.actor_id = actors.id
    GROUP BY
        FLOOR(movies.year / 10) * 10, first_name, gender
)
SELECT
    decade,
    MAX(CASE WHEN gender = 'F' AND rnk = 1 THEN first_name END) AS female_first_name,
    MAX(CASE WHEN gender = 'M' AND rnk = 1 THEN first_name END) AS male_first_name
FROM
    MostFrequentActorFNames
WHERE
    rnk = 1
GROUP BY
    decade
ORDER BY
    decade;


-- How many movies had a majority of females among their cast?

SELECT COUNT(*) AS movie_count
FROM (
    SELECT movies.id
    FROM movies
    JOIN roles ON movies.id = roles.movie_id
    JOIN actors ON roles.actor_id = actors.id
    GROUP BY movies.id
    HAVING SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) > SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END)
) AS movies_with_more_females;


-- Create a temporary table with movies where females outnumber males

CREATE TEMPORARY TABLE temp_movies_with_more_females AS
SELECT movies.id
FROM movies
JOIN roles ON movies.id = roles.movie_id
JOIN actors ON roles.actor_id = actors.id
GROUP BY movies.id
HAVING SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) > SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END);

-- Get the count of roles.movie_id for denominator
SELECT COUNT(DISTINCT(movie_id)) AS total_movies,
       (SELECT COUNT(*) FROM temp_movies_with_more_females) AS female_majority_movies
FROM roles;

SELECT COUNT(*) 
FROM temp_movies_with_more_females AS female_majority_movies;

SELECT COUNT(DISTINCT(movie_id)) 
FROM roles AS total_movies_in_roles;

-- What percentage of the total movies had a majority female cast?

WITH female_majority_cte AS (
  SELECT COUNT(*) AS female_majority_movies
  FROM temp_movies_with_more_females
),
total_movies_cte AS (
  SELECT COUNT(DISTINCT movie_id) AS total_movies_in_roles
  FROM roles
)
SELECT 
  female_majority_movies,
  total_movies_in_roles,
  (female_majority_movies * 100.0) / total_movies_in_roles AS percentage_female_majority
FROM female_majority_cte, total_movies_cte;


