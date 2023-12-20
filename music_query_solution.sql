select employee_id, first_name, last_name, title from employee group by title, employee_id order by levels desc  limit 1;


--which country has the most invoice
select billing_country, count(1) as tot 
from invoice 
group by billing_country 
order by tot desc;


--top 3 value of invoice
select total from invoice
order by total desc
limit 3;

select * from customer;

--4 city which has the highest sum of invoices
select billing_city, sum(total) as tota from invoice as i group by i.billing_city order by tota desc;


--5  best custmer who has spent the most money
select c.customer_id, concat(c.first_name,c.last_name) as name, sum(i.total) as total from invoice as i join customer as c on c.customer_id=i.customer_id group by c.customer_id order by total desc limit 1;

--set 2 
select c.customer_id, email, concat(c.first_name,c.last_name) as name
from customer as c join invoice as i on c.customer_id=i.customer_id
join invoice_line as l on i.invoice_id=l.invoice_id
where track_id in 
(select t.track_id from track as t join genre as g on t.genre_id=g.genre_id where g.name='Rock')
group by email ,c.customer_id, c.first_name, c.last_name
order by email;



select distinct a.name, count(1) as total, g.name 
from artist as a join album as al on a.artist_id=al.artist_id 
join track as t on t.album_id=al.album_id 
join genre as g on t.genre_id=g.genre_id where g.name='Rock' 
group by a.name, g.name 
order by total desc
limit 10;


--set 2 sol 3
select name, milliseconds 
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


--set 3 
--sol 1
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	limit 1
)
SELECT c.customer_id,  c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--set 3
-- sol 2 max purchase from each country
with cte1 as
(
select c.country as country, g.name as Genre, g.genre_id,count(il.quantity) as total_purchase ,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
from customer as c 
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on  i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
group by c.country,2,3
order by 1 asc, 5 desc
)

select * from cte1 where RowNo<=1;


--sol 3 max money spent from each country
WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;