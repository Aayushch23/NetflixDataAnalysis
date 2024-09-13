create database db;
select * from netflix;

/*1. Write a query to list all titles with their show_id, title, and type.*/

select  show_id,title, type from netflix;

/*2. Write a query to display all columns for titles that are Movies.*/

select * from netflix where type = 'Movie';

/*3. Write a query to list TV shows that were released in the year 2021.*/

select * from netflix where type = 'TV Show' and release_year = 2021;

/*4. Write a query to find all titles where the description contains the word family.*/

select title from netflix where description like '%family%';

/*5. Write a query to count the total number of titles in the dataset.*/

select count(title) from netflix;

/*6.Write a query to find the average duration of all movies (in minutes, wherever the season is mentioned, consider 400 minutes per season).*/

ALTER TABLE netflix ADD COLUMN duration_in_minutes INT;
UPDATE netflix
SET duration_in_minutes = 
    CASE
        WHEN duration LIKE '% min' THEN CAST(REPLACE(duration, ' min', '') AS UNSIGNED)
        WHEN duration LIKE '% Seasons' THEN CAST(REPLACE(duration, ' Seasons', '') AS UNSIGNED) * 400
        WHEN duration LIKE '% Season' THEN CAST(REPLACE(duration, ' Season', '') AS UNSIGNED) * 400
    END;
SELECT AVG(duration_in_minutes) AS average_duration FROM netflix;

/*7. Write a query to list the top 5 latest titles based on the date_added, sorted in descending order.*/

ALTER TABLE netflix ADD COLUMN date_added_converted DATE;
ALTER TABLE netflix CHANGE COLUMN `Date` `date_added` VARCHAR(255);
DELETE FROM netflix WHERE date_added = '//';
UPDATE netflix SET date_added_converted = STR_TO_DATE(date_added, '%d/%m/%Y');
SELECT title, date_added_converted FROM netflix ORDER BY date_added_converted DESC LIMIT 5;

/*8. Write a query to list all titles along with the number of other titles by the same director. Include columns for show_id, title, director, and number_of_titles_by_director.*/

SELECT n1.show_id, n1.title, n1.director, n2.number_of_titles_by_director FROM  netflix n1
JOIN (SELECT director, COUNT(*) AS number_of_titles_by_director FROM netflix GROUP BY director) n2 
ON n1.director = n2.director
ORDER BY n1.show_id;
    
/*9. Write a query to find the total number of titles for each country. Display country and the count of titles.*/

SELECT country, COUNT(*) AS number_of_titles FROM netflix GROUP BY country ORDER BY number_of_titles DESC;

/*10. Write a query using a CASE statement to categorize titles into three categories based on their rating: Family for ratings G, PG, PG-13, Kids for TV-Y, TV-Y7, TV-G, and Adult for all other ratings.*/

SELECT show_id, title, rating,
    CASE
        WHEN rating IN ('G', 'PG', 'PG-13') THEN 'Family'
        WHEN rating IN ('TV-Y', 'TV-Y7', 'TV-G') THEN 'Kids'
        ELSE 'Adult'
    END AS category FROM netflix;
    
/*11. Write a query to add a new column title_length to the titles table that calculates the length of each title.*/

alter table netflix add column title_length INT;
SET SQL_SAFE_UPDATES = 0;
update netflix set title_length = LENGTH(title)  WHERE show_id IS NOT NULL;

/*12. Write a query using an advanced function to find the title with the longest duration in minutes.*/
SELECT title, duration_in_minutes FROM netflix ORDER BY duration_in_minutes DESC LIMIT 1;
SELECT title, duration_in_minutes FROM netflix Where type = 'Movie'ORDER BY duration_in_minutes DESC LIMIT 1;

/*13. Create a view named RecentTitles that includes titles added in the last 30 days.*/
CREATE VIEW RecentTitles AS SELECT * FROM netflix
WHERE date_added >= CURDATE() - INTERVAL 30 DAY;
SELECT * FROM RecentTitles;

/*14. Write a query using a window function to rank titles based on their release_year within each country.*/
SELECT title, country, release_year, RANK() OVER (PARTITION BY country ORDER BY release_year) 
AS release_year_rank FROM netflix;

/*15. Write a query to calculate the cumulative count of titles added each month sorted by date_added.*/
SELECT date_added_converted, COUNT(*) OVER (PARTITION BY YEAR(date_added_converted), 
MONTH(date_added_converted) ORDER BY date_added_converted) AS cumulative_count FROM netflix;

/*16. Write a stored procedure to update the rating of a title given its show_id and new rating.*/

/*17. Write a query to find the country with the highest average rating for titles. Use subqueries and aggregate functions to achieve this.*/
SELECT n.country, n.title AS title_with_highest_rating, n.rating AS highest_rating
FROM netflix n
INNER JOIN (SELECT country, MAX(rating) AS max_rating FROM netflix GROUP BY country) 
AS max_ratings 
ON n.country = max_ratings.country AND n.rating = max_ratings.max_rating;

/*18. Write a query to find pairs of titles from the same country where one title has a higher rating than the other. Display columns for show_id_1, title_1, rating_1, show_id_2, title_2, and rating_2.*/
SELECT n1.show_id AS show_id_1, n1.title AS title_1, n1.rating AS rating_1, n2.show_id AS show_id_2,
n2.title AS title_2, n2.rating AS rating_2 FROM netflix n1 INNER JOIN 
netflix n2 ON n1.country = n2.country WHERE 
n1.show_id < n2.show_id AND n1.rating > n2.rating;



