use sakila;

-- 1.1 Contribution of Countries & Cities (in hierarchy) by rental amount 
SELECT cy.country + ',' + c.city AS Country_City, SUM(p.amount) AS total_rental_sales
FROM payment  p INNER JOIN
rental  r 
ON p.rental_id = r.rental_id INNER JOIN
customer  cs 
ON cs.customer_id = r.customer_id INNER JOIN
address  a 
ON cs.address_id = a.address_id INNER JOIN
city  c 
ON a.city_id = c.city_id INNER JOIN
country  cy 
ON c.country_id = cy.country_id
GROUP BY cy.country + ',' + c.city
ORDER BY cy.country + ',' + c.city;

-- 1.2 Rental amounts by countries for PG & PG-13 rated films
SELECT cy.country AS customer_country, f.rating AS rated_films,
SUM(p.amount) AS total_rental_sales
FROM payment  p INNER JOIN
rental  r 
ON p.rental_id = r.rental_id INNER JOIN
inventory  iv 
ON iv.inventory_id = r.inventory_id INNER JOIN
film  f 
ON f.film_id = iv.film_id INNER JOIN
customer  cs 
ON cs.customer_id = r.customer_id INNER JOIN
address  a 
ON cs.address_id = a.address_id INNER JOIN
city c 
ON a.city_id = c.city_id INNER JOIN
country cy 
ON c.country_id = cy.country_id
WHERE (f.rating = 'PG') OR (f.rating = 'PG-13')
GROUP BY cy.country, f.rating
ORDER BY cy.country;

-- 1.3 Top 20 cities by number of customers who rented
SELECT TOP 20 c.city, COUNT(r.customer_id) AS #OfCustRented
FROM payment  p INNER JOIN
rental  r ON p.rental_id = r.rental_id INNER JOIN
customer  cs ON cs.customer_id = r.customer_id INNER JOIN
address  a ON cs.address_id = a.address_id INNER JOIN
city  c ON a.city_id = c.city_id 
GROUP BY c.city
ORDER BY COUNT(r.customer_id) DESC;

-- 1.4 Top 20 cities by number of films rented 
SELECT TOP 20 c.city, COUNT(f.film_id) AS #OfFilmRented
FROM payment AS p INNER JOIN
rental r ON p.rental_id = r.rental_id INNER JOIN
inventory iv ON r.inventory_id = iv.inventory_id INNER JOIN
film f ON f.film_id = iv.film_id INNER JOIN
customer cs ON cs.customer_id = r.customer_id INNER JOIN
address a ON cs.address_id = a.address_id INNER JOIN
city c ON a.city_id = c.city_id INNER JOIN
country cy ON c.country_id = cy.country_id
GROUP BY c.city
ORDER BY COUNT(f.film_id) DESC;

-- 1.5 Display total rental amounts (payment amount) by city
SELECT c.city AS customer_city, avg(p.amount) AS total_rental_sales
FROM payment p INNER JOIN
rental r 
ON p.rental_id = r.rental_id INNER JOIN
customer cs 
ON cs.customer_id = r.customer_id INNER JOIN
address a 
ON cs.address_id = a.address_id INNER JOIN
city c 
ON a.city_id = c.city_id 
GROUP BY c.city
ORDER BY avg(p.amount) DESC;


--2.1--film category by rental amount and quantity
select name , COUNT(f.film_id) AS rental_quantity, DENSE_RANK() OVER( ORDER BY SUM(p.amount) DESC) AS SalesRank,  sum(amount) as Rental_amount from category c
join film_category fc 
on fc.category_id = c.category_id
join film f
on f.film_id = fc.film_id
join inventory i
on i.film_id = f.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by c.name;

--2.2--film category by rental amount
select c.category_id, c.name, sum(p.amount) as rental_amount, DENSE_RANK() OVER( ORDER BY SUM(p.amount) DESC) AS SalesRank 
from film_category fc join film f
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
group by c.name, c.category_id ;


--2.3--film category by avg rental amount
select c.category_id, avg(p.amount) as avg_amount,DENSE_RANK() OVER( ORDER BY AVG(p.amount) DESC) AS AvgSalesRank 
from film_category fc join film f
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
group by c.category_id;

--2.4-- contribution of film category by number of customers
select distinct(c.name), count(m.customer_id) 
from film_category fc join film f
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
group by c.name
order by count(m.customer_id) desc;


--2.5--contribution of film categories by rental amount
select distinct(c.name), sum(p.amount) as rental_amount
from film_category fc join film f
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
group by c.name
order by sum(p.amount) desc ;

--3.1--list of films with rental amount, rental quantity, rating, rentalrate, replacementcost and category name.
select f.title, sum(p.amount) as rental_amount, count(r.rental_id) as quantity, f.rating, f.rental_rate, f.replacement_cost, c.name
from film f join film_category fc
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
group by f.title,f.rating, f.rental_rate, c.name, f.replacement_cost
order by f.title;

--3.2-- list top 10 films by rental amount
select top 10 f.title, sum(p.amount) as rental_amount, DENSE_RANK() OVER( ORDER BY SUM(p.amount) DESC) AS SalesRank
from film f join film_category fc
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
group by f.title
;

--3.3--list top 20 films by number of customers.
SELECT *,
	DENSE_RANK() OVER( ORDER BY #OfCustRented DESC) AS FilmRank
FROM(
SELECT TOP 20 f.title AS film_name, COUNT(r.customer_id) AS #OfCustRented	   
FROM payment  p INNER JOIN
rental  r ON p.rental_id = r.rental_id INNER JOIN
customer  cs ON cs.customer_id = r.customer_id INNER JOIN
inventory  i ON r.inventory_id = i.inventory_id INNER JOIN
film  f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.customer_id) DESC)temp
ORDER BY FilmRank;


--3.4--List Films with the word “punk” in title with rental amount and number of customers
select f.title, sum(p.amount), count(m.customer_id)
from film f join film_category fc
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
where f.title like '%punk%' 
group by f.title
order by count(m.customer_id) desc;

use sakila;
--3.5--Contribution by rental amount for films with a documentary category 
select f.title, sum(p.amount), c.name
from film f join film_category fc
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
where c.name = 'documentary'
group by c.name, f.title
order by sum(p.amount) desc
;

--4.1--List Customers (Last name, First Name) with rental amount, rental quantity, active status, country and city
SELECT cs.first_name + ' ' + cs.last_name AS customer_name, 
SUM(p.amount) AS rental_amt, COUNT(f.film_id) AS rental_quantity,
CASE WHEN cs.active = 1 THEN 'active' ELSE 'not active' END AS active_status,
cy.country, c.city
FROM dbo.payment AS p INNER JOIN
rental AS r ON p.rental_id = r.rental_id INNER JOIN
inventory AS iv ON iv.inventory_id = r.inventory_id INNER JOIN
film as f ON f.film_id = iv.film_id INNER JOIN
customer AS cs ON cs.customer_id = r.customer_id INNER JOIN
address AS a ON cs.address_id = a.address_id INNER JOIN
city AS c ON a.city_id = c.city_id INNER JOIN
country AS cy ON c.country_id = cy.country_id
GROUP BY cs.first_name + ' ' + cs.last_name, cs.active, cy.country, c.city
ORDER BY SUM(p.amount) DESC;

use sakila;
--4.2
select  cu.first_name,cu.last_name, sum(p.amount) as rental_amount,film.rating 
from customer cu
join rental r on r.customer_id = cu.customer_id 
join inventory i on i.inventory_id = r.inventory_id
join film film on film.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where  rating = 'PG' or rating = 'PG-13'
group by cu.first_name,cu.last_name,film.rating 
order by sum(p.amount) desc;

--4.3
SELECT sum(p.amount) as Rental_amount, cus.last_name, cus.first_name, c.country 
from payment p JOIN customer cus 
on p.customer_id = cus.customer_id
JOIN address ad 
on cus.address_id = ad.address_id
JOIN city ci 
on ad.city_id = ci.city_id
JOIN country c 
on ci.country_id = c.country_id
WHERE c.country  IN ('France','Italy','Germany')
GROUP by c.country, p.amount, cus.last_name, cus.first_name
order by c.country ;

--4.4--
select top 20 m.first_name, m.last_name, sum(p.amount), DENSE_RANK() OVER( ORDER BY SUM(p.amount) DESC) AS SalesRank, c.name
from film f join film_category fc
on fc.film_id = f.film_id
join category c
on  c.category_id =fc.category_id
join inventory i 
on i.film_id = f.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on p.rental_id = r.rental_id
join customer m
on m.customer_id = r.customer_id
where c.name = 'comedy'
group by m.first_name, m.last_name, c.name
;

--4.5--
select c.last_name, c.first_name, sum(pay.amount) as Rental_amount, co.country as Country 
from country co
JOIN city ci 
on co.country_id = ci.country_id
JOIN address ad 
on ci.city_id = ad.city_id
JOIN customer c 
on ad.address_id = c.address_id 
JOIN payment pay 
on c.customer_id = pay.customer_id
JOIN rental r 
on pay.rental_id = r.rental_id
JOIN inventory i 
on r.inventory_id = i.inventory_id
JOIN film f 
on i.film_id = f.film_id

where co.country = 'China' and f.replacement_cost > 24
group by c.last_name, c.first_name, co.country
order by Rental_amount desc;


